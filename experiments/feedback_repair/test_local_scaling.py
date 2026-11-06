"""Source-backed bounded tests for scaling the local-repair contract."""
from contextlib import nullcontext
import json
import os
from pathlib import Path
import unittest
from unittest.mock import patch

import torch
from . import test_local
from .run_gates import sha
from .local_runtime import collect_label
from .local_scale_data import absolute_task, teacher_task
from .scaling_data import prepare_source
from .local_scale_bank import training_index, rollin_tasks, LocalBank
from .train_gates import worker
from .train_local import rollout
from . import train_local_scaled as scaled


class LocalScalingTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.classes = Path(os.environ['FEEDBACK_TEST_CLASSES'])
        torch.set_num_threads(2)

    setUp = test_local.LocalTest.setUp
    tearDown = test_local.LocalTest.tearDown

    def prepare(self):
        # The shared fixture has a task dictionary attribute, not a model feature.
        task = {**self.task, 'path': self.source.name, 'status': 'SOURCE_READY',
                'sourceHash': sha(self.source), 'group': 'fixture:question'}
        (self.directory/'teachers').mkdir()
        row, _ = collect_label(self.classes, absolute_task(task, self.directory), self.directory/'teachers', 'fixture')
        self.assertEqual(row['status'], 'REPLAY_ADMITTED', row)
        row['split'] = 'train'
        entries = training_index([task], [row], self.directory/'teachers')
        with worker(self.classes, self.directory/'catalog.log') as process:
            operators = process.request('catalog')['operators']
        return task, entries, operators

    def test_source_identity_and_external_root(self):
        task = {**self.task, 'path': self.source.name, 'sourceHash': sha(self.source)}
        self.assertEqual(absolute_task(task, self.directory)['path'], str(self.source))
        with self.assertRaisesRegex(ValueError, 'SOURCE_IDENTITY'):
            absolute_task({**task, 'sourceHash': 'wrong'}, self.directory)

    def test_heldout_teacher_refused_before_io(self):
        for split in ('validation', 'evaluation'):
            with self.assertRaisesRegex(ValueError, 'TRAIN_ONLY'):
                teacher_task({'split': split}, None, None, None)

    def test_training_index_scope_and_coverage(self):
        tasks = [{'id': 'a', 'split': 'train'}, {'id': 'b', 'split': 'evaluation'}]
        row = {'id': 'a', 'split': 'train', 'status': 'REPLAY_ADMITTED', 'decisions': 2, 'trajectory': 'a.json'}
        self.assertEqual(training_index(tasks, [row], self.directory)[0]['count'], 2)
        with self.assertRaisesRegex(ValueError, 'TRAIN_ONLY'):
            training_index(tasks, [{**row, 'id': 'b'}], self.directory)
        with self.assertRaisesRegex(ValueError, 'TRAIN_ONLY'):
            training_index(tasks, [{**row, 'split': 'evaluation'}], self.directory)
        with self.assertRaisesRegex(ValueError, 'DUPLICATE_TEACHER'):
            training_index(tasks, [row, row], self.directory)
        with self.assertRaisesRegex(ValueError, 'NO_TRAIN_TEACHERS'):
            training_index(tasks, [{**row, 'status': 'ENCODING_NOT_ADMITTED'}], self.directory)

    def test_rollins_ignore_success_and_exclude_heldout(self):
        tasks = [{'id': str(i), 'group': group, 'split': split, 'status': status}
                 for i, (group, split, status) in enumerate([
                     ('a', 'train', 'SOURCE_FAILED'), ('a', 'train', 'SOURCE_READY'),
                     ('b', 'train', 'SOURCE_READY'), ('c', 'validation', 'SOURCE_READY')])]
        self.assertEqual([t['id'] for t in rollin_tasks(tasks, 3)], ['0', '2', '1'])
        tasks[0]['status'] = 'SOURCE_READY'
        self.assertEqual([t['id'] for t in rollin_tasks(tasks, 2)], ['0', '2'])

    def test_bank_transparent_and_bounded(self):
        _, entries, operators = self.prepare()
        bank = LocalBank(operators)
        with self.assertRaisesRegex(ValueError, 'UNKNOWN'):
            bank.get(entries[0], 0)
        bank.admit(entries)
        graph, obs, alternatives = bank.get(entries[0], 0)
        again = bank.get(entries[0], 0)
        self.assertIs(graph, again[0])
        self.assertEqual((obs, alternatives), again[1:])
        cold = LocalBank(operators, budget=0)
        cold.admit(entries)
        rebuilt = cold.get(entries[0], 0)
        self.assertEqual(cold.used, 0)
        self.assertEqual(len(cold.cache), 0)
        self.assertEqual(graph.addresses, rebuilt[0].addresses)
        for field in ('kinds', 'values', 'edges', 'roles'):
            torch.testing.assert_close(getattr(graph, field), getattr(rebuilt[0], field))
        self.assertEqual((obs, alternatives), rebuilt[1:])
        with self.assertRaisesRegex(ValueError, 'UNKNOWN'):
            bank.get(entries[0], entries[0]['count'])

    def test_unaccepted_teacher_rejected(self):
        _, entries, operators = self.prepare()
        path = Path(entries[0]['path'])
        record = json.loads(path.read_text())
        record['final']['closed'] = False
        path.write_text(json.dumps(record))
        bank = LocalBank(operators)
        bank.admit(entries)
        with self.assertRaisesRegex(ValueError, 'TEACHER_NOT_ACCEPTED'):
            bank.get(entries[0], 0)

    def test_failed_request_accounting(self):
        obs = {'revision': 0, 'history': [], 'closed': False, 'remaining': 256}
        with patch('experiments.feedback_repair.train_local.worker', return_value=nullcontext(None)), \
             patch('experiments.feedback_repair.train_local.load', return_value=obs), \
             patch('experiments.feedback_repair.train_local.execute', side_effect=TimeoutError('fixture')):
            trial = rollout({'id': 'failure'}, None, self.directory, [], None, 'cpu', 'noop', 17)
        self.assertEqual(trial['queriesIssued'], 1)
        self.assertEqual(trial['decisionsIssued'], 1)
        self.assertFalse(trial['solved'])
        self.assertIn('error', trial)

    def test_json_subprocesses_disable_shared_perfdata(self):
        with patch('experiments.feedback_repair.train_gates.JavaWorker') as constructor:
            worker(self.classes, self.directory/'worker.log')
            self.assertIn('-XX:-UsePerfData', constructor.call_args.kwargs['command'])
        with patch('experiments.feedback_repair.local_runtime.subprocess.run', side_effect=RuntimeError('fixture')) as run:
            collect_label(self.classes, self.task, self.directory, 'failed')
            self.assertIn('-XX:-UsePerfData', run.call_args.args[0])
        with patch('experiments.feedback_repair.scaling_data.subprocess.run', side_effect=RuntimeError('fixture')) as run:
            prepare_source({'source': str(self.source), 'id': 'fixture', 'preferred': 'candidate'},
                           self.directory, self.classes)
            self.assertIn('-XX:-UsePerfData', run.call_args.args[0])

    def test_failure_denominator_and_heldout_rollin(self):
        tasks = [{'id': 'failed', 'split': 'evaluation', 'status': 'SOURCE_FAILED'}]
        stats, rows = scaled.evaluate(tasks, self.directory, self.classes, self.directory/'evaluation',
                                       [], None, 'cpu', 'noop', 17, 1)
        self.assertEqual((stats['tasks'], stats['repairs'], stats['errors']), (1, 0, 1))
        self.assertEqual(len(rows), 1)
        with self.assertRaisesRegex(ValueError, 'TRAIN_ONLY'):
            scaled.evaluate(tasks, self.directory, self.classes, self.directory/'refused',
                            [], None, 'cpu', 'noop', 17, 1, snapshots=True)

    def test_short_actual_training_and_aggregation(self):
        task, entries, operators = self.prepare()
        config = {'name': 'fixture', 'variant': 'gin', 'width': 16, 'layers': 1}
        with patch.object(scaled, 'INITIAL_UPDATES', 2), patch.object(scaled, 'ROUND_UPDATES', 1), \
             patch.object(scaled, 'BATCH', 1):
            _, record = scaled.train(config, 17, entries, self.directory, self.classes, operators,
                                      [task], self.directory/'training', 'cpu', 1)
        self.assertEqual(record['updates'], 4)
        self.assertEqual(record['finiteNonzeroGradientUpdates'], 4)
        self.assertEqual(len(record['rounds']), 2)
        self.assertGreater(record['encoderDelta'], 0)
        checkpoint = torch.load(self.directory/'training/policy-2.pt', weights_only=True)
        self.assertEqual(checkpoint['config'], config)
        self.assertEqual(checkpoint['round'], 2)


if __name__ == '__main__':
    unittest.main()
