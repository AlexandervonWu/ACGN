"""Bounded checks for larger-data split, admission and selection boundaries."""
from collections import Counter
from copy import deepcopy
from pathlib import Path
import unittest
import json
import torch

from .scaling_data import select_sources, eligible, teacher_task
from .train_scaled import training_index, select_config, sample_schedule, TeacherBank
from .train_gates import rollout
from .test_replay import ReplayTest
from .replay import replay
from .tables import encode


class ScalingTest(unittest.TestCase):
    setUp=ReplayTest.setUp
    load=ReplayTest.load
    source=staticmethod(ReplayTest.source)
    action=staticmethod(ReplayTest.action)

    def candidates(self):
        return [Path(f'classified-data/problem/over/file{j}_inv{i}.als') for i in range(80) for j in range(5)]

    def test_selection_order_independent(self):
        paths=self.candidates(); quotas={'train':8,'validation':4,'evaluation':4}
        self.assertEqual(select_sources(paths,quotas,2),select_sources(list(reversed(paths)),quotas,2))

    def test_question_split_and_quotas(self):
        quotas={'train':8,'validation':4,'evaluation':4}
        rows=select_sources(self.candidates(),quotas,2); seen={}
        self.assertEqual(Counter(r['split'] for r in rows),Counter(quotas))
        self.assertLessEqual(max(Counter(r['group'] for r in rows).values()),2)
        for row in rows: self.assertEqual(seen.setdefault(row['group'],row['split']),row['split'])

    def test_training_index_rejects_heldout(self):
        tasks=[{'id':'a','split':'train'},{'id':'b','split':'evaluation'}]
        good={'id':'a','split':'train','status':'REPLAY_VALIDATED_TEACHER','decisions':2}
        self.assertEqual(training_index(tasks,[good]),[('a',2)])
        with self.assertRaisesRegex(ValueError,'Held-out'):
            training_index(tasks,[{**good,'id':'b'}])
        with self.assertRaisesRegex(ValueError,'Held-out'):
            training_index(tasks,[{**good,'split':'evaluation'}])

    def test_teacher_refuses_heldout_before_io(self):
        for split in ('validation','evaluation'):
            with self.assertRaisesRegex(ValueError,'Held-out'):
                teacher_task({'split':split},None,None,None)

    def test_only_ast_exclusions_leave_denominator(self):
        ready={'id':'a','status':'SOURCE_READY','group':'q',
               'metadata':{'studentAstHash':'s','oracleAstHash':'o'}}
        rows=[ready,{**deepcopy(ready),'id':'duplicate'}, {'id':'fail','status':'SOURCE_FAILED'},
              {'id':'identical','status':'AST_IDENTICAL'}]
        self.assertEqual([r['id'] for r in eligible(rows)],['a','fail'])
        self.assertEqual(rows[1]['status'],'DUPLICATE_AST_PAIR')

    def test_selection_uses_validation_and_size_only(self):
        arms=[{'name':'a','validation':{'repairs':2},'parameters':100,'order':0,'testRepairs':999},
              {'name':'b','validation':{'repairs':3},'parameters':100,'order':1,'testRepairs':0},
              {'name':'c','validation':{'repairs':3},'parameters':50,'order':2,'testRepairs':0}]
        self.assertEqual(select_config(arms)['name'],'c')
        arms[0]['testRepairs']=100000; arms[2]['testRepairs']=-5
        self.assertEqual(select_config(arms)['name'],'c')

    def test_paired_schedules_and_bank_namespace(self):
        index=[('a',2),('b',3)]
        a=sample_schedule(index,17,5,4)
        self.assertEqual(a,sample_schedule(index,17,5,4))
        self.assertEqual(len(a),5); self.assertTrue(all(len(b)==4 for b in a))
        self.assertTrue(all(0<=i<dict(index)[key] for b in a for key,i in b))
        bank=TeacherBank(Path('/unused'),index,[])
        with self.assertRaisesRegex(ValueError,'Unknown'): bank.get('evaluation',0)
        with self.assertRaisesRegex(ValueError,'Unknown'): bank.get('a',2)

    def test_external_source_root_rollout(self):
        _,_,catalog=self.load(self.source())
        task={'id':'root-check','path':'source.als','target':'candidate','oracle':'oracle','command':0}
        result=rollout(task,self.classes,self.directory,catalog['operators'],None,'cpu','noop',17,
                       task_root=self.directory)
        self.assertTrue(result['wellFormed'],result)
        self.assertNotIn('error',result)
        self.assertFalse(result['solved'])
        self.assertEqual(result['queries'],1)

    def test_lazy_cache_preserves_replayed_example(self):
        w,obs,catalog=self.load(self.source())
        data=replay(w,obs,ReplayTest.path(self,obs,catalog))
        (self.directory/'teachers').mkdir()
        (self.directory/'teachers/a.json').write_text(json.dumps(data))
        bank=TeacherBank(self.directory,[('a',len(data['decisions']))],catalog['operators'])
        a=bank.get('a',0); b=bank.get('a',0)
        expected=encode(data['decisions'][0]['observation'],catalog['operators'])
        self.assertEqual(bank.encodedExamples,1)
        self.assertIs(a[0],b[0]); self.assertEqual(a[1:],b[1:])
        for field in ('kinds','values','edges','roles'):
            self.assertTrue(torch.equal(getattr(a[0],field),getattr(expected,field)))
        self.assertEqual(a[0].addresses,expected.addresses)
        self.assertEqual(a[3],0); self.assertEqual(bank.get('a',1)[3],1)
        self.assertEqual(bank.encodedExamples,2)
        bank.cache.clear(); bank.used=0
        cold=bank.get('a',0)
        self.assertEqual(cold[1:],a[1:])
        self.assertTrue(torch.equal(cold[0].values,a[0].values))


if __name__=='__main__': unittest.main()
