"""Bounded source-backed checks for contextual repair, not a corpus experiment."""
import copy
import os
from pathlib import Path
import tempfile
import unittest

import torch

from .contextual import (ContextualPolicy, PublicUnarySearch, phase, run_episode,
                         replay_for_training, sequence_loss)
from .local_runtime import load
from .policy import options
from .tables import encode
from .train_gates import worker


class ContextualTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.classes = Path(os.environ['FEEDBACK_TEST_CLASSES'])
        torch.set_num_threads(2)

    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.directory = Path(self.temp.name)
        self.source = self.directory/'source.als'
        self.source.write_text('sig S {}\npred candidate { some S }\npred oracle { one S }\nrun {} for 3\n')
        self.task = dict(id='context-fixture', path=str(self.source), target='candidate',
                         oracle='oracle', command=0, split='train')
        with worker(self.classes, self.directory/'catalog.log') as process:
            self.operators = process.request('catalog')['operators']
            self.initial = load(process, self.task)

    def tearDown(self):
        self.temp.cleanup()

    def episode(self, query_budget=4):
        return run_episode(self.task, self.classes, self.directory/'episode.log',
                           proposer=PublicUnarySearch(self.operators), query_budget=query_budget)

    def test_actual_failed_attempt_then_repaired(self):
        trial = self.episode()
        self.assertNotIn('error', trial)
        checks = [r for r in trial['records'] if r['role'] == 'controller']
        self.assertEqual([r['after']['status'] for r in checks], [4, 4, 5])
        self.assertEqual([r['after']['revision'] for r in checks], [0, 1, 2])
        self.assertFalse(checks[1]['after']['closed'])
        self.assertTrue(checks[1]['after']['feedback']['worlds'])
        self.assertTrue(trial['solved'])
        replay = replay_for_training(self.task, trial, self.classes, self.directory/'replay.log')
        self.assertEqual(replay.final, trial['final'])

    def test_unsolved_budget_limited_episode_is_retained(self):
        trial = self.episode(query_budget=2)
        self.assertNotIn('error', trial)
        self.assertEqual(trial['end'], 'QUERY_LIMIT')
        self.assertEqual(trial['queriesIssued'], 2)
        self.assertFalse(trial['solved'])
        replay_for_training(self.task, trial, self.classes, self.directory/'negative-replay.log')

    def test_policy_cannot_terminate_with_unchecked_stop(self):
        trial = run_episode(self.task, self.classes, self.directory/'stop.log',
                            proposer=lambda public: {'control': 12})
        self.assertIn('VERIFICATION_IS_CONTROLLER_OWNED', trial['error'])
        self.assertFalse(trial['solved'])
        self.assertEqual(trial['queriesIssued'], 1)

    def test_heldout_admission_refused_before_replay(self):
        for split in ('validation', 'evaluation'):
            with self.assertRaisesRegex(ValueError, 'TRAIN_ONLY'):
                replay_for_training({**self.task, 'split': split}, {}, None, None)

    def test_changed_source_and_false_feedback_refused(self):
        trial = self.episode()
        changed = copy.deepcopy(trial)
        changed['records'][0]['after']['status'] = 5
        with self.assertRaisesRegex(ValueError, 'REPLAY_DIVERGED'):
            replay_for_training(self.task, changed, self.classes, self.directory/'false-feedback.log')
        self.source.write_text(self.source.read_text()+'\n// changed source\n')
        with self.assertRaisesRegex(ValueError, 'EPISODE_ORIGIN'):
            replay_for_training(self.task, trial, self.classes, self.directory/'changed.log')

    def test_replay_requires_verification_after_commit(self):
        trial = self.episode()
        trial['records'][5]['role'] = 'policy'
        with self.assertRaisesRegex(ValueError, 'MISSING_REAL_VERIFICATION'):
            replay_for_training(self.task, trial, self.classes, self.directory/'roles.log')

    def test_prefix_memory_and_reset(self):
        trial = self.episode()
        torch.manual_seed(17)
        model = ContextualPolicy(16, 1).eval()
        first = encode(self.initial, self.operators)
        after = encode(trial['records'][0]['after'], self.operators)
        a, memory, _ = model.step(first)
        reset, reset_memory, _ = model.step(first)
        torch.testing.assert_close(a.query, reset.query)
        torch.testing.assert_close(memory, reset_memory)
        with_context, _, _ = model.step(after, memory)
        without_context, _, _ = model.step(after)
        self.assertFalse(torch.allclose(with_context.query, without_context.query))
        # Future action labels/results are not passed to step at all.
        changed = copy.deepcopy(trial)
        changed['records'][-1]['after']['status'] = 7
        public = encode(changed['records'][0]['observation'], self.operators)
        again, _, _ = model.step(public)
        torch.testing.assert_close(a.query, again.query)

    def test_contextual_mask_and_prediction_are_not_acceptance(self):
        model = ContextualPolicy(16, 1)
        graph = encode(self.initial, self.operators)
        view, _, _ = model.step(graph)
        choices = options(self.initial, 'control', {}, 0, 4)
        logits, _ = view.logits(view.hidden, view.query, choices, graph.addresses)
        for i, c in enumerate(choices):
            self.assertEqual(bool(torch.isneginf(logits[i])), c.fields['control'] in (11, 12))
        obs = {**self.initial, 'status': 7}
        self.assertEqual(phase(obs), 'INCONCLUSIVE')
        self.assertEqual(phase({**self.initial, 'remaining': 0}), 'DECISION_LIMIT')
        self.assertFalse(obs['closed'])

    def test_real_episode_gradients_and_historical_addresses(self):
        trial = self.episode()
        replay = replay_for_training(self.task, trial, self.classes, self.directory/'loss-replay.log')
        torch.manual_seed(17)
        model = ContextualPolicy(16, 1)
        loss = sequence_loss(model, replay, self.operators)
        self.assertTrue(torch.isfinite(loss))
        loss.backward()
        for parameter in (model.memory.weight_hh, model.outcome.weight, model.encoder.scalar.weight):
            self.assertTrue(torch.isfinite(parameter.grad).all())
            self.assertGreater(float(parameter.grad.norm()), 0)
        archive = {}
        for r in trial['records']:
            graph = encode(r['observation'], self.operators, archive)
            archive[r['observation']['revision']] = r['observation']
        self.assertIn(('revision1.nodes', 0), graph.addresses)

    def test_unreplayed_loss_refused(self):
        with self.assertRaisesRegex(ValueError, 'REPLAY_REQUIRED'):
            sequence_loss(ContextualPolicy(16, 1), {}, self.operators)


if __name__ == '__main__':
    unittest.main()
