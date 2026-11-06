"""Exact public tables -> typed incidence graph; no hashes or row-ID features."""
from dataclasses import dataclass
import torch
from .run_gates import check_tables


@dataclass
class Graph:
    kinds: torch.Tensor
    values: torch.Tensor
    edges: torch.Tensor
    roles: torch.Tensor
    addresses: dict

    def to(self, device):
        return Graph(*(x.to(device) for x in (self.kinds, self.values, self.edges, self.roles)), self.addresses)

    def permute(self, order):
        """order maps old addresses to new ones, including all typed pointers."""
        inverse = torch.argsort(order)
        return Graph(self.kinds[inverse], self.values[inverse], order[self.edges], self.roles,
                     {k: int(order[v]) for k, v in self.addresses.items()})


SOURCE = ('nodes', 'ports', 'types', 'typePorts', 'symbols', 'symbolParents', 'bindings',
          'scopes', 'occurrences', 'phases', 'canonicalNodes', 'canonicalPorts', 'canonicalTypes',
          'canonicalTypePorts', 'canonicalBindings', 'canonicalDependencies', 'canonicalOrbits',
          'canonicalPhases', 'canonicalPhasePorts')
WORLD = ('symbols', 'typePorts', 'worlds', 'atoms', 'tuples')
TABLES = tuple(f'{g}.{t}' for g in ('initial', 'current') for t in SOURCE) + tuple(
    'feedback.' + t for t in WORLD) + ('draft', 'draftDeclarations', 'history', 'holes', 'state', 'group')
assert len(TABLES) < 128


