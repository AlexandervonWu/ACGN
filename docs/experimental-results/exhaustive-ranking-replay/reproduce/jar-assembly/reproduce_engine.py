"""Recover a byte-identical measured engine using tracked source, dependencies, and ZIP entry metadata."""
import argparse
import hashlib
import json
import subprocess
import tempfile
from pathlib import Path

SOURCE = Path(__file__).resolve().parent


def sha(path):
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def main():
    known = json.loads((SOURCE / "engines.json").read_bytes())
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("engine", choices=sorted(known))
    parser.add_argument("output", type=Path, help="unused output JAR path")
    parser.add_argument("--repo", type=Path, default=Path.cwd())
    args = parser.parse_args()
    spec = known[args.engine]
    output = args.output.resolve()
    if output.exists():
        parser.error("output already exists")
    layout = SOURCE / spec["zipEntries"]
    if sha(layout) != spec["zipEntriesSha256"]:
        raise ValueError("changed ZIP entry metadata")
    with tempfile.TemporaryDirectory(dir=output.parent) as temp:
        build = Path(temp)
        with subprocess.Popen(["git", "-C", args.repo, "archive", spec["git"], "src", "lib"],
                              stdout=subprocess.PIPE) as archive:
            subprocess.run(["tar", "-xf", "-", "-C", build], stdin=archive.stdout, check=True)
            archive.stdout.close()
            if archive.wait():
                raise RuntimeError("failed to materialize the exact source commit")
        classes = build / "classes"
        classes.mkdir()
        subprocess.run(["javac", "-J-XX:ActiveProcessorCount=2", "-J-Xmx650m", "--release", "17",
                        "-encoding", "UTF-8", "-cp", str(build / "lib/*"), "-d", classes,
                        *sorted((build / "src").rglob("*.java"))], check=True)
        subprocess.run(["javac", "--release", "17", "-d", build, SOURCE / "ReassembleJar.java"], check=True)
        jar = build / "rebuilt.jar"
        subprocess.run(["java", "-cp", build, "ReassembleJar", layout, classes, jar], check=True)
        actual = sha(jar)
        if actual != spec["sha256"]:
            raise ValueError(f"expected {spec['sha256']}, rebuilt {actual}; measured compiler was {spec['javac']}")
        # Publish atomically without replacing an existing JAR.
        output.hardlink_to(jar)
    print(f"{actual}  {output}")


if __name__ == "__main__":
    main()
