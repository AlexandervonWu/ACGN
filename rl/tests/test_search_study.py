import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

from acgn_repair.search_study import PROOF, admit, load, tasks, worker
from acgn_repair.language_study import messages
from acgn_repair.report_search import language_diagnostics


class SearchStudyTest(unittest.TestCase):
    def test_generation_failure_reporting(self):
        rows = [dict(attempts=[
            dict(status='FORMAT_ERROR', response=dict(status='FORMAT_ERROR',
                 response=dict(done=False))),
            dict(status='FORMAT_ERROR', response=dict(status='FORMAT_ERROR',
                 response=dict(done=True, done_reason='length'))),
            dict(status='COUNTEREXAMPLE', response=dict(done=True, done_reason='stop'))])]
        self.assertEqual(language_diagnostics(rows), dict(attempts=3,
            statuses={'FORMAT_ERROR': 2, 'COUNTEREXAMPLE': 1},
            incompleteResponses=1, outputTokenLimits=1))

    def test_prompt_uses_only_public_fields(self):
        prompt=messages(dict(schema=[],facts='true',body='some A',teacher='SECRET_ORACLE_BODY'),
                        [{'expected':True,'relations':{'A':'{A$0}'}}])
        self.assertNotIn('SECRET_ORACLE_BODY',json.dumps(prompt))
        self.assertEqual([m['role'] for m in prompt],['system','user'])
        self.assertIn('A$0',json.dumps(prompt))

    def test_lean_admission_matrix(self):
        base = dict(kind='repair', split='evaluation', sourceHash='s', profileHash='p',
                    identityBound=True, contextSat=True, extraUnsat=True, missingUnsat=True,
                    used=1, budget=2)
        cases = [(base, True), ({**base,'kind':'training','split':'train'},True)]
        cases += [({**base,k:v}, False) for k,v in [('identityBound',False),('contextSat',False),
            ('extraUnsat',False),('missingUnsat',False),('used',3),('sourceHash',''),
            ('profileHash',''),('kind','training'),('kind','unknown')]]
        for request, accepted in cases:
            result = subprocess.run(['lean','--run',str(PROOF)],input=json.dumps(request)+'\n',
                                    text=True,capture_output=True,check=True)
            self.assertEqual(json.loads(result.stdout),dict(request=request,accepted=accepted))

    def test_question_split_and_counts(self):
        rows=tasks()
        self.assertEqual(sum(t['split']=='train' for t in rows),16)
        self.assertEqual(sum(t['split']=='evaluation' for t in rows),8)
        self.assertFalse({t['group'] for t in rows if t['split']=='train'} &
                         {t['group'] for t in rows if t['split']=='evaluation'})

    def test_actual_source_boundary_and_repair(self):
        classes = os.environ['ACGN_RL_CLASSES']
        with tempfile.TemporaryDirectory() as folder:
            folder=Path(folder)
            path=folder/'model.als'
            path.write_text('sig A {}\npred faulty { some A }\npred oracle { no A }\nrun {} for 3\n')
            task=dict(path=str(path),target='faulty',oracle='oracle',command=0,split='evaluation')
            with worker(classes, folder/'worker.log') as w:
                root=load(w,task,budget=5)
                self.assertNotIn('teacher',root)
                self.assertTrue(root['witnesses'])
                for body in ('oracle[]','} fact { no A } pred escaped {', 'some && A'):
                    rejected=w.request('propose',body=body,force=True)
                    self.assertEqual(rejected['status'],'INVALID')
                repaired=w.request('propose',body='no A',force=True)
                self.assertEqual(repaired['status'],'SOLVED_WITHIN_PROFILE')
                self.assertTrue(admit(repaired,root,'evaluation')['accepted'])
                with self.assertRaises(ValueError):
                    admit(repaired,{**root,'profileHash':'wrong'},'evaluation')
                with self.assertRaises(ValueError):
                    admit(repaired,{**root,'sourceHash':'wrong'},'evaluation')
                with self.assertRaises(ValueError):
                    admit(repaired,root,'evaluation','training')
                self.assertTrue(admit(repaired,root,'train','training')['accepted'])


if __name__=='__main__':
    unittest.main()
