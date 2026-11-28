"""The bulk verifier must distinguish equal-cost native divergence on original files."""
import gzip,hashlib,json,subprocess,tempfile
from pathlib import Path

w=Path(__file__).resolve().parent.parent
frozen=w/'frozen'
target=w/'preflight/calibration'
target.mkdir(exist_ok=True)
old=w.parent/'historical-retention-final-d9kv9rre'
old_jar=old/'run/artifacts/build/acgn-experiments.jar'
receipt=json.loads((old/'evidence/run-receipt.json').read_bytes())
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
assert sha(old_jar)==receipt['experimentJar']['sha256']
d=frozen/'docs/experimental-results/historical-retention'
with (d/'paid-rank-witnesses-measured.jsonl').open() as stream:previous=list(map(json.loads,stream))
jobs=(previous[0],next(r for r in previous if r['reference']!=previous[0]['reference']),previous[-1])
rows=['\t'.join(str(r[k]) if k not in ('kind',) else 'paid' for k in ('kind','submission','predicate','sourceSha256','reference','referencePredicate','referenceSha256','expected')) for r in jobs]
with tempfile.TemporaryDirectory(prefix='run-',dir=target) as name:
    case=Path(name);(case/'inputs.tsv').write_text('\n'.join(rows)+'\n')
    summary=[]
    classes=case/'classes';classes.mkdir()
    driver=w/'runner/ExhaustiveNativeReplay.java'
    subprocess.run(['javac','--release','17','-cp',f'{frozen}/measured.jar:{frozen}/lib/*','-d',str(classes),str(driver)],check=True)
    for version,jar,expected in [('before',old_jar,'MISMATCH'),('measured',frozen/'measured.jar','MATCHED')]:
        p=case/version;p.mkdir();(p/'incidents').mkdir()
        cmd=['java','-XX:ActiveProcessorCount=1','-XX:+UseSerialGC','-Xmx650m','-cp',f'{classes}:{jar}:{frozen}/lib/*','is.fivefivefive.CanDis.ExhaustiveNativeReplay',str(frozen/'classified-data'),str(p),'16']
        subprocess.run(cmd,input=f'probe\t{case}/inputs.tsv\t0\n',text=True,stdout=subprocess.PIPE,check=True)
        ledger=list(map(json.loads,(p/'probe.jsonl').read_text().splitlines()))
        assert len(ledger)==len(jobs)
        for i,(r,j) in enumerate(zip(ledger,jobs,strict=True)):
            assert r['left']==j['submission'] and r['right']==j['reference'] and r['status']==expected and r['checked']==(version=='measured')
            assert r['fastDistance']==r['certifiedDistance']==j['expected']
            assert r['fastActionCount']==r['certifiedActionCount']
            assert all(r[k] for k in ['sourceCertificatesChecked','fixedChoiceReplaysChecked','endpointCorrespondenceChecked'])
            if expected=='MISMATCH':
                assert r['firstDifference'] >= 0 and r['fastFirst'] != r['certifiedFirst']
                assert sha(p/r['incidentPath'])==r['incidentSha256']
        summary.append(dict(label=version,jarSha256=sha(jar),rows=[{k:v for k,v in r.items() if k not in ('incidentPath','incidentSha256')} for r in ledger]))
    result=dict(frozenBulkWorkerSha256=sha(driver),jars=summary,checkedCases=len(jobs),passStatus='PASS')
    (target/'result.json').write_text(json.dumps(result,indent=2,sort_keys=True)+'\n')
    print('Native comparator separated all three archived same-distance, same-action-count mismatches from the repaired results.')
