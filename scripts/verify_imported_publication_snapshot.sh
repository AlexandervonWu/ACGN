#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MANIFEST=${1:-"$ROOT/publication_runs/57f5a2d8-f501-494d-81d5-b3f1396dbe18/run-manifest.json"}

python3 - "$ROOT" "$MANIFEST" <<'PY'
import hashlib
import json
import sys
from pathlib import Path, PurePosixPath

root = Path(sys.argv[1]).resolve()
manifest_path = Path(sys.argv[2]).resolve()
stage_roots = {
    "distance_results",
    "alloy4fun-augmented",
    "egraph_ablation",
    "capability_benchmark",
}
lfs_header = b"version https://git-lfs.github.com/spec/v1"

try:
    manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
except (OSError, json.JSONDecodeError) as error:
    raise SystemExit(f"cannot read publication manifest {manifest_path}: {error}")

records = []
for artifact in manifest.get("artifacts", []):
    relative = PurePosixPath(artifact.get("path", ""))
    if relative.parts and relative.parts[0] in stage_roots:
        records.append((relative, artifact))

if len(records) != 5808:
    raise SystemExit(
        f"publication manifest selects {len(records)} imported stage files; expected 5808"
    )

expected_paths = {relative.as_posix() for relative, _ in records}
actual_paths = set()
for stage in sorted(stage_roots):
    stage_path = root / stage
    if not stage_path.is_dir():
        raise SystemExit(f"imported stage directory is missing: {stage_path}")
    for path in stage_path.rglob("*"):
        if path.is_file():
            actual_paths.add(path.relative_to(root).as_posix())

missing = sorted(expected_paths - actual_paths)
extra = sorted(actual_paths - expected_paths)
if missing or extra:
    details = []
    if missing:
        details.append("missing=" + ", ".join(missing[:10]))
    if extra:
        details.append("extra=" + ", ".join(extra[:10]))
    raise SystemExit("imported snapshot file set differs from manifest: " + "; ".join(details))

for relative, artifact in records:
    path = root.joinpath(*relative.parts)
    with path.open("rb") as stream:
        prefix = stream.read(200)
        if prefix.startswith(lfs_header):
            raise SystemExit(
                f"Git LFS pointer present instead of required content: {relative}. "
                "Run 'git lfs install' and 'git lfs pull', then retry."
            )
        digest = hashlib.sha256()
        digest.update(prefix)
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(block)
    actual_size = path.stat().st_size
    expected_size = int(artifact["sizeBytes"])
    if actual_size != expected_size:
        raise SystemExit(
            f"size mismatch for {relative}: expected {expected_size}, got {actual_size}"
        )
    actual_digest = digest.hexdigest()
    expected_digest = artifact["sha256"]
    if actual_digest != expected_digest:
        raise SystemExit(
            f"SHA-256 mismatch for {relative}: expected {expected_digest}, "
            f"got {actual_digest}"
        )

print("VERIFIED imported publication snapshot: 5808 files")
PY
