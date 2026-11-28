"""Validate each completed native shard once and publish incremental evidence outside the measured tree."""
import argparse
from collections import Counter, defaultdict
from datetime import datetime,timezone
import json
from pathlib import Path
import time

from verify_inputs import atomic, jsonfile,sha
from verify_results import native_rows,registration

def watch(root,delay,once):
    meta,identity=registration(root)
    work=root/'cohort/checkpoints';work.mkdir(exist_ok=True)
    selected={s['id']:s for s in meta['shards']}
    checker=sha(Path(__file__).with_name('verify_results.py'))
    program=sha(Path(__file__).with_name('native_commitment.py'))
    cache={}
    while True:
        done={p.name.removesuffix('.receipt.json'):p for p in (root/'results').glob('shard-*.receipt.json')}
        if set(done)-set(selected):raise ValueError('Unknown completed native shard')
        if set(cache)-set(done):raise ValueError('A completed shard receipt was removed')
        for shard,p in sorted(done.items()):
            st=p.stat()
            stamp=st.st_ino,st.st_size,st.st_mtime_ns
            if shard in cache and cache[shard][0]==stamp:continue
            receipt_sha=sha(p);checkpoint=work/(shard+'.json');rec=jsonfile(checkpoint) if checkpoint.is_file() else None
            if rec is None or (rec['receiptSha256'],rec['checkerSha256'],rec['programCheckerSha256'])!=(receipt_sha,checker,program):
                raw=jsonfile(p);modes=Counter();failed=Counter()
                for _,row,state in native_rows(root,selected[shard],raw):
                    if state=='MATCHED':modes[row['sequenceKind']]+=1
                    else:failed[state,row['reason']]+=1
                rec={'shard':shard,'receiptSha256':receipt_sha,'inputSha256':raw['inputSha256'],'resultSha256':raw['outputSha256'],'checkerSha256':checker,'programCheckerSha256':program,'rows':raw['rows'],'checkedModes':dict(modes),'failures':[{'status':s,'reason':r,'count':n} for (s,r),n in sorted(failed.items())]}
                atomic(checkpoint,rec)
            cache[shard]=(stamp,rec)
        counts=Counter();fail=Counter()
        for _,entry in cache.values():
            counts.update(entry['checkedModes'])
            for row in entry['failures']:fail[row['status'],row['reason']]+=row['count']
        data={'completedShardsChecked':len(cache),'requiredShards':len(selected),'rows':sum(counts.values())+sum(fail.values()),'modes':dict(counts),
              'nonconforming':sum(fail.values()),'failures':[{'status':s,'reason':r,'count':n} for (s,r),n in sorted(fail.items())],
              'updated':datetime.now(timezone.utc).isoformat(),'runnerIdentitySha256':sha(root/'runner-identity.json'),'rawCheckerSha256':checker,
              'status':'INFRASTRUCTURE_FAILURE' if any(s=='WORKER_ERROR' for s,_ in fail) else 'BLOCKED' if fail else 'CHECKPOINT'}
        atomic(work/'progress.json',data)
        if once or len(cache)==len(selected):
            print(json.dumps(data,sort_keys=True),flush=True);return
        time.sleep(delay)
if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--workspace',type=Path,default=Path(__file__).resolve().parent.parent)
    p.add_argument('--once',action='store_true');p.add_argument('--delay',type=float,default=30)
    args=p.parse_args();watch(args.workspace,args.delay,args.once)
