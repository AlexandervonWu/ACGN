import copy
import json
from pathlib import Path
import unittest
from .candidates import candidates

FIXTURE = Path(__file__).with_name('fixtures')/'be563a3a9ebe9062107c.json'


class CandidateTests(unittest.TestCase):
    def setUp(self):
        fixture = json.loads(FIXTURE.read_text())
        self.obs = fixture['observation']; self.ops = fixture['operators']

    def test_real_previously_unsupported_input(self):
        cs = candidates(self.obs, self.ops)
        self.assertEqual([self.ops[c.operator] for c in cs], ['U:ONE', 'U:LONE', 'U:SOME'])
        self.assertEqual([(c.site, c.operand) for c in cs], [(3, 4)]*3)
        self.assertEqual(len({c.key for c in cs}), 3)
        self.assertEqual(cs, candidates(copy.deepcopy(self.obs), self.ops))
        self.assertEqual(cs[0].path(self.obs), [dict(control=0,site=3,family=8),
            dict(control=6,operator=self.ops.index('U:ONE')),dict(control=1,pointer=4),dict(control=8)])

    def test_whole_predicate_labels_never_select_local_candidates(self):
        before = candidates(self.obs, self.ops)
        for label in (False, True):
            self.obs['feedback'] = {'worlds': [[0, 0, int(label), int(not label), 1, 0]]}
            self.obs['oracle'] = 'must not be inspected'
            self.assertEqual(before, candidates(self.obs, self.ops))
        # In a two-node world one local no(n.adj) may be true while all n is false.
        local_cardinality_truths = [True, False]
        self.assertNotEqual(local_cardinality_truths[0], all(local_cardinality_truths))

    def test_stale_revision_or_graph_refused(self):
        c = candidates(self.obs, self.ops)[0]
        for mutate in (lambda o: o.update(revision=1),
                       lambda o: o['current']['nodes'][4].__setitem__(0,self.ops.index('B:PLUS'))):
            changed = copy.deepcopy(self.obs); mutate(changed)
            with self.assertRaisesRegex(ValueError,'STALE_SOURCE_GRAPH'): c.path(changed)

    def test_nonlocal_change_refused(self):
        c = candidates(self.obs, self.ops)[0]; after = copy.deepcopy(self.obs)
        after['revision'] += 1; after['current']['nodes'][c.site][0] = c.operator
        c.check_commit(self.obs, after)
        after['current']['nodes'][0][0] = self.ops.index('Q:SOME')
        with self.assertRaisesRegex(ValueError,'NONLOCAL_SOURCE_CHANGE'): c.check_commit(self.obs, after)

    def test_source_position_required(self):
        for node in (3,4):
            obs = copy.deepcopy(self.obs)
            next(r for r in obs['current']['occurrences'] if r[0] == node)[1] = 0
            self.assertEqual(candidates(obs,self.ops),())

    def test_outside_scope_shapes_refused(self):
        changes = [lambda g:g['nodes'][0].__setitem__(0,self.ops.index('Q:SOME')),
                   lambda g:g['bindings'].append(g['bindings'][0][:]),
                   lambda g:g['phases'].append([0,0,0]),
                   lambda g:g['nodes'][3].__setitem__(0,self.ops.index('U:NOT')),
                   lambda g:g['ports'].append([0,4,2,1])]
        for change in changes:
            obs = copy.deepcopy(self.obs); change(obs['current'])
            self.assertEqual(candidates(obs,self.ops),())

    def test_disabled_action_and_active_draft_refused(self):
        obs=copy.deepcopy(self.obs); obs['actions']['sites'].remove([8,3])
        self.assertEqual(candidates(obs,self.ops),())
        obs=copy.deepcopy(self.obs); obs['draft']=[[0]]
        self.assertEqual(candidates(obs,self.ops),())

    def test_unknown_schema_refused(self):
        self.obs['schema']='future-schema'
        with self.assertRaisesRegex(ValueError,'UNKNOWN_OBSERVATION_SCHEMA'):
            candidates(self.obs,self.ops)




class CorpusRegressionTests(unittest.TestCase):
    """New recorded natural observations; no synthetic coverage extrapolation."""
    def test_all_104_denominator_and_natural_coverage(self):
        import gzip
        root = Path(__file__).resolve().parents[2]
        evidence = root/'docs/repair-search/source-local-20261017'
        old = json.loads((root/'docs/canonical-edit-learning/results/multistep_scaling_20261004/natural-coverage.json').read_text())
        observations = json.loads(gzip.decompress((evidence/'coverage-observations.json.gz').read_bytes()))
        old_by_id = {r['id']:r for r in old}
        self.assertEqual(len(old),104); self.assertEqual(len(old_by_id),104)
        self.assertEqual(len(observations),95)
        self.assertEqual({r['id'] for r in observations},
                         {r['id'] for r in old if r['status']=='GRAMMAR_UNSUPPORTED'})
        matched = {}
        for row in observations:
            cs=candidates(row['observation'],row['operators'])
            if cs: matched[row['id']]=len(cs)
        self.assertEqual(matched, {k:3 for k in ('be563a3a9ebe9062107c','ae1005bc105b6803a89e',
                                               '9a4a7746df4e4f77a4e7','c44a0fb82108da00c1a0')})
        self.assertTrue(all(old_by_id[k]['status']=='GRAMMAR_UNSUPPORTED' for k in matched))

    def test_all_real_candidate_traces_keep_context_and_validate(self):
        import gzip
        root=Path(__file__).resolve().parents[2]
        evidence=root/'docs/repair-search/source-local-20261017'
        traces=json.loads(gzip.decompress((evidence/'candidate-traces.json.gz').read_bytes()))
        self.assertEqual(len(traces),12)
        ops=json.loads(FIXTURE.read_text())['operators']
        solved=[]
        for name, trace in traces.items():
            records=trace['records']
            self.assertEqual([r['action']['control'] for r in records],[11,0,6,1,8,11])
            self.assertEqual(records[0]['after']['status'],4)
            self.assertTrue(records[0]['after']['feedback']['worlds'])
            for before, after in zip(records,records[1:]):
                self.assertEqual(before['after'],after['before'])
            chosen=next(c for c in candidates(records[0]['before'],ops) if c.key==trace['result']['key'])
            chosen.check_commit(records[0]['before'],records[-2]['after'])
            final=records[-1]['after']
            self.assertIn(final['status'],(4,5))
            self.assertEqual(trace['result']['solved'],final['closed'] and final['status']==5)
            if final['status']==5: solved.append(name.split('-')[0])
            else: self.assertTrue(final['feedback']['worlds'])
        self.assertEqual(solved,['c44a0fb82108da00c1a0'])

if __name__ == '__main__': unittest.main()
