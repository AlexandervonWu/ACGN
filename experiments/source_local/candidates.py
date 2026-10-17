"""Finite, source-only operator substitutions; no local truth-label inference."""
from dataclasses import dataclass
import hashlib
import json

CARDS = ('U:NO', 'U:ONE', 'U:LONE', 'U:SOME')
SCHEMA = 'feedback-executor-canonical-v4'


def identity(obs):
    """Bind occurrence IDs to this exact source graph and revision, not names."""
    return json.dumps([obs['revision'], obs['current']], sort_keys=True, separators=(',', ':'))


@dataclass(frozen=True)
class Candidate:
    origin: str
    site: int
    operand: int
    operator: int

    @property
    def key(self):
        return hashlib.sha256(json.dumps([self.origin, self.site, self.operand,
                                         self.operator]).encode()).hexdigest()

    def path(self, obs):
        if identity(obs) != self.origin:
            raise ValueError('STALE_SOURCE_GRAPH')
        if obs['draft'] or obs['actions']['holes'] or obs['closed']:
            raise ValueError('NOT_AN_EDIT_BOUNDARY')
        if [8, self.site] not in obs['actions']['sites']:
            raise ValueError('SOURCE_SITE_UNAVAILABLE')
        return [dict(control=0, site=self.site, family=8),
                dict(control=6, operator=self.operator),
                dict(control=1, pointer=self.operand), dict(control=8)]

    def check_commit(self, before, after):
        """Fail closed unless the source AST changes only the chosen operator."""
        if identity(before) != self.origin or after['revision'] != before['revision'] + 1:
            raise ValueError('COMMIT_ORIGIN_MISMATCH')
        expected = json.loads(json.dumps(before['current']))
        expected['nodes'][self.site][0] = self.operator
        for name, table in expected.items():
            # Derived canonical views may change substantially; source views may not.
            if not name.startswith('canonical') and after['current'][name] != table:
                raise ValueError('NONLOCAL_SOURCE_CHANGE: ' + name)


def candidates(obs, operators):
    """Exactly three alternatives for `all x : D | card E`.

    One binder, one declaration, static graph, located unary body and operand.
    E is copied at the same lexical scope; Java action heads and COMMIT remain
    authoritative for scope, type and source-span legality. No oracle/feedback
    fields are read. A syntactic proposal is NOT yet an executable candidate.
    """
    if obs['schema'] != SCHEMA:
        raise ValueError('UNKNOWN_OBSERVATION_SCHEMA')
    if obs['draft'] or obs['actions']['holes'] or obs['closed']:
        return ()
    g = obs['current']; nodes = g['nodes']; ports = g['ports']
    if not nodes or operators[nodes[0][0]] != 'Q:ALL':
        return ()
    # Exclude temporal crossings, multiple declarations/binders and nested binds.
    if len(g['bindings']) != 1 or g['bindings'][0][0] != 0 or len(g['phases']) != 1:
        return ()
    edges = [p for p in ports if p[0] == 0]
    body = [p[1] for p in edges if p[3] == 2]
    if len(edges) != 2 or len(body) != 1 or sum(p[3] == 1 for p in edges) != 1:
        return ()
    site = body[0]; old = operators[nodes[site][0]]
    children = [p[1] for p in ports if p[0] == site]
    if old not in CARDS or len(children) != 1:
        return ()
    operand = children[0]
    if g['types'][nodes[site][1]][0] != 1 or g['types'][nodes[operand][1]][3] < 1:
        return ()
    located = {r[0] for r in g['occurrences'] if r[1] == 1}
    if not {site, operand} <= located or [8, site] not in obs['actions']['sites']:
        return ()
    return tuple(Candidate(identity(obs), site, operand, operators.index(op))
                 for op in CARDS if op != old)