def encode(observation, operators, archive=None):
    check_tables(observation)
    rows = {}
    for g in ('initial', 'current'):
        if set(observation[g]) != set(SOURCE):
            raise ValueError('Unknown source/canonical tables')
        for t in SOURCE:
            rows[g + '.' + t] = observation[g][t]
    if set(observation['feedback']) != set(WORLD) | {'omittedWorlds'}:
        raise ValueError('Unknown feedback tables')
    for t in WORLD:
        rows['feedback.' + t] = observation['feedback'][t]
    for t in ('draft', 'draftDeclarations', 'history'):
        rows[t] = observation[t]
    rows['holes'] = observation['actions']['holes']
    rows['state'] = [[observation['remaining'], observation['status'], int(observation['closed']),
                      observation['feedback']['omittedWorlds']]]
    addresses, kinds, values, edges, roles = {}, [], [], [], []
    for table in TABLES:
        for i, row in enumerate(rows.get(table, [])):
            addresses[table, i] = len(kinds)
            kinds.append(TABLES.index(table))
            values.append(row + [0] * (16 - len(row)))
    groups = {}

    def link(a, b, role):
        edges.extend(((a, b), (b, a))); roles.extend((role, role + 16))

    def ptr(table, i, col, target, index=None):
        a = addresses[table, i]
        value = rows[table][i][col] if index is None else index
        values[a][col] = 0
        if value >= 0:
            if (target, value) not in addresses:
                raise ValueError(f'Dangling {table}[{i}].{col} -> {target}:{value}')
            link(a, addresses[target, value], col)

    def group(table, i, col, key):
        a = addresses[table, i]; values[a][col] = 0
        if key not in groups:
            groups[key] = len(kinds); kinds.append(TABLES.index('group'))
            # Group identity is edges, never its address or source spelling.
            values.append([TABLES.index(table), col] + [0] * 14)
        link(a, groups[key], col)

    def ordinary(table, columns):
        for i in range(len(rows[table])):
            for col, target in columns.items():
                ptr(table, i, col, target)

    for g in ('initial', 'current'):
        def t(name): return g + '.' + name
        for name, columns in {
            'ports': {0: 'nodes', 1: 'nodes'}, 'symbols': {1: 'types', 2: 'symbols'},
            'symbolParents': {0: 'symbols', 1: 'symbols'},
            'bindings': {0: 'nodes', 1: 'types', 3: 'nodes', 6: 'phases', 7: 'bindings'},
            'scopes': {0: 'nodes', 1: 'bindings'}, 'occurrences': {0: 'nodes'},
            'phases': {0: 'phases', 1: 'nodes'},
            'canonicalPorts': {0: 'canonicalNodes', 1: 'canonicalNodes'},
            'canonicalTypePorts': {0: 'canonicalTypes', 1: 'canonicalTypes'},
            'canonicalBindings': {0: 'canonicalPhases', 3: 'canonicalPhases', 5: 'canonicalTypes', 10: 'symbols'},
            'canonicalDependencies': {0: 'canonicalBindings', 1: 'canonicalBindings'},
            'canonicalOrbits': {0: 'canonicalBindings', 1: 'canonicalBindings'},
            'canonicalPhases': {0: 'canonicalNodes'},
            'canonicalPhasePorts': {0: 'canonicalNodes', 1: 'canonicalPhases'},
        }.items():
            ordinary(t(name), {c: t(target) for c, target in columns.items()})
        for i, row in enumerate(rows[t('nodes')]):
            for col, target in ((1, 'types'), (3, 'phases'), (4, 'nodes')):
                ptr(t('nodes'), i, col, t(target))
            op = operators[row[0]]
            if op in ('SIG', 'FIELD', 'VAR'):
                ptr(t('nodes'), i, 2, t('bindings' if op == 'VAR' else 'symbols'))
        for i, row in enumerate(rows[t('typePorts')]):
            ptr(t('typePorts'), i, 0, t('types')); ptr(t('typePorts'), i, 3, t('symbols'))
            group(t('typePorts'), i, 1, (g, 'product', row[0], row[1]))
        for i, row in enumerate(rows[t('bindings')]):
            for col in (4, 5):
                if row[col] >= 0: group(t('bindings'), i, col, (g, 'disj', col, row[col]))
        for i, row in enumerate(rows[t('canonicalNodes')]):
            ptr(t('canonicalNodes'), i, 1, t('canonicalTypes')); ptr(t('canonicalNodes'), i, 5, t('canonicalPhases'))
            if row[3] in (1, 2):
                ptr(t('canonicalNodes'), i, 4, t('symbols' if row[3] == 1 else 'canonicalBindings'))
        for i, row in enumerate(rows[t('canonicalTypes')]):
            if row[0] in (5, 6): ptr(t('canonicalTypes'), i, 1, t('symbols'))
        for i, row in enumerate(rows[t('canonicalBindings')]):
            for col in (4, 8, 9):
                if row[col] >= 0 and (col != 8 or row[col] > 0):
                    group(t('canonicalBindings'), i, col, (g, 'cb', col, row[3], row[col]))
            # Ordinal is an ordering coordinate within its role, not a learned identity.
    ordinary('feedback.symbols', {1: 'current.symbols', 2: 'feedback.worlds'})
    ordinary('feedback.typePorts', {0: 'feedback.symbols', 3: 'feedback.symbols'})
    for i, row in enumerate(rows['feedback.typePorts']):
        group('feedback.typePorts', i, 1, ('feedback-product', row[0], row[1]))
    atom_ids = {}
    for i, row in enumerate(rows['feedback.atoms']):
        atom_ids[row[0], row[1]] = i
        ptr('feedback.atoms', i, 0, 'feedback.worlds')
        values[addresses['feedback.atoms', i]][1] = 0
    for i, row in enumerate(rows['feedback.tuples']):
        ptr('feedback.tuples', i, 0, 'feedback.worlds'); ptr('feedback.tuples', i, 2, 'feedback.symbols')
        group('feedback.tuples', i, 3, ('tuple', *row[:4]))
        ptr('feedback.tuples', i, 5, 'feedback.atoms', atom_ids[row[0], row[5]])
    for i, row in enumerate(rows['draft']):
        ptr('draft', i, 2, 'draft')
        # FeedbackDraft's negative leaf tags are a versioned enumeration.
        target = {-1: 'current.nodes', -2: 'current.symbols', -3: 'current.bindings',
                  -4: 'draftDeclarations', -11: 'feedback.symbols'}.get(row[0])
        if target == 'draftDeclarations':
            matching = [j for j, d in enumerate(rows['draftDeclarations']) if d[2] == row[1]]
            if len(matching) != 1: raise ValueError('Unknown draft variable')
            ptr('draft', i, 1, target, matching[0])
        elif target: ptr('draft', i, 1, target)
        if row[8] >= 0: group('draft', i, 8, ('draft-binding', row[8]))
    ordinary('draftDeclarations', {0: 'draft'})
    for i, row in enumerate(rows['draftDeclarations']):
        group('draftDeclarations', i, 1, ('declaration', row[0], row[1]))
        group('draftDeclarations', i, 2, ('draft-binding', row[2]))
    ordinary('holes', {0: 'draft', 3: 'current.types', 4: 'current.phases', 5: 'current.nodes', 7: 'current.nodes'})
    # Old revisions come only from earlier public packets retained by the caller.
    # Reuse semantic channels; revision-qualified addresses are never features.
    for revision in sorted({r[0] for r in rows['history']} - {0, observation['revision']}):
        if archive is None or revision not in archive:
            raise ValueError('HISTORY_VIEW_UNAVAILABLE')
        historical = archive[revision]
        if historical['revision'] != revision:
            raise ValueError('HISTORY_REVISION_MISMATCH')
        historical = {**historical, 'history': [], 'draft': [], 'draftDeclarations': [],
                      'actions': {**historical['actions'], 'holes': []}}
        extra = encode(historical, operators)
        offset = len(kinds)
        if offset + len(extra.kinds) > 8192:
            raise ValueError('HISTORY_ROW_BUDGET_EXCEEDED')
        kinds.extend(extra.kinds.tolist()); values.extend(extra.values.tolist())
        edges.extend((a + offset, b + offset) for a, b in extra.edges.T.tolist())
        roles.extend(extra.roles.tolist())
        for (table, row), address in extra.addresses.items():
            if table.startswith('current.'):
                addresses[f'revision{revision}.' + table.removeprefix('current.'), row] = offset + address
    transaction = -1
    for i, row in enumerate(rows['history']):
        revision, control = row[:2]
        if control == 0: transaction += 1
        g = 'initial' if revision == 0 else 'current' if revision == observation['revision'] else f'revision{revision}'
        ptr('history', i, 2, g + '.nodes')
        target = {1: g + '.nodes', 2: g + '.symbols', 3: g + '.bindings', 15: 'feedback.symbols'}.get(control)
        if control == 9: target = g + '.nodes'
        if target: ptr('history', i, 4, target)
        elif control == 4 and row[4] >= 0:
            group('history', i, 4, ('history-draft-variable', revision, transaction, row[4]))
        # Preserve chronology explicitly; storage order is not an embedding.
        if i: link(addresses['history', i-1], addresses['history', i], 15)
    if len(kinds) > 8192: raise ValueError('ENCODED_ROW_BUDGET_EXCEEDED')
    return Graph(torch.tensor(kinds, dtype=torch.long), torch.tensor(values, dtype=torch.int64),
                 torch.tensor(edges, dtype=torch.long).T.reshape(2, -1), torch.tensor(roles, dtype=torch.long), addresses)
