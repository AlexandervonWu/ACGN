#!/usr/bin/env python3
"""Create and verify fail-closed manifests for clean publication runs."""

from __future__ import annotations

import argparse
import datetime as dt
import hashlib
import json
import os
import pathlib
import platform
import socket
import subprocess
import sys
import uuid

SCHEMA = "acgn-publication-run-v1"


def sha256_file(path: pathlib.Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def fingerprint(root: pathlib.Path, suffix: str | None = None) -> dict[str, object]:
    files = sorted(
        path for path in root.rglob("*")
        if path.is_file() and (suffix is None or path.name.endswith(suffix))
    )
    digest = hashlib.sha256()
    byte_count = 0
    for path in files:
        relative = path.relative_to(root).as_posix()
        content = path.read_bytes()
        digest.update(relative.encode("utf-8"))
        digest.update(b"\0")
        digest.update(content)
        digest.update(b"\xff")
        byte_count += len(content)
    return {
        "sha256": digest.hexdigest(),
        "fileCount": len(files),
        "byteCount": byte_count,
    }


def run(*command: str, cwd: pathlib.Path | None = None) -> str:
    completed = subprocess.run(
        command,
        cwd=cwd,
        check=True,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
    )
    return completed.stdout.strip()


def git_identity(repo: pathlib.Path) -> tuple[str, bool]:
    commit = run("git", "rev-parse", "HEAD", cwd=repo)
    dirty = bool(run("git", "status", "--porcelain", "--untracked-files=all", cwd=repo))
    return commit, dirty


def dependencies(repo: pathlib.Path) -> list[dict[str, object]]:
    lib = repo / "lib"
    jars = sorted(path for path in lib.rglob("*.jar") if path.is_file())
    if not jars:
        raise RuntimeError(f"No dependency JARs found in {lib}")
    return [
        {
            "path": path.relative_to(repo).as_posix(),
            "sizeBytes": path.stat().st_size,
            "sha256": sha256_file(path),
        }
        for path in jars
    ]


def canonical_hash(value: object) -> str:
    encoded = json.dumps(value, sort_keys=True, separators=(",", ":")).encode("utf-8")
    return hashlib.sha256(encoded).hexdigest()


def utc_now() -> str:
    return dt.datetime.now(dt.timezone.utc).isoformat().replace("+00:00", "Z")


def identity_payload(manifest: dict[str, object]) -> dict[str, object]:
    keys = (
        "schemaVersion", "runId", "git", "source", "experimentJar",
        "dependencies", "dataset", "configuration", "commands", "runtime",
    )
    return {key: manifest[key] for key in keys}


def load(path: pathlib.Path) -> dict[str, object]:
    value = json.loads(path.read_text(encoding="utf-8"))
    if value.get("schemaVersion") != SCHEMA:
        raise RuntimeError(f"Unsupported publication manifest: {value.get('schemaVersion')}")
    return value


def save(path: pathlib.Path, value: dict[str, object]) -> None:
    path.write_text(json.dumps(value, indent=2, sort_keys=True) + "\n", encoding="utf-8")


def assert_identity(manifest: dict[str, object]) -> None:
    repo = pathlib.Path(str(manifest["repositoryRoot"]))
    commit, dirty = git_identity(repo)
    if dirty:
        raise RuntimeError("Publication identity check found a dirty worktree")
    if commit != manifest["git"]["commit"]:  # type: ignore[index]
        raise RuntimeError("Git commit changed during the publication run")
    if fingerprint(repo / "src", ".java") != manifest["source"]:
        raise RuntimeError("Java source identity changed during the publication run")
    jar = pathlib.Path(str(manifest["experimentJar"]["path"]))  # type: ignore[index]
    if not jar.is_file() or sha256_file(jar) != manifest["experimentJar"]["sha256"]:  # type: ignore[index]
        raise RuntimeError("Frozen experiment JAR changed during the publication run")
    if dependencies(repo) != manifest["dependencies"]:
        raise RuntimeError("Dependency identity changed during the publication run")
    dataset = pathlib.Path(str(manifest["dataset"]["root"]))  # type: ignore[index]
    if fingerprint(dataset, ".als") != {
        key: manifest["dataset"][key]  # type: ignore[index]
        for key in ("sha256", "fileCount", "byteCount")
    }:
        raise RuntimeError("Dataset identity changed during the publication run")
    commands = pathlib.Path(str(manifest["commands"]["path"]))  # type: ignore[index]
    if not commands.is_file() or sha256_file(commands) != manifest["commands"]["sha256"]:  # type: ignore[index]
        raise RuntimeError("Publication command plan changed during the run")
    if canonical_hash(identity_payload(manifest)) != manifest["identitySha256"]:
        raise RuntimeError("Publication manifest identity payload is inconsistent")


def output_entries(root: pathlib.Path, exclude: set[pathlib.Path] | None = None) -> list[dict[str, object]]:
    excluded = {path.resolve() for path in (exclude or set())}
    entries = []
    for path in sorted(candidate for candidate in root.rglob("*") if candidate.is_file()):
        if path.resolve() in excluded:
            continue
        entries.append({
            "path": path.relative_to(root).as_posix(),
            "sizeBytes": path.stat().st_size,
            "sha256": sha256_file(path),
        })
    return entries


def verify_entries(root: pathlib.Path, entries: list[dict[str, object]], exact: bool) -> None:
    expected = {str(entry["path"]): entry for entry in entries}
    actual_paths = {
        path.relative_to(root).as_posix()
        for path in root.rglob("*") if path.is_file()
    }
    if exact and actual_paths != set(expected):
        raise RuntimeError(
            f"Generated output set drifted under {root}: "
            f"missing={sorted(set(expected) - actual_paths)} "
            f"unexpected={sorted(actual_paths - set(expected))}"
        )
    for relative, entry in expected.items():
        path = root / relative
        if not path.is_file():
            raise RuntimeError(f"Missing generated output {path}")
        if path.stat().st_size != entry["sizeBytes"] or sha256_file(path) != entry["sha256"]:
            raise RuntimeError(f"Generated output hash drifted: {path}")


def create(args: argparse.Namespace) -> None:
    repo = pathlib.Path(args.repo).resolve()
    dataset = pathlib.Path(args.dataset).resolve()
    jar = pathlib.Path(args.jar).resolve()
    commands = pathlib.Path(args.commands).resolve()
    manifest_path = pathlib.Path(args.manifest).resolve()
    commit, dirty = git_identity(repo)
    if dirty:
        raise RuntimeError("Publication runs require a clean Git worktree")
    if not jar.is_file() or not commands.is_file():
        raise RuntimeError("Frozen JAR and command plan must exist before manifest creation")
    dataset_fp = fingerprint(dataset, ".als")
    value: dict[str, object] = {
        "schemaVersion": SCHEMA,
        "runId": str(uuid.uuid4()),
        "repositoryRoot": str(repo),
        "git": {"commit": commit, "dirty": False},
        "source": fingerprint(repo / "src", ".java"),
        "experimentJar": {
            "path": str(jar),
            "sizeBytes": jar.stat().st_size,
            "sha256": sha256_file(jar),
        },
        "dependencies": dependencies(repo),
        "dataset": {"root": str(dataset), **dataset_fp},
        "configuration": {
            "workers": args.workers,
            "heap": args.heap,
            "seed": args.seed,
            "capabilityTarget": args.capability_target,
            "limit": args.limit,
            "rewardPool": args.reward_pool,
        },
        "commands": {
            "path": str(commands),
            "sha256": sha256_file(commands),
        },
        "runtime": {
            "java": run("java", "-version"),
            "python": sys.version.splitlines()[0],
            "host": socket.gethostname(),
            "cpu": platform.processor() or platform.machine(),
            "logicalProcessors": os.cpu_count() or 1,
            "platform": platform.platform(),
        },
        "startedAt": utc_now(),
        "status": "running",
        "stages": [],
        "reportBindings": [],
    }
    value["identitySha256"] = canonical_hash(identity_payload(value))
    manifest_path.parent.mkdir(parents=True, exist_ok=True)
    save(manifest_path, value)


def check(args: argparse.Namespace) -> None:
    path = pathlib.Path(args.manifest).resolve()
    manifest = load(path)
    assert_identity(manifest)
    for stage in manifest.get("stages", []):
        verify_entries(pathlib.Path(stage["root"]), stage["outputs"], True)
    for binding in manifest.get("reportBindings", []):
        report = pathlib.Path(binding["report"])
        if sha256_file(report) != binding["reportSha256"]:
            raise RuntimeError(f"Generated report drifted: {report}")
        for source in binding["sources"]:
            if sha256_file(pathlib.Path(source["path"])) != source["sha256"]:
                raise RuntimeError(f"Generated report source drifted: {source['path']}")
    semantic = manifest.get("semanticChecker")
    if semantic:
        if semantic["runIdentitySha256"] != manifest["identitySha256"]:
            raise RuntimeError("Semantic checker is bound to another run identity")
        for category in ("pairs", "outputs"):
            for entry in semantic[category]:
                if sha256_file(pathlib.Path(entry["path"])) != entry["sha256"]:
                    raise RuntimeError(f"Semantic checker binding drifted: {entry['path']}")
        for key in ("checkerSource", "checkerBuild"):
            entry = semantic[key]
            if sha256_file(pathlib.Path(entry["path"])) != entry["sha256"]:
                raise RuntimeError(f"Semantic checker {key} drifted")
    if args.require_complete:
        if manifest.get("status") != "complete":
            raise RuntimeError("Publication manifest is not complete")
        run_root = path.parent
        expected = {entry["path"] for entry in manifest["artifacts"]}
        actual = {
            candidate.relative_to(run_root).as_posix()
            for candidate in run_root.rglob("*")
            if candidate.is_file() and candidate.resolve() != path
        }
        if actual != expected:
            raise RuntimeError(
                f"Top-level generated output set drifted: "
                f"missing={sorted(expected - actual)} unexpected={sorted(actual - expected)}"
            )
        verify_entries(run_root, manifest["artifacts"], False)


def record_stage(args: argparse.Namespace) -> None:
    path = pathlib.Path(args.manifest).resolve()
    manifest = load(path)
    assert_identity(manifest)
    root = pathlib.Path(args.root).resolve()
    outputs = output_entries(root)
    if not outputs:
        raise RuntimeError(f"Stage {args.name} produced no files")
    stages = [stage for stage in manifest["stages"] if stage["name"] != args.name]
    stages.append({
        "name": args.name,
        "root": str(root),
        "command": args.command,
        "commandSha256": hashlib.sha256(args.command.encode("utf-8")).hexdigest(),
        "recordedAt": utc_now(),
        "outputs": outputs,
    })
    manifest["stages"] = stages
    save(path, manifest)


def bind_semantic(args: argparse.Namespace) -> None:
    path = pathlib.Path(args.manifest).resolve()
    manifest = load(path)
    assert_identity(manifest)
    results = pathlib.Path(args.results).resolve()
    pair_files = sorted(results.glob("*/pairs.csv"))
    output_files = [
        results / "semantic_soundness.json",
        results / "semantic_counterexamples.csv",
        results / "semantic_soundness.md",
    ]
    if not pair_files or not all(item.is_file() for item in output_files):
        raise RuntimeError("Semantic checker binding is missing pairs or checker outputs")
    source = pathlib.Path(args.checker_source).resolve()
    jar = pathlib.Path(manifest["experimentJar"]["path"])
    manifest["semanticChecker"] = {
        "runIdentitySha256": manifest["identitySha256"],
        "datasetSha256": manifest["dataset"]["sha256"],
        "pairs": [{"path": str(item), "sha256": sha256_file(item)} for item in pair_files],
        "outputs": [{"path": str(item), "sha256": sha256_file(item)} for item in output_files],
        "checkerSource": {"path": str(source), "sha256": sha256_file(source)},
        "checkerBuild": {"path": str(jar), "sha256": sha256_file(jar)},
    }
    save(path, manifest)


def bind_report(args: argparse.Namespace) -> None:
    path = pathlib.Path(args.manifest).resolve()
    manifest = load(path)
    assert_identity(manifest)
    report = pathlib.Path(args.report).resolve()
    sources = [pathlib.Path(source).resolve() for source in args.source]
    binding = {
        "report": str(report),
        "reportSha256": sha256_file(report),
        "sources": [{"path": str(source), "sha256": sha256_file(source)} for source in sources],
    }
    bindings = [entry for entry in manifest["reportBindings"] if entry["report"] != str(report)]
    bindings.append(binding)
    manifest["reportBindings"] = bindings
    save(path, manifest)


def finalize(args: argparse.Namespace) -> None:
    path = pathlib.Path(args.manifest).resolve()
    manifest = load(path)
    assert_identity(manifest)
    manifest["status"] = "complete"
    manifest["completedAt"] = utc_now()
    manifest["artifacts"] = output_entries(path.parent, {path})
    save(path, manifest)
    check(argparse.Namespace(manifest=str(path), require_complete=True))


def parser() -> argparse.ArgumentParser:
    root = argparse.ArgumentParser()
    sub = root.add_subparsers(dest="command", required=True)
    make = sub.add_parser("create")
    make.add_argument("--repo", required=True)
    make.add_argument("--dataset", required=True)
    make.add_argument("--jar", required=True)
    make.add_argument("--commands", required=True)
    make.add_argument("--manifest", required=True)
    make.add_argument("--workers", type=int, required=True)
    make.add_argument("--heap", required=True)
    make.add_argument("--seed", type=int, required=True)
    make.add_argument("--capability-target", type=int, required=True)
    make.add_argument("--limit", type=int, default=0)
    make.add_argument("--reward-pool", type=int, default=0)
    make.set_defaults(handler=create)

    verify = sub.add_parser("verify")
    verify.add_argument("--manifest", required=True)
    verify.add_argument("--require-complete", action="store_true")
    verify.set_defaults(handler=check)

    stage = sub.add_parser("record-stage")
    stage.add_argument("--manifest", required=True)
    stage.add_argument("--name", required=True)
    stage.add_argument("--root", required=True)
    stage.add_argument("--command", required=True)
    stage.set_defaults(handler=record_stage)

    semantic = sub.add_parser("bind-semantic")
    semantic.add_argument("--manifest", required=True)
    semantic.add_argument("--results", required=True)
    semantic.add_argument("--checker-source", required=True)
    semantic.set_defaults(handler=bind_semantic)

    report = sub.add_parser("bind-report")
    report.add_argument("--manifest", required=True)
    report.add_argument("--report", required=True)
    report.add_argument("--source", action="append", required=True)
    report.set_defaults(handler=bind_report)

    done = sub.add_parser("finalize")
    done.add_argument("--manifest", required=True)
    done.set_defaults(handler=finalize)
    return root


if __name__ == "__main__":
    try:
        arguments = parser().parse_args()
        arguments.handler(arguments)
    except (OSError, RuntimeError, subprocess.CalledProcessError, KeyError, ValueError) as error:
        print(f"publication manifest error: {error}", file=sys.stderr)
        raise SystemExit(1)
