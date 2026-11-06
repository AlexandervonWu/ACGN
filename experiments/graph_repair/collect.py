"""Export complete paired canonical graphs without a one-step action menu."""
import argparse
import collections
from concurrent.futures import ThreadPoolExecutor
import hashlib
import json
from pathlib import Path
import subprocess
import time

from experiments.hybrid_edit.corpus import ROOT, write, digest, split_for
from .codec import encode_pair, identity


def process(path, out, classpath):
    relative = path.relative_to(ROOT).as_posix()
    key = hashlib.sha256(relative.encode()).hexdigest()[:20]
    problem = path.parts[-3].replace('classroom_rl','classroom_fol')
    group = problem + ':' + path.stem.rsplit('_',1)[-1].lower()
    row = {'id':key,'source':relative,'sourceHash':digest(path),'group':group,'split':split_for(group)}
    try:
        rawpath = out/'raw'/f'{key}.json'
        with (out/'logs'/f'{key}.log').open('w') as log:
            result = subprocess.run(['java','-Xmx768m','-cp',classpath,
                'is.fivefivefive.CanDis.CanonicalPairExport',str(path),str(rawpath)],
                cwd=ROOT,stdout=log,stderr=subprocess.STDOUT,timeout=60)
        if result.returncode:
            detail = (out/'logs'/f'{key}.log').read_text()[-2000:]
            row.update(status='EXCLUDED' if 'AST_IDENTICAL' in detail else 'FAILED', reason=detail)
            return row
        raw = json.loads(rawpath.read_text())
        if raw['sourceHash'] != row['sourceHash'] or digest(path) != row['sourceHash']:
            raise RuntimeError('SOURCE_CHANGED')
        packet = encode_pair(raw)
        packet.update({k:row[k] for k in ('id','source','group','split')})
        packet['pairHash'] = hashlib.sha256(identity([packet['key'],packet['target']]).encode()).hexdigest()
        write(out/'records'/f'{key}.json',packet)
        row.update(status='ACCEPTED',keyTokens=len(packet['key']),targetTokens=len(packet['value']),
                   pairHash=packet['pairHash'],packetHash=digest(out/'records'/f'{key}.json'))
    except ValueError as e:
        row.update(status='EXCLUDED' if str(e) in ('TOKEN_BOUND','NUMBER_BOUND') else 'FAILED',reason=str(e))
    except Exception as e:
        row.update(status='FAILED',reason=type(e).__name__+': '+str(e))
    return row


def main():
    p=argparse.ArgumentParser()
    p.add_argument('--output',type=Path,required=True)
    p.add_argument('--classpath',required=True)
    p.add_argument('--attempts',type=int,default=4096)
    p.add_argument('--workers',type=int,default=12)
    p.add_argument('--per-question',type=int,default=200)
    args=p.parse_args(); args.output.mkdir()
    for name in ('raw','logs','records'): (args.output/name).mkdir()
    paths=[x for x in (ROOT/'classified-data').rglob('*.als')
           if x.parent.name.lower() in ('both','over','under','overconstrained','underconstrained')]
    paths.sort(key=lambda x:hashlib.sha256(('graph-path-v1:'+x.relative_to(ROOT).as_posix()).encode()).digest())
    counts=collections.Counter(); selected=[]
    for path in paths:
        group=path.parts[-3].replace('classroom_rl','classroom_fol')+':'+path.stem.rsplit('_',1)[-1].lower()
        if counts[group]<args.per_question:
            selected.append(path); counts[group]+=1
        if len(selected)==args.attempts: break
    write(args.output/'selection.json',{'sources':{x.relative_to(ROOT).as_posix():digest(x) for x in selected},
          'repairabilitySelection':False,'sourceHashes':{str(x.relative_to(ROOT)):digest(x) for x in [
              *ROOT.joinpath('experiments/graph_repair').glob('*.py'),
              ROOT/'src/is/fivefivefive/CanDis/CanonicalPairExport.java',
              ROOT/'docs/canonical-edit-learning/formal/GraphRepair.lean']}})
    ledger=[]; seen=set(); started=time.monotonic()
    with ThreadPoolExecutor(max_workers=args.workers) as pool:
        for start in range(0,len(selected),args.workers):
            futures=[pool.submit(process,x,args.output,args.classpath) for x in selected[start:start+args.workers]]
            for f in futures:
                row=f.result()
                if row['status']=='ACCEPTED':
                    key=row['group'],row['pairHash']
                    if key in seen: row.update(status='EXCLUDED',reason='DUPLICATE_GRAPH_PAIR')
                    seen.add(key)
                ledger.append(row)
            write(args.output/'ledger.json',ledger)
            print(json.dumps({'done':len(ledger),'total':len(selected),
                'statuses':collections.Counter(r['status'] for r in ledger),
                'seconds':time.monotonic()-started}),flush=True)
    write(args.output/'summary.json',{'attempts':len(ledger),'seconds':time.monotonic()-started,
          'statuses':collections.Counter(r['status'] for r in ledger),
          'splits':collections.Counter(r['split'] for r in ledger if r['status']=='ACCEPTED'),
          'exclusions':collections.Counter(r.get('reason','').split('\n')[0] for r in ledger if r['status']=='EXCLUDED')})


if __name__=='__main__': main()
