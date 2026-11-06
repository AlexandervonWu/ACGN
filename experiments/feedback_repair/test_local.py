import copy
import json
import os
from pathlib import Path
import tempfile
import unittest

import torch
from .run_gates import ROOT
from .train_gates import worker
from .local_runtime import joint_loss, snapshot_equal, load, execute, replay_local, collect_label
from .tables import encode
from .gnn_variants import make_policy


class LocalTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.classes = Path(os.environ['FEEDBACK_TEST_CLASSES'])
        torch.set_num_threads(2)

    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.directory = Path(self.temp.name)
        self.source = self.directory/'source.als'
        self.source.write_text('sig S {}\npred candidate { some S }\npred oracle { no S }\nrun {} for 3\n')
        self.task = dict(id='fixture', path=str(self.source), target='candidate', oracle='oracle', command=0, split='train')

    def tearDown(self):
        self.temp.cleanup()

    def test_local_teacher_and_recovery(self):
        record, examples = collect_label(self.classes, self.task, self.directory, 'teacher')
        self.assertEqual(record['status'], 'REPLAY_ADMITTED', record)
        self.assertTrue(any(e['alternatives'][0]['control'] == 1 for e in examples))
        with worker(self.classes, self.directory/'prefix.log') as process:
            obs = load(process, self.task)
            prefix = [{'control': 0, 'site': 0, 'family': 8}]
            obs = execute(process, obs, prefix[0])
        record, examples = collect_label(self.classes, self.task, self.directory, 'recover', prefix, obs, True)
        self.assertEqual(record['status'], 'REPLAY_ADMITTED', record)
        self.assertEqual(examples[0]['kind'], 'recovery')
        self.assertEqual(examples[0]['alternatives'], [{'control': 10}])

    def test_joint_loss_deduplicates(self):
        with worker(self.classes, self.directory/'loss.log') as process:
            obs = load(process, self.task); operators = process.request('catalog')['operators']
        graph = encode(obs, operators)
        torch.manual_seed(17); model = make_policy('gin', 32, 1)
        a, b = {'control': 11}, {'control': 13}
        single = joint_loss(model, graph, obs, [a])
        duplicate = joint_loss(model, graph, obs, [a, a])
        both = joint_loss(model, graph, obs, [a, b])
        torch.testing.assert_close(single, duplicate)
        self.assertLessEqual(float(both), float(single))
        both.backward()
        self.assertGreater(float(model.scalar.weight.grad.norm()), 0)
        self.assertTrue(torch.isfinite(model.scalar.weight.grad).all())

    def test_snapshot_and_split_fail_closed(self):
        with self.assertRaisesRegex(ValueError, 'REPLAY_DIVERGED'):
            snapshot_equal({'revision': 1}, {'revision': 2})
        for split in ('validation', 'test'):
            with self.assertRaisesRegex(ValueError, 'TRAIN_ONLY'):
                collect_label(self.classes, {**self.task, 'split': split}, self.directory, split)

    def test_two_commits_preserve_history(self):
        with worker(self.classes, self.directory/'history.log') as process:
            obs = load(process, self.task); operators = process.request('catalog')['operators']
            archive = {}
            for op in ('U:NO', 'U:SOME'):
                for action in ({'control': 0, 'site': 0, 'family': 8},
                               {'control': 6, 'operator': operators.index(op)},
                               {'control': 1, 'pointer': 1}, {'control': 8}):
                    archive[obs['revision']] = copy.deepcopy(obs)
                    obs = execute(process, obs, action)
            self.assertEqual(obs['revision'], 2)
            graph = encode(obs, operators, archive)
            self.assertIn(('revision1.nodes', 0), graph.addresses)
            self.assertNotEqual(graph.addresses['revision1.nodes', 0], graph.addresses['current.nodes', 0])
            with self.assertRaisesRegex(ValueError, 'HISTORY_VIEW_UNAVAILABLE'):
                encode(obs, operators)
            wrong = {1: {**archive[1], 'revision': 9}}
            with self.assertRaisesRegex(ValueError, 'HISTORY_REVISION_MISMATCH'):
                encode(obs, operators, wrong)


if __name__ == '__main__':
    unittest.main()
