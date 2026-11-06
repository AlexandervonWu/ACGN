"""Publish bounded codec, coverage and provenance evidence; no solver claims."""
import argparse
import collections
import hashlib
import json
from pathlib import Path
import subprocess

from experiments.hybrid_edit.corpus import ROOT, digest, write
from . import codec
from .train import load_records


def main():
    p=argparse.ArgumentParser(); p.add_argument('--data',type=Path,required=True)
    p.add_argument('--output',type=Path,required=True); args=p.parse_args()
    records=load_records(args.data); keys=collections.defaultdict(set); groups={}; key_splits=collections.defaultdict(set)
    for r in records:
        key=hashlib.sha256(codec.identity(r['key']).encode()).hexdigest()
        target=hashlib.sha256(codec.identity(r['target']).encode()).hexdigest()
        keys[(r['group'],key)].add(target)
        key_splits[key].add(r['split'])
        previous=groups.setdefault(r['group'],r['split'])
        if previous!=r['split']: raise ValueError('QUESTION_LEAKAGE')
    if any(len(s)>1 for s in key_splits.values()): raise ValueError('CROSS_SPLIT_INPUT_LEAKAGE')
    sizes={}
    for name,fn in [('keyTokens',lambda r:len(r['key'])),('targetTokens',lambda r:len(r['value'])),
                    ('totalTokens',lambda r:len(r['key'])+len(r['value'])),('sourceDagNodes',lambda r:len(r['nodes']))]:
        values=sorted(map(fn,records))
        sizes[name]={'min':values[0],'median':values[len(values)//2],'p90':values[int(len(values)*.9)],
                     'max':values[-1],'mean':sum(values)/len(values)}
    report={'accepted':len(records),'completeTeacherReplays':len(records),'sourcePrefixRoundTrips':len(records),
        'targetNotUsedByDecoder':'generate() reads key only and reconstructs source tables from it',
        'groups':dict(collections.Counter(groups.values())),
        'splitCounts':dict(collections.Counter(r['split'] for r in records)),
        'problems':dict(collections.Counter(r['group'].split(':')[0] for r in records)),
        'ambiguousKeys':sum(len(v)>1 for v in keys.values()),'sizes':sizes,
        'selectionHash':digest(args.data/'selection.json'),'ledgerHash':digest(args.data/'ledger.json'),
        'javaSourceHashes':{str(f.relative_to(ROOT)):digest(f) for f in (ROOT/'src').rglob('*.java')},
        'libraryHashes':{str(f.relative_to(ROOT)):digest(f) for f in (ROOT/'lib').glob('*.jar')},
        'leanVersion':subprocess.check_output(['lean','--version'],text=True).strip()}
    write(args.output,report)
    print(json.dumps({k:v for k,v in report.items() if k not in ('javaSourceHashes','libraryHashes')},indent=2))


if __name__=='__main__': main()
