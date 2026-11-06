import copy
import unittest

from acgn_repair.proof_gate import ProofGate


def fixture_steps():
    first = {"budgetBefore": 3, "budgetAfter": 2, "menuSize": 2, "action": 0,
             "bankBefore": 7, "bankAfter": 7, "tokenBefore": "a", "tokenAfter": "b",
             "profileBefore": "p", "profileAfter": "p", "phiBefore": 250, "phiAfter": 400,
             "reward": 140, "base": -10, "terminal": False, "solved": False,
             "rejected": False, "contextSat": True, "extraUnsat": False, "missingUnsat": False}
    last = {**first, "budgetBefore": 2, "budgetAfter": 1, "tokenBefore": "b", "tokenAfter": "c",
            "phiBefore": 400, "phiAfter": 0, "reward": -410, "terminal": True}
    return [first, last]


class ProofGateTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.gate = ProofGate()

    @classmethod
    def tearDownClass(cls):
        cls.gate.close()

    def check(self, steps=None, **kwargs):
        options = {"train": True, "uncensored": True, "policy_before": 0,
                   "policy_after": 0, "profile": "p"}
        options.update(kwargs)
        return self.gate.check(fixture_steps() if steps is None else steps, **options)

    def test_exact_suffix_returns_and_telescope(self):
        receipt = self.check()
        self.assertEqual(receipt.returns, (-270, -410))
        self.assertEqual(receipt.returns[0], -20 - 250)
        self.assertEqual(receipt.rewards, (140, -410))

    def test_admission_rejects_each_step_guard(self):
        changes = {"budgetBefore": 0, "budgetAfter": 3, "menuSize": 0, "action": 2,
                   "bankAfter": 8, "tokenAfter": "a", "profileAfter": "q",
                   "phiBefore": -1, "phiAfter": 1001, "reward": 141, "base": -50,
                   "terminal": True, "solved": True, "rejected": True}
        for key, value in changes.items():
            with self.subTest(field=key):
                steps = fixture_steps()
                steps[0][key] = value
                with self.assertRaisesRegex(ValueError, "Lean application gate rejected"):
                    self.check(steps)

    def test_request_and_chain_guards(self):
        for options in ({"train": False}, {"uncensored": False}, {"policy_after": 1},
                        {"profile": "q"}, {"profile": ""}):
            with self.subTest(options=options), self.assertRaises(ValueError):
                self.check(**options)
        for steps in ([], fixture_steps()[:1], fixture_steps() * 17):
            with self.assertRaises(ValueError):
                self.check(steps)
        for key, value in (("tokenBefore", "disconnected"), ("terminal", False), ("bankBefore", 6)):
            steps = fixture_steps()
            steps[1][key] = value
            with self.subTest(field=key), self.assertRaises(ValueError):
                self.check(steps)

    def test_success_requires_both_answers_and_context(self):
        step = {**fixture_steps()[0], "solved": True, "terminal": True, "base": 1000,
                "phiAfter": 0, "reward": 750, "extraUnsat": True, "missingUnsat": True}
        self.assertEqual(self.check([step]).returns, (750,))
        for field in ("extraUnsat", "missingUnsat", "contextSat"):
            broken = {**step, field: False}
            with self.subTest(field=field), self.assertRaises(ValueError):
                self.check([broken])

    def test_terminal_bank_change_is_allowed_not_continuation(self):
        steps = fixture_steps()
        steps[-1]["bankAfter"] += 1
        self.assertEqual(self.check(steps).returns, (-270, -410))
        steps[0]["bankAfter"] += 1
        with self.assertRaises(ValueError):
            self.check(steps)

    def test_checked_reward_and_generation_binding(self):
        receipt = self.check()
        receipt.require_matches([140, -410], 0)
        for rewards, generation in (([140, -411], 0), ([140, -410], 1), ([140], 0)):
            with self.assertRaises(ValueError):
                receipt.require_matches(rewards, generation)

    def test_decoder_does_not_coerce_bad_values(self):
        for field, value in (("action", -1), ("reward", 1.5), ("terminal", 1), ("menuSize", "2")):
            steps = copy.deepcopy(fixture_steps())
            steps[0][field] = value
            with self.subTest(field=field), self.assertRaises(ValueError):
                self.check(steps)


if __name__ == "__main__":
    unittest.main()
