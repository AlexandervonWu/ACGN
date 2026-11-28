"""Independently reconstruct the full paid cohort and check every source, reference identity, and expected score."""
import argparse,bisect,collections,csv,gzip,hashlib,json,sys
from array import array
from pathlib import Path
pub=Path('docs/experimental-results/historical-retention')
refs_file=Path('docs/experimental-results/2026-11-25/references.jsonl.gz')

def check(condition,message):
    if not condition:raise ValueError(message)
def sha(path):
    with path.open('rb') as f:
        h=hashlib.sha256()
        for block in iter(lambda:f.read(1048576),b''):h.update(block)
    return h.hexdigest()
def jrows(path):
    with gzip.open(path,'rt') as f:yield from map(json.loads,f)
def tsv(path):
    with path.open(newline='') as f: yield from csv.DictReader(f,delimiter='\t')
def jsonfile(path):
    return json.loads(path.read_bytes())
def atomic(path,obj):
    tmp=path.with_suffix(path.suffix+'.tmp');tmp.write_text(json.dumps(obj,indent=2,sort_keys=True)+'\n');tmp.replace(path)
def verify(workspace,cohort):
    frozen=workspace/'frozen';meta=jsonfile(cohort/'manifest.json');contract=jsonfile(workspace/'closure-contract.json')
    check(meta['schema']=='acgn-exhaustive-paid-ranking-inputs-v1' and contract['schema']=='all-ranking-native-replay-v1','Unknown cohort/closure contract')
    baseline=frozen/pub
    run=jsonfile(baseline/'run-receipt.json')
    check(run['status']=='complete' and run['fullManifestVerified'] is True,'Incomplete published run')
    check(meta['measuredCommit']==contract['producerRevision']==run['git']['commit'] and not run['git']['dirty'],'Engine revision mismatch')
    check(meta['measuredRunId']==contract['producerRun']==run['runId'] and run['identitySha256']==contract['producerIdentity'],'Published identity mismatch')
    check(meta['releaseCommit']==contract['inputEdition'],'Wrong evidence commit')
    check(sha(frozen/'measured.jar')==run['experimentJar']['sha256']==contract['measuredJarSha256']==meta['jarSha256'],'Measured jar SHA mismatch')
    for k,v in contract['inputs'].items():check(sha(frozen/k)==v,'Frozen closure input changed: '+k)
    required={str(pub/x) for x in ('run-receipt.json','headlines.json','ranking-score-parity.json','paired-comparisons.jsonl.gz','ranking-scores.jsonl.gz','nearest-distances.csv.gz')}|{str(refs_file)}
    check(set(meta['upstream'])==required,'Unexpected cohort source evidence')
    for k,d in meta['upstream'].items():
        data=(frozen/k).read_bytes()
        check(hashlib.sha256(data).hexdigest()==d['sha256'] and hashlib.sha1(b'blob '+str(len(data)).encode()+b'\0'+data).hexdigest()==d['gitBlob'],'Incorrect published input: '+k)
    for k,d in meta['supportingFiles'].items():check(sha(cohort/k)==d,'Mismatched generated catalog: '+k)
    check(sha(cohort/'build_inputs.py')==meta['generatorSha256'],'Generator drift')
    for dep in run['dependencies']:
        check(sha(frozen/dep['path'])==dep['sha256'],'Changed native dependency: '+dep['path'])
    catalog={r['id']:r for r in jrows(frozen/refs_file)}
    cat={int(r['referenceId']):r for r in tsv(cohort/'reference-catalog.tsv')}
    check(len(cat)==len(catalog)==4496 and cat.keys()==catalog.keys(),'Missing catalog entries')
    ids={};groups=collections.defaultdict(set)
    for i,ref in catalog.items():
        actual=(ref['source'],ref['operator'])
        check(actual not in ids,'Duplicate original reference predicate');ids[actual]=i;groups[tuple(ref['group'])].add(i)
        generated=cat[i]
        check([generated[k] for k in ('questionSet','invariantId','name','kind','source','predicate','sourceSha256')]==[*ref['group'],ref['name'],ref['kind'],*actual,ref['sha']],'Catalog selector mismatch')
    paired={r['path']:(r['left'],r['right'],r['status']) for r in jrows(baseline/'paired-comparisons.jsonl.gz')}
    students={p for p,v in paired.items() if v[2]!='CORRECT'}
    originals={r['source']:r for r in tsv(cohort/'source-catalog.tsv')}
    check(set(originals)==students|{r['source'] for r in catalog.values()},'Original source cohort differs')
    computed=hashlib.sha256();size=0;filecount=0
    data=frozen/'classified-data'
    for f in sorted(data.rglob('*.als')):
        content=f.read_bytes();p=f.relative_to(data).as_posix();computed.update(p.encode()+b'\0'+content+b'\xff');filecount+=1;size+=len(content)
        if p not in originals: continue
        r=originals[p]
        check((r['studentPredicate'],r['oraclePredicate'],r['status'])==paired[p] and r['sourceSha256']==hashlib.sha256(content).hexdigest() and r['gitBlob']==hashlib.sha1(b'blob '+str(len(content)).encode()+b'\0'+content).hexdigest(),'Original source or predicate drift: '+p)
    check((filecount,size,computed.hexdigest())==(66080,run['dataset']['byteCount'],run['dataset']['sha256']),'Original dataset does not match measured corpus')
    for r in catalog.values():check(originals[r['source']]['sourceSha256']==r['sha'] and paired[r['source']][int(r['kind']=='oracle')]==r['operator'],'Published reference is not from its original source')
    with gzip.open(baseline/'nearest-distances.csv.gz','rt',newline='') as f:nearest={r['path']:(int(r['canonicalDistance']),int(r['legacyCanonicalDistance'])) for r in csv.DictReader(f)}
    expected={};excluded=set();upstream_pairs=0
    for path,refids,fast,cert in jrows(baseline/'ranking-scores.jsonl.gz'):
        check(path not in expected and path in students,'Unexpected or duplicate ranked source')
        group=path.split('/')[0],paired[path][0]
        check(refids==sorted(set(refids)) and set(refids)<=groups[group] and len(refids)==len(fast)==len(cert) and refids,'Invalid reference selection')
        check(fast==cert and all(type(x)==int and x>0 for x in fast) and nearest[path]==(min(cert),min(fast)),'Native score disagreement in published comparison')
        excluded.update((path,i) for i in groups[group]-set(refids))
        expected[path]=(array('H',refids),array('I',fast),bytearray(len(refids)))
        upstream_pairs+=len(refids)
    check(set(expected)==set(nearest)==students and len(expected)==42386 and upstream_pairs==1894168,'Published comparison cohort mismatch')
    observed_exclusions={(r['source'],r['referenceId']) for r in jsonfile(cohort/'ast-identical-exclusions.json')}
    check(excluded==observed_exclusions and len(excluded)==21,'Incorrect excluded leaf identities')
    allhash=hashlib.sha256();total=0;seen_sources=set()
    shard_paths={cohort/s['path'] for s in meta['shards']}
    check(len(shard_paths)==len(meta['shards']) and shard_paths==set((cohort/'jobs').glob('*.tsv')),'Missing or extra shard file')
    for number,s in enumerate(meta['shards']):
        i=f'shard-{number:04d}';check(s['id']==i and s['path']==f'jobs/{i}.tsv','Unexpected shard identity')
        digest=hashlib.sha256();count=0;subset=set();cost_sum=0;max_cost=0
        with (cohort/s['path']).open('rb') as f:
            for raw in f:
                check(raw.endswith(b'\n'),'Unterminated job');allhash.update(raw);digest.update(raw);cells=raw[:-1].decode().split('\t')
                check(len(cells)==8 and cells[0]=='paid','Malformed or reversed job')
                _,p,left,lh,right,pred,rh,score=cells;idx=ids.get((right,pred))
                check(p in students and idx is not None and tuple(s['pool'])==tuple(catalog[idx]['group'])==(p.split('/')[0],left),'Unexpected ranking identity or pool')
                check((left,lh)==(paired[p][0],originals[p]['sourceSha256']) and rh==catalog[idx]['sha'],'Mismatched original selector or source hash')
                refids,values,bitmap=expected[p];at=bisect.bisect_left(refids,idx)
                check(at<len(refids) and refids[at]==idx and not bitmap[at] and str(values[at])==score,'Unexpected, duplicated, or wrong-score job')
                bitmap[at]=1;count+=1;cost_sum+=values[at];max_cost=max(max_cost,values[at]);subset.add(p)
        check(not seen_sources.intersection(subset),'Source split across shards');seen_sources.update(subset)
        check((digest.hexdigest(),count,len(subset),cost_sum,max_cost)==(s['sha256'],s['rows'],s['submissions'],s['expectedScoreSum'],s['expectedScoreMax']) and 0<count<=2048,'Wrong shard binding: '+i)
        total+=count
    check(all(all(bitmap) for _,_,bitmap in expected.values()) and seen_sources==students and total==upstream_pairs==meta['rows']==contract['targetPopulation'],'Missing independently expected jobs')
    check(allhash.hexdigest()==meta['combinedInputsSha256'],'Aggregate input hash mismatch')
    return dict(status='VERIFIED',scope='INPUT_COHORT',releaseCommit=meta['releaseCommit'],engineCommit=meta['measuredCommit'],originallyMeasuredRun=run['runId'],measuredJarSha256=meta['jarSha256'],
                rows=total,submittedPaths=len(seen_sources),references=len(ids),pools=len(groups),alloyFilesCount=filecount,verifiedOriginalSources=len(originals),astIdenticalExclusions=len(excluded),
                shards=len(meta['shards']),combinedInputsSha256=allhash.hexdigest(),manifestSha256=sha(cohort/'manifest.json'),closureContractSha256=sha(workspace/'closure-contract.json'),checkerSha256=sha(Path(__file__).resolve()))
if __name__=='__main__':
    ap=argparse.ArgumentParser(description=__doc__);ap.add_argument('--workspace',type=Path,default=Path(__file__).resolve().parent.parent);o=ap.parse_args()
    try:
        result=verify(o.workspace,o.workspace/'cohort');atomic(o.workspace/'cohort/input-recount.json',result);print(json.dumps(result,sort_keys=True))
    except Exception as e:
        print(f'INFRASTRUCTURE_FAILURE: {e}',file=sys.stderr);raise
