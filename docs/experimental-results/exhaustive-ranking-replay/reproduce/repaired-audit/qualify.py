"""Calibrate the candidate verifier on real tile/original rows and inject execution-plan mutations."""
import argparse,collections,copy,hashlib,json,tempfile
from pathlib import Path
from registry import inspect,select,verify_plans
from verify_results import check_native
from verify_inputs import atomic,check,sha
def reject(work):
    try:work()
    except ValueError:return
    raise AssertionError('Fault injection incorrectly accepted')
def test(w):
    m,identity=inspect(w,plans=True);dig,registered,_=select(w/'runner-identity.json');cal=w/'independent-order-calibration'
    with (cal/'serial/sample.jsonl').open() as f:serial={r['ordinal']:r for r in map(json.loads,f)}
    with (cal/'tiled/inflight/sample.jsonl').open() as f:tiled={r['ordinal']:r for r in map(json.loads,f)}
    check(serial==tiled and len(serial)==60 and all(check_native(r,r['expected']) for r in serial.values()),'Real contiguous/tiled native status or digest calibration failed')
    row=next(iter(serial.values()))
    for k in ('sourceCertificatesChecked','fixedChoiceReplaysChecked','endpointCorrespondenceChecked','nativeSequencesEqual','fastSequenceSha256','certifiedSequenceSha256','fastDistance','certifiedDistance','reason'):
        changed=dict(row);changed.pop(k);check(not check_native(changed,row['expected']),'Failed native corruption test '+k)
    with tempfile.TemporaryDirectory() as tmp:
        root=Path(tmp);(root/'cohort/jobs').mkdir(parents=True);(root/'plans').mkdir()
        src=m['shards'][0];jobs=(w/'cohort'/src['path']).read_bytes();orig=jobs.splitlines();ids=[(str(i)+'\n').encode() for i in range(len(orig))]
        (root/'cohort'/src['path']).write_bytes(jobs)
        tiny={'shards':[src],'rows':src['rows'],'combinedInputsSha256':src['sha256']}
        plan=root/'plans'/(src['id']+'.tsv')
        def write(lines):
            plan.write_bytes(b''.join(lines));atomic(root/'plans/manifest.json',{src['id']:sha(plan)})
            return {'plan':sha(root/'plans/manifest.json')}
        valid=[line+b'\t'+ids[i] for i,line in enumerate(orig)]
        check(verify_plans(root,tiny,write(reversed(valid)))==len(orig),'Legal permutation rejected')
        for wrong in (valid[1:],[valid[0]]+valid[:-1],[valid[0].replace(b'paid\t',b'zero\t',1)]+valid[1:],[orig[0]+b'\t01\n']+valid[1:]):
            current=write(wrong);reject(lambda:verify_plans(root,tiny,current))
    return {'qualification':'PASS','candidateIdentitySha256':dig,'eligibleOriginalOrdinalsChecked':m['rows'],'executionPlansChecked':len(m['shards']),'calibrationRows':len(tiled),'missingDuplicatedSubstitutedAndNoncanonicalOrdinalRejected':True,'nativeStatusFieldCorruptionRejected':True}
if __name__=='__main__':
    ap=argparse.ArgumentParser();ap.add_argument('workspace',type=Path);args=ap.parse_args();q=test(args.workspace.resolve());atomic(Path(__file__).resolve().parent/'qa/qualification.json',q);print(q)
