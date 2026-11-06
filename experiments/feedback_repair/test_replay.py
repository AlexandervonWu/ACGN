"""Real worker replay tests; FEEDBACK_TEST_CLASSES must point at a current build."""
import os
from pathlib import Path
import sys
import tempfile
import unittest
import subprocess
import json
from copy import deepcopy

from .replay import CONTROLS, ReplayRejected, decision, replay

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'rl'))
from acgn_repair.worker import JavaWorker


class ReplayTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix='acgn-causal-replay-')
        self.addCleanup(self.temp.cleanup)
        self.directory = Path(self.temp.name)
        self.classes = Path(os.environ['FEEDBACK_TEST_CLASSES'])

    def load(self, source):
        path = self.directory / 'source.als'
        path.write_text(source, encoding='utf-8')
        worker = JavaWorker(ROOT, self.classes, self.directory / 'worker.log', timeout=30,
                            command=['java', '-ea', '-Xmx2g', '-cp', str(self.classes) + os.pathsep + str(ROOT/'lib/*'),
                                     'is.fivefivefive.ACGN.repair.FeedbackRepairWorker'])
        worker.__enter__()
        self.addCleanup(worker.__exit__, None, None, None)
        observation = worker.request('load', path=str(path), target='candidate', oracle='oracle', command=0, budget=64)['observation']
        catalog = worker.request('catalog')
        return worker, observation, catalog

    @staticmethod
    def source(oracle='no S'):
        return f'sig S {{}} pred candidate {{ some S }} pred oracle {{ {oracle} }} run {{}} for 3 but 4 Int'

    @staticmethod
    def action(name, **fields):
        return dict(control=CONTROLS.index(name), **fields)

    def path(self, observation, catalog):
        site = 0
        relation = next(i for i, row in enumerate(observation['current']['nodes'])
                        if row[0] == catalog['operators'].index('SIG'))
        return [self.action('VALIDATE'), self.action('BEGIN', site=site, family=catalog['families'].index('MATRIX_UPDATE')),
                self.action('OPERATOR', operator=catalog['operators'].index('U:NO')),
                self.action('COPY', pointer=relation), self.action('COMMIT'), self.action('STOP')]

    def test_real_path_and_causal_keys(self):
        worker, initial, catalog = self.load(self.source())
        path = self.path(initial, catalog)
        result = replay(worker, initial, iter(path))
        records = result['decisions']
        self.assertEqual(len(records), 6)
        self.assertEqual(records[0]['observation']['feedback']['worlds'], [])
        self.assertTrue(records[1]['observation']['feedback']['worlds'])
        self.assertEqual(records[-1]['observation']['revision'], 1)
        self.assertEqual(result['finalObservation']['status'], 5)
        self.assertEqual(initial['history'], [])
        self.assertEqual([item['action'] for item in records], path)
        for i, item in enumerate(records):
            self.assertEqual(len(item['observation']['history']), i)
            self.assertEqual(item['observation']['remaining'], 64-i)

    def test_wrong_final_body_is_not_teacher(self):
        worker, initial, _ = self.load(self.source())
        with self.assertRaisesRegex(ReplayRejected, 'No bounded-valid'):
            replay(worker, initial, [self.action('STOP')])

    def test_empty_or_no_validation_path_is_not_teacher(self):
        worker, initial, _ = self.load(self.source())
        with self.assertRaisesRegex(ReplayRejected, 'explicitly validate'):
            replay(worker, initial, [])

    def test_private_target_does_not_change_heads(self):
        _, left, _ = self.load(self.source())
        _, right, _ = self.load(self.source('some S'))
        self.assertEqual(left, right)
        self.assertEqual(decision(left, self.action('STOP')), decision(right, self.action('STOP')))

    def test_extra_source_or_revision_is_rejected(self):
        _, initial, _ = self.load(self.source())
        for extra in ({'source': 'no S'}, {'revision': 0}, {'oracle': 3}):
            with self.assertRaises(ReplayRejected):
                decision(initial, {**self.action('STOP'), **extra})

    def test_float_bool_and_overflow_rejected(self):
        _, initial, _ = self.load(self.source())
        for invalid in (True, 1.5, 2**32):
            with self.assertRaises(ReplayRejected):
                decision(initial, {'control': invalid})

    def test_unavailable_control_rejected(self):
        _, initial, _ = self.load(self.source())
        with self.assertRaisesRegex(ReplayRejected, 'unavailable'):
            decision(initial, self.action('COMMIT'))

    def test_future_transcript_cannot_be_initial_key(self):
        worker, initial, _ = self.load(self.source())
        altered = deepcopy(initial)
        altered['feedback']['worlds'] = [[0, 0, 1, 0, 1, -1]]
        with self.assertRaisesRegex(ReplayRejected, 'before feedback'):
            replay(worker, altered, [self.action('STOP')])

    def teacher(self, source):
        path = self.directory / 'teacher.als'
        path.write_text(source, encoding='utf-8')
        command = ['java', '-ea', '-Xmx2g', '-cp', str(self.classes) + os.pathsep + str(ROOT/'lib/*'),
                   'is.fivefivefive.ACGN.repair.FeedbackTeacherMain', str(path), 'candidate', 'oracle', '0', '64']
        result = subprocess.run(command, cwd=ROOT, text=True, capture_output=True, timeout=30, check=True)
        return json.loads(result.stdout)

    def test_offline_teacher_replays_on_real_worker(self):
        source = 'sig S {r:set S} pred candidate {some x:S|some x.r} pred oracle {all y:S|no y.r} run {} for 3 but 4 Int'
        teacher = self.teacher(source)
        self.assertEqual(teacher['status'], 'VALIDATED_LABEL_PATH')
        worker, observation, _ = self.load(source)
        result = replay(worker, observation, teacher['labels'])
        self.assertEqual(result['finalObservation']['status'], 5)
        self.assertTrue(all(set(row) <= {'control', 'operator', 'pointer', 'family', 'site', 'value',
                                        'count', 'disjoint', 'cardinality'} for row in teacher['labels']))

    def test_feedback_only_symbol_requires_actual_query(self):
        source = 'sig S {} sig Secret {} pred candidate {some S} pred oracle {some Secret} run {} for 3 but 4 Int'
        result = self.teacher(source)
        self.assertEqual(result['status'], 'VALIDATED_LABEL_PATH')
        self.assertTrue(any(label['control'] == CONTROLS.index('FEEDBACK_SYMBOL') for label in result['labels']))
        worker, observation, catalog = self.load(source)
        begin = self.action('BEGIN', family=catalog['families'].index('MATRIX_UPDATE'), site=0)
        draft = worker.request('decide', decision=decision(observation, begin))['observation']
        op = self.action('OPERATOR', operator=catalog['operators'].index('U:SOME'))
        draft = worker.request('decide', decision=decision(draft, op))['observation']
        self.assertEqual(draft['actions']['feedbackSymbols'], [])
        with self.assertRaises(ReplayRejected):
            decision(draft, self.action('FEEDBACK_SYMBOL', pointer=0))
        worker2, observation2, _ = self.load(source)
        trajectory = replay(worker2, observation2, result['labels'])
        self.assertEqual(trajectory['finalObservation']['status'], 5)
        use = next(row for row in trajectory['decisions'] if row['action']['control'] == CONTROLS.index('FEEDBACK_SYMBOL'))
        self.assertTrue(use['observation']['feedback']['worlds'])

    def test_joint_one_groups_preserve_the_original_quantifier(self):
        source = 'sig S {r:set S} pred candidate {some x:S|some x.r} pred oracle {one x:S, y:S | y in x.r} run {} for 3 but 4 Int'
        teacher = self.teacher(source)
        self.assertEqual(teacher['status'], 'VALIDATED_LABEL_PATH')
        self.assertEqual(sum(a['control'] == CONTROLS.index('QUANTIFIER') for a in teacher['labels']), 1)
        self.assertEqual(sum(a['control'] == CONTROLS.index('DECLARATION') for a in teacher['labels']), 1)
        worker, observation, _ = self.load(source)
        trajectory = replay(worker, observation, teacher['labels'])
        self.assertEqual(trajectory['finalObservation']['status'], 5)
        self.assertEqual(len(trajectory['decisions'][-2]['observation']['draftDeclarations']), 2)

    def test_dependent_domain_sees_only_preceding_groups(self):
        source = 'sig S {r:set S} pred candidate {some x:S|some x.r} pred oracle {all x:S, y:x.r | y != x} run {} for 3 but 4 Int'
        teacher = self.teacher(source)
        self.assertEqual(teacher['status'], 'VALIDATED_LABEL_PATH')
        worker, observation, _ = self.load(source)
        result = replay(worker, observation, teacher['labels'])
        self.assertEqual(result['finalObservation']['status'], 5)
        declaration = next(i for i, row in enumerate(result['decisions'])
                           if row['action']['control'] == CONTROLS.index('DECLARATION'))
        available = result['decisions'][declaration + 1]['observation']['actions']['draftVariables']
        self.assertEqual(available, [[0]])

    def test_integer_world_membership_is_present(self):
        source = 'pred candidate {some Int} pred oracle {some none} run {} for 3 but 4 Int'
        worker, observation, _ = self.load(source)
        queried = worker.request('decide', decision=decision(observation, self.action('VALIDATE')))['observation']
        feedback = queried['feedback']
        integer_symbol = next(i for i, row in enumerate(feedback['symbols']) if row[3] == 2)
        memberships = [row for row in feedback['tuples'] if row[2] == integer_symbol and row[0] == 0 and row[1] == 0]
        self.assertEqual(len(memberships), 16)
        values = {atom[3] for atom in feedback['atoms'] if atom[0] == 0 and atom[2] == 1}
        self.assertEqual(values, set(range(-8, 8)))

    def test_arrow_multiplicity_is_preserved(self):
        source = 'sig S {r:set S} pred candidate {some r} pred oracle {r in S -> lone S} run {} for 3 but 4 Int'
        teacher = self.teacher(source)
        self.assertEqual(teacher['status'], 'VALIDATED_LABEL_PATH')
        worker, observation, catalog = self.load(source)
        self.assertTrue(any(a.get('operator') == catalog['operators'].index('B:ANY_ARROW_LONE')
                            for a in teacher['labels']))
        self.assertEqual(replay(worker, observation, teacher['labels'])['finalObservation']['status'], 5)


if __name__ == '__main__':
    unittest.main()
