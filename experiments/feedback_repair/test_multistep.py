"""Finite semantic and source-to-result checks for attempt-level repair learning."""
import copy
from itertools import product
import os
from pathlib import Path
import tempfile
import unittest

import torch

from .contextual import ReplayedEpisode
from .local_runtime import execute, load
from .multistep import (CARDS, PLANS, MODES, MultistepPolicy, PlanAgent, evidence,
                        evaluate, holds, survivors, frame, path, rollout, shape,
                        training_examples, prepare_examples, episode_loss, examples_from_replay)
from .train_gates import worker


class MultistepTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.classes = Path(os.environ['FEEDBACK_TEST_CLASSES'])
        torch.set_num_threads(2)

    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.root = Path(self.temp.name)
        with worker(self.classes, self.root/'catalog.log') as process:
            self.ops = process.request('catalog')['operators']

    def tearDown(self):
        self.temp.cleanup()

    def task(self, goal, name='fixture'):
        source = self.root/(name+'.als')
        source.write_text('sig A, B {}\npred candidate { some A and some B }\n'
                          'pred oracle { '+goal+' }\nrun {} for 3\n')
        return dict(id=name, path=str(source), target='candidate', oracle='oracle', command=0, split='train')

    def episode(self):
        task = self.task('one A and lone B')
        trial = rollout(task, self.classes, self.root/'episode.log', self.ops)
        self.assertNotIn('error', trial)
        return task, trial

    def test_cardinality_and_evidence_algebra(self):
        for c, n in product(range(4), range(32)):
            self.assertEqual(holds(c, n), holds(c, min(n, 2)))
        for target in PLANS:
            events = []
            previous = set(range(16))
            for a, b in product(range(3), repeat=2):
                events.append((a, b, int(evaluate(target, (a, b))), 0))
                current = set(survivors(events))
                self.assertLessEqual(current, previous)
                self.assertIn(PLANS.index(target), current)
                previous = current
            self.assertEqual(current, {PLANS.index(target)})

    def test_all_sixteen_paths_match_real_alloy(self):
        for index, plan in enumerate(PLANS):
            with self.subTest(plan=plan):
                goal = CARDS[plan[0]][2:].lower()+' A and '+CARDS[plan[1]][2:].lower()+' B'
                task = self.task(goal, str(index))
                with worker(self.classes, self.root/f'all-{index}.log') as process:
                    obs = load(process, task)
                    for action in path(obs, self.ops, index):
                        obs = execute(process, obs, action)
                        self.assertIn(obs['status'], (0, 1))
                    self.assertEqual(shape(obs, self.ops)[0], plan)
                    obs = execute(process, obs, {'control': 11})
                    self.assertTrue(obs['closed'])
                    self.assertEqual(obs['status'], 5)

    def test_actual_branch_and_failed_attempt_replay(self):
        task, trial = self.episode()
        examples = training_examples(task, trial, self.classes, self.root/'replay.log', self.ops)
        self.assertTrue(trial['solved'])
        self.assertGreaterEqual(len(examples), 2)
        checks = [r['after'] for r in trial['records'] if r['role'] == 'controller']
        self.assertEqual([x['status'] for x in checks], [4, 4, 5])
        self.assertEqual([x['revision'] for x in checks], [0, 1, 2])
        self.assertNotEqual(examples[0].plan, examples[1].plan)
        self.assertEqual(trial['decisionsIssued'], 17)

    def test_same_fault_different_feedback_different_plan(self):
        observations = []
        for i, goal in enumerate(('no A and some B', 'some A and no B')):
            with worker(self.classes, self.root/f'branch-{i}.log') as process:
                obs = load(process, self.task(goal, f'branch-{i}'))
                observations.append(execute(process, obs, {'control': 11}))
        self.assertEqual(observations[0]['current'], observations[1]['current'])
        agents = [PlanAgent(self.ops) for _ in observations]
        for agent, obs in zip(agents, observations):
            agent(obs)
        self.assertNotEqual(agents[0].attempts[0]['plan'], agents[1].attempts[0]['plan'])
        self.assertNotEqual(evidence(observations[0], self.ops), evidence(observations[1], self.ops))

    def test_blind_inputs_remove_feedback_and_history(self):
        _, trial = self.episode()
        obs = trial['records'][1]['observation']
        changed = copy.deepcopy(obs)
        changed['feedback']['worlds'][0][2] ^= 1
        changed['history'][0][2] = 999
        # Both are presentation views only, never sent back to the executor.
        a, b = frame(obs, self.ops, {15}, True), frame(changed, self.ops, {15}, True)
        for attribute in ('event', 'candidates', 'available'):
            torch.testing.assert_close(getattr(a, attribute), getattr(b, attribute))
        for attribute in ('kinds', 'values', 'edges', 'roles'):
            torch.testing.assert_close(getattr(a.graph, attribute), getattr(b.graph, attribute))

    def test_latest_projection_does_not_duplicate_old_feedback(self):
        _, trial = self.episode()
        obs = next(r['observation'] for r in trial['records'] if r['role'] == 'policy'
                   and r['observation']['revision'] == 1)
        events = evidence(obs, self.ops)
        self.assertLessEqual(len(events), 2)
        changed = copy.deepcopy(obs)
        changed['feedback']['worlds'][0][2] ^= 1
        self.assertEqual(events, evidence(changed, self.ops))

    def test_missing_mapping_and_temporal_world_refused(self):
        _, trial = self.episode()
        obs = copy.deepcopy(trial['records'][1]['observation'])
        for symbol in obs['feedback']['symbols']:
            symbol[1] = -1
        with self.assertRaisesRegex(ValueError, 'MAPPING'):
            evidence(obs, self.ops)
        obs = copy.deepcopy(trial['records'][1]['observation'])
        obs['feedback']['worlds'][0][4] = 2
        with self.assertRaisesRegex(ValueError, 'NONSTATIC'):
            evidence(obs, self.ops)

    def test_modes_memory_and_gradients(self):
        task, trial = self.episode()
        examples = training_examples(task, trial, self.classes, self.root/'gradient-replay.log', self.ops)
        for mode in MODES:
            torch.manual_seed(17)
            model = MultistepPolicy(mode, 16, 1)
            batch = prepare_examples(examples, self.ops, mode)
            loss = episode_loss(model, batch)
            self.assertTrue(torch.isfinite(loss))
            loss.backward()
            for parameter in (model.event[0].weight, model.score[0].weight, model.encoder.scalar.weight):
                self.assertTrue(torch.isfinite(parameter.grad).all())
                self.assertGreater(float(parameter.grad.norm()), 0)
            if mode != 'reset':
                self.assertGreater(float(model.memory.weight_hh.grad.norm()), 0)
            x = batch[-1][0]
            a, _, memory = model(batch[0][0])
            prior, _, _ = model(x, memory)
            reset, _, _ = model(x)
            if mode == 'reset':
                torch.testing.assert_close(prior, reset)
            else:
                self.assertFalse(torch.allclose(prior[x.available], reset[x.available]))

    def test_source_scope_and_plan_index_refused(self):
        task = self.task('one A and some B')
        with worker(self.classes, self.root/'scope.log') as process:
            obs = load(process, task)
        with self.assertRaisesRegex(ValueError, 'INDEX_INVALID'):
            path(obs, self.ops, -1)
        obs['current']['nodes'][0][0] = self.ops.index('B:OR')
        with self.assertRaisesRegex(ValueError, 'CONJUNCTION_REQUIRED'):
            shape(obs, self.ops)

    def test_no_heldout_or_unreplayed_training(self):
        with self.assertRaisesRegex(ValueError, 'FRESH_REPLAY_REQUIRED'):
            examples_from_replay({}, self.ops)
        with self.assertRaisesRegex(ValueError, 'TRAIN_ONLY'):
            training_examples({'split': 'test'}, {}, None, None, self.ops)
        with self.assertRaisesRegex(ValueError, 'NO_MULTISTEP'):
            examples_from_replay(ReplayedEpisode([], {}), self.ops)

    def test_trial_feedback_mutation_rejected_by_java_replay(self):
        task, trial = self.episode()
        trial['records'][0]['after']['feedback']['worlds'][0][2] ^= 1
        with self.assertRaisesRegex(ValueError, 'REPLAY_DIVERGED'):
            training_examples(task, trial, self.classes, self.root/'tampered.log', self.ops)


if __name__ == '__main__':
    unittest.main()
