"""Execute Lean rollout admission; this checks records, not solver truth."""

from dataclasses import dataclass
from collections import OrderedDict
import hashlib
import json
import os
from pathlib import Path
import subprocess
import tempfile
from .transformer import GRAPH_FILES, graph_request, transformer_contract_hash


FORMAL = Path(__file__).resolve().parents[2] / "docs/rl-repair/formal"
CONTRACT_FILES = ("ApplicationCore.lean", "ApplicationGate.lean", "ApplicationRunner.lean")


def contract_hash():
    digest = hashlib.sha256()
    for name in CONTRACT_FILES:
        digest.update(name.encode("ascii") + b"\0" + (FORMAL / name).read_bytes() + b"\0")
    return digest.hexdigest()


def step_record(before, action, after):
    """Bind the worker fields without coercing malformed numeric/Boolean values."""
    if before["terminal"] is not False or after["previousToken"] != before["token"]:
        raise ValueError("Closed or disconnected worker trace")
    if after["actionIndex"] != action or after["episode"] != before["episode"]:
        raise ValueError("Action or episode changed in worker reply")
    bank, next_bank = before["bank"], after["bank"]
    for state in (before, after):
        if state["score"]["bankVersion"] != bank["version"] or state["score"]["bankHash"] != bank["hash"]:
            raise ValueError("Score belongs to a different bank snapshot")
    if bank["version"] == next_bank["version"] and bank["hash"] != next_bank["hash"]:
        raise ValueError("Unversioned bank change")
    if after["oldPotential"] != before["score"]["potential"]:
        raise ValueError("Old potential differs from the actual observation")
    if after["terminal"] is False and after["newPotential"] != after["score"]["potential"]:
        raise ValueError("Continuing potential differs from the actual observation")
    validation = after.get("validation", {})
    return {
        "budgetBefore": before["remaining"], "budgetAfter": after["remaining"],
        "menuSize": len(before["observation"]["actions"]), "action": action,
        "bankBefore": bank["version"], "bankAfter": next_bank["version"],
        "tokenBefore": before["token"], "tokenAfter": after["token"],
        "profileBefore": bank["profile"], "profileAfter": next_bank["profile"],
        "phiBefore": after["oldPotential"], "phiAfter": after["newPotential"],
        "reward": after["reward"], "base": after["baseReward"],
        "terminal": after["terminal"], "solved": after["status"] == "SOLVED_WITHIN_PROFILE",
        "rejected": after["transition"] == "REJECTED", "contextSat": next_bank["context"] == "SAT",
        "extraUnsat": validation.get("extra") == "UNSAT",
        "missingUnsat": validation.get("missing") == "UNSAT",
    }


@dataclass(frozen=True)
class CheckedRollout:
    rewards: tuple
    returns: tuple
    generation: int
    contract: str
    request_hash: str

    def require_matches(self, rewards, generation):
        if tuple(rewards) != self.rewards or generation != self.generation or self.contract != contract_hash():
            raise ValueError("Checked rollout does not match rewards, policy, or proof contract")


class ProofGate:
    def __init__(self):
        self.contract = contract_hash()
        self.directory = tempfile.TemporaryDirectory(prefix="acgn-rl-lean-gate-")
        self.env = {**os.environ, "LEAN_PATH": self.directory.name}
        self.graph_cache = OrderedDict()
        self.graph_cache_bytes = 0
        self.graph_checks = self.graph_executions = 0
        self.graph_contract = None
        try:
            self.lean_version = subprocess.check_output(["lean", "--version"], text=True, timeout=15).strip()
            for name in CONTRACT_FILES[:2]:
                self._run(["lean", "-o", str(Path(self.directory.name) / Path(name).with_suffix(".olean")),
                           str(FORMAL / name)])
        except BaseException:
            self.close()
            raise

    def _run(self, command, payload=None):
        result = subprocess.run(command, input=payload, capture_output=True, text=True,
                                env=self.env, timeout=30)
        if result.returncode:
            raise ValueError("Lean application gate rejected: " + (result.stdout + result.stderr)[-4000:])
        return result.stdout

    def check(self, steps, *, train, uncensored, policy_before, policy_after, profile):
        if self.contract != contract_hash():
            raise ValueError("Proof inputs changed during run")
        request = {"train": train, "uncensored": uncensored, "policyBefore": policy_before,
                   "policyAfter": policy_after, "expectedProfile": profile, "steps": steps}
        payload = json.dumps(request, separators=(",", ":"), sort_keys=True, allow_nan=False) + "\n"
        if len(payload.encode("utf-8")) > 262144:
            raise ValueError("Application gate input exceeds bound")
        reply = json.loads(self._run(["lean", "--run", str(FORMAL / "ApplicationRunner.lean")], payload))
        if reply.get("accepted") is not True or reply.get("request") != request:
            raise ValueError("Lean reply is not bound to the submitted request")
        returns = reply["returns"]
        if len(returns) != len(steps) or any(type(value) is not int for value in returns):
            raise ValueError("Malformed checked return targets")
        return CheckedRollout(tuple(s["reward"] for s in steps), tuple(returns), policy_before,
                              self.contract, hashlib.sha256(payload.encode("utf-8")).hexdigest())

    def check_graph(self, observation, architecture, allowed=None):
        contract = transformer_contract_hash()
        if architecture.get("transformerContractHash") != contract:
            raise ValueError("Graph transformer checkpoint contract changed")
        if self.graph_contract is None:
            self._run(["lean", "-o", str(Path(self.directory.name) / "EGraph2Graph.olean"),
                       str(FORMAL / GRAPH_FILES[0])])
            self.graph_contract = contract
        if self.graph_contract != contract:
            raise ValueError("Graph proof inputs changed during run")
        request = graph_request(observation, architecture, allowed)
        payload = json.dumps(request, separators=(",", ":"), sort_keys=True, allow_nan=False) + "\n"
        size = len(payload.encode("utf-8"))
        if size > 8388608:
            raise ValueError("Graph gate input exceeds bound")
        key = hashlib.sha256(payload.encode("utf-8")).hexdigest()
        if key in self.graph_cache and self.graph_cache[key] == payload:
            self.graph_cache.move_to_end(key)
        else:
            reply = json.loads(self._run(["lean", "--run", str(FORMAL / GRAPH_FILES[1])], payload))
            if reply.get("accepted") is not True or reply.get("request") != request:
                raise ValueError("Lean graph admission is not bound to request")
            self.graph_executions += 1
            while self.graph_cache and self.graph_cache_bytes + size > 8388608:
                _, old = self.graph_cache.popitem(last=False)
                self.graph_cache_bytes -= len(old.encode("utf-8"))
            self.graph_cache[key] = payload
            self.graph_cache_bytes += size
        self.graph_checks += 1
        return {"contractHash": contract, "requestHash": key}

    def close(self):
        self.directory.cleanup()

    def __enter__(self):
        return self

    def __exit__(self, *args):
        self.close()
