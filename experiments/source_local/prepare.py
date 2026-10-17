"""Restore only hash-pinned producer inputs to a fresh external directory."""
import argparse
import hashlib
import io
import json
from pathlib import Path
import subprocess
import tarfile

ROOT = Path(__file__).resolve().parents[2]
EVIDENCE = ROOT / 'docs/canonical-edit-learning/results/multistep_scaling_20261004'


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def verify(producer):
    manifest = json.loads((EVIDENCE / 'input-hashes.json').read_text())
    for name, expected in manifest.items():
        if sha(producer / name) != expected:
            raise ValueError('PRODUCER_HASH_MISMATCH: ' + name)
    return len(manifest)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('destination', type=Path)
    args = parser.parse_args(); out = args.destination.resolve()
    if out.exists() or ROOT == out or ROOT in out.parents:
        parser.error('Destination must be fresh and outside the checkout')
    hashes = json.loads((EVIDENCE / 'hashes.json').read_text())
    for name in ('evidence.tar.gz', 'input-hashes.json', 'natural-coverage.json'):
        if sha(EVIDENCE / name) != hashes[name]:
            raise ValueError('EVIDENCE_HASH_MISMATCH: ' + name)
    manifest = json.loads((EVIDENCE / 'input-hashes.json').read_text())
    with tarfile.open(EVIDENCE / 'evidence.tar.gz', 'r:gz') as archive:
        frozen = archive.extractfile('frozen-sources.tar.gz').read()
    out.mkdir(parents=True)
    # Extract only named regular files; never archive paths, links or permissions.
    with tarfile.open(fileobj=io.BytesIO(frozen), mode='r:gz') as archive:
        for name, expected in manifest.items():
            if Path(name).is_absolute() or '..' in Path(name).parts:
                raise ValueError('UNSAFE_MANIFEST_PATH')
            if name.startswith('lib/'):
                data = (ROOT / name).read_bytes()
            else:
                member = archive.getmember(name)
                if not member.isfile():
                    raise ValueError('NON_REGULAR_SOURCE')
                data = archive.extractfile(member).read()
            if hashlib.sha256(data).hexdigest() != expected:
                raise ValueError('PRODUCER_HASH_MISMATCH: ' + name)
            path = out / name; path.parent.mkdir(parents=True, exist_ok=True); path.write_bytes(data)
    classes = out / 'classes'; classes.mkdir()
    sources = out / 'sources.args'
    sources.write_text('\n'.join(json.dumps(str(p)) for p in sorted((out/'src').rglob('*.java'))) + '\n')
    cp = ':'.join(str(p) for p in sorted((out/'lib').glob('*.jar')))
    command = ['java', '-m', 'jdk.compiler/com.sun.tools.javac.Main', '--release', '17',
               '-encoding', 'UTF-8', '-cp', cp, '-d', str(classes), '@'+str(sources)]
    with (out/'compile.log').open('w') as log:
        subprocess.run(command, stdout=log, stderr=subprocess.STDOUT, check=True)
    (out/'preparation.json').write_text(json.dumps({'verifiedInputs': verify(out),
        'archiveSha256': hashes['evidence.tar.gz'], 'compileCommand': command}, indent=2)+'\n')
    print(json.dumps({'verifiedInputs': verify(out), 'classes': str(classes)}))


if __name__ == '__main__':
    main()
