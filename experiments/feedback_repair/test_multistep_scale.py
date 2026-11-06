"""Finite correspondence checks for variable-arity, evidence-filtered repair."""
import copy
from itertools import product
import os
from pathlib import Path
import tempfile
import unittest

import torch

from .local_runtime import load, execute
from .multistep_scale import (CARDS, plans, shape, evaluate, evidence, available, frame,
                              path, ScalePolicy, rollout, training_examples, loss)
from .train_gates import worker


class ScalingTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.classes = Path(os.environ['FEEDBACK_TEST_CLASSES'])
        torch.set_num_threads(2)

    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.root = Path(self.temp.name)
        with worker(self.classes, self.root/'catalog.log') as p:
            self.ops = p.request('catalog')['operators']

    def tearDown(self):
        self.temp.cleanup()

    def task(self, n=3, op='AND', goal=None, name='fixture'):
        letters = 'ABCD'[:n]
        goal = goal or (1, 2, 3, 1)[:n]
        join = ' '+op.lower()+' '
        source = self.root/(name+'.als')
        source.write_text('sig '+', '.join(letters)+' {}\npred candidate { '+
                          join.join('some '+s for s in letters)+' }\npred oracle { '+
                          join.join(CARDS[c][2:].lower()+' '+s for c, s in zip(goal, letters))+
                          ' }\nrun {} for 3\n')
        return dict(id=name, path=str(source), target='candidate', oracle='oracle', command=0, split='train')

    def checked(self):
        task = self.task()
        with worker(self.classes, self.root/'initial.log') as p:
            obs = load(p, task)
            obs = execute(p, obs, {'control': 11})
        return obs

    def test_variadic_semantics_and_bounds(self):
        for n in (2, 3, 4):
            self.assertEqual(len(plans(n)), 4**n)
            for op in ('AND', 'OR'):
                for plan in plans(n):
                    for counts in product(range(3), repeat=n):
                        expanded = tuple(6 if c == 2 else c for c in counts)
                        self.assertEqual(evaluate(op, plan, expanded), evaluate(op, plan, counts))
        with self.assertRaisesRegex(ValueError, 'ARITY'):
            evaluate('AND', (1, 2), (1,))
        with self.assertRaisesRegex(ValueError, 'ARITY'):
            plans(5)

    def test_real_paths_across_arities_and_connectives(self):
        for n, op in product((2, 3, 4), ('AND', 'OR')):
            for goal in ((0,)*n, (1,)*n, (2,)*n, tuple(i % 4 for i in range(n))):
                name = op+str(n)+''.join(map(str, goal))
                task = self.task(n, op, goal, name)
                with worker(self.classes, self.root/(name+'.log')) as p:
                    obs = load(p, task)
                    actions = path(obs, self.ops, plans(n).index(goal))
                    self.assertEqual(len(actions), 3*n+1)
                    for action in actions:
                        obs = execute(p, obs, action)
                        self.assertIn(obs['status'], (0, 1))
                    self.assertEqual(shape(obs, self.ops).current, goal)
                    checked = execute(p, obs, {'control': 11})
                    self.assertEqual(checked['status'], 5)
                    self.assertTrue(checked['closed'])

    def test_evidence_filter_never_reintroduces_or_repeats(self):
        obs = self.checked(); s = shape(obs, self.ops)
        events = set(evidence(obs, self.ops))
        first = set(available(s, set(), events))
        self.assertNotIn(plans(3).index(s.current), first)
        self.assertIn(plans(3).index((1, 2, 3)), first)
        selected = min(first)
        more = events | {((1, 0, 1), 1)}
        self.assertLessEqual(set(available(s, {selected}, more)), first - {selected})
        for i in available(s, set(), more):
            self.assertTrue(all(evaluate(s.op, plans(3)[i], x) == bool(y) for x, y in more))

    def test_real_replay_with_exploration_and_budget_failures(self):
        task = self.task()
        trial = rollout(task, self.classes, self.root/'rollout.log', self.ops, explore=True)
        self.assertNotIn('error', trial)
        self.assertLessEqual(trial['queriesIssued'], 4)
        self.assertLessEqual(trial['decisionsIssued'], 43)
        self.assertTrue(all(a['consistent'] for a in trial['attempts']))
        examples = training_examples(task, trial, self.classes, self.root/'replay.log', self.ops)
        self.assertEqual(examples[0][1], -1)
        self.assertTrue(examples)
        model = ScalePolicy(16, 1)
        value = loss(model, examples)
        self.assertTrue(torch.isfinite(value)); value.backward()
        self.assertGreater(float(model.encoder.scalar.weight.grad.norm()), 0)

    def test_heldout_and_changed_replay_refused(self):
        with self.assertRaisesRegex(ValueError, 'TRAIN_ONLY'):
            training_examples({'split': 'test'}, {}, None, None, self.ops)
        task = self.task()
        trial = rollout(task, self.classes, self.root/'good.log', self.ops)
        trial['records'][0]['after']['status'] = 5
        with self.assertRaisesRegex(ValueError, 'REPLAY_DIVERGED'):
            training_examples(task, trial, self.classes, self.root/'bad.log', self.ops)

    def test_old_evidence_retained_outside_window(self):
        obs = self.checked(); s = shape(obs, self.ops)
        saved = set(evidence(obs, self.ops))
        changed = copy.deepcopy(obs)
        changed['feedback']['worlds'] = []
        # Missing current feedback cannot erase controller-owned older evidence.
        combined = saved | set(evidence(changed, self.ops))
        self.assertEqual(available(s, set(), saved), available(s, set(), combined))

    def test_missing_mapping_and_wrong_revision_refused(self):
        obs = self.checked()
        bad = copy.deepcopy(obs)
        for r in bad['feedback']['symbols']:
            r[1] = -1
        with self.assertRaisesRegex(ValueError, 'MAPPING'):
            evidence(bad, self.ops)
        bad = copy.deepcopy(obs); bad['revision'] += 1
        with self.assertRaisesRegex(ValueError, 'UNBOUND'):
            evidence(bad, self.ops)

    def test_model_respects_mask_and_variable_arity(self):
        model = ScalePolicy(16, 1).eval()
        for n in (2, 3, 4):
            task = self.task(n, name='arity'+str(n))
            with worker(self.classes, self.root/f'arity{n}.log') as p:
                obs = execute(p, load(p, task), {'control': 11})
            x = frame(obs, self.ops, set(), set(evidence(obs, self.ops)))
            scores, _, memory = model(x)
            self.assertEqual(len(scores), 4**n)
            self.assertTrue(torch.isneginf(scores[~x.available]).all())
            self.assertTrue(torch.isfinite(scores[x.available]).all())
            reset, _, _ = model(x, memory, reset=True)
            torch.testing.assert_close(reset, scores)

    def test_mixed_and_duplicate_source_refused(self):
        obs = self.checked()
        bad = copy.deepcopy(obs)
        unary = next(i for i, r in enumerate(bad['current']['nodes']) if self.ops[r[0]] in CARDS)
        bad['current']['nodes'][unary][0] = self.ops.index('U:NOT')
        with self.assertRaisesRegex(ValueError, 'HOMOGENEOUS'):
            shape(bad, self.ops)
        bad = copy.deepcopy(obs); s = shape(bad, self.ops)
        bad['current']['nodes'][s.leaves[1]][2] = s.symbols[0]
        with self.assertRaisesRegex(ValueError, 'DISTINCT'):
            shape(bad, self.ops)

    def test_split_groups_and_counts(self):
        from .train_multistep_scaled import make_tasks
        from collections import Counter
        tasks = make_tasks(self.root)
        self.assertEqual(Counter(t['split'] for t in tasks),
                         Counter(train=144, validation=32, test=32, arity4=32))
        groups = {}
        for task in tasks:
            group = (task['arity'], tuple(sorted(task['privateGoal'])))
            self.assertEqual(groups.setdefault(group, task['split']), task['split'])


if __name__ == '__main__':
    unittest.main()
