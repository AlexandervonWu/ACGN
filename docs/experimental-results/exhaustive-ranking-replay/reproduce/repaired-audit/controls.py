"""Replay all historically retained reverse rank edges and bind forward cohorts to the exhaustive candidate ledger."""
import argparse,collections,csv,gzip,hashlib,itertools,json,subprocess,sys,tempfile
from pathlib import Path
from registry import inspect,select
from verify_results import check_native,check_incident
from verify_inputs import atomic,check,sha,jsonfile
from verify_compact import PUBLISHED,source_hashes

ARCHIVE={
    'native-reference-inputs.tsv.gz':'23483b5dc59418ec0e42c3ee7d2485afcd1b033a2c66c90d9249192abc1bb0d4',
    'paid-rank-witnesses-measured.jsonl':'5af1b5fe83317ddeadea6ca2e2c108ff1c361002588d4896a69185427749a010',
    'stratified-native-traces.jsonl.gz':'0a6dce5330d84bb3870a39621803946619efc81a26b697bde8e6f84c574a61fb',
    'paid-rank-witnesses-replays.jsonl':'07b8865b038ffcfbcf80fbdd5944145f959b18ab474fe59a09284c06d4073ad4',
}
def inventory(frozen):
    base=frozen/'docs/experimental-results/historical-retention'
    for name,h in ARCHIVE.items():check(sha(base/name)==h,'Changed published retention inventory: '+name)
    groups=collections.defaultdict(set)
    with gzip.open(base/'native-reference-inputs.tsv.gz','rt') as f:
        for l in f:
            role,*values=l.rstrip('\n').split('\t')
            if role in ('paid','both','reverse'):groups[role].add(tuple(values))
    with (base/'paid-rank-witnesses-measured.jsonl').open() as f:
        for r in map(json.loads,f):
            forward=tuple(str(r[k]) for k in ('submission','predicate','sourceSha256','reference','referencePredicate','referenceSha256','expected'))
            groups['ratchet-forward'].add(forward)
            groups['ratchet-reverse'].add(forward[3:6]+forward[:3]+forward[6:])
    with gzip.open(base/'stratified-native-traces.jsonl.gz','rt') as f:
        for r in map(json.loads,f):
            check(r['verifiedStatus']=='MATCHED' and r['verifiedReason']=='CHECKED_NATIVE_ACTIONS_EQUAL','Unsupported historical stratified witness')
            groups['stratified'].add(tuple(str(r[k]) for k in ('left','leftPredicate','leftSourceHash','right','rightPredicate','rightSourceHash','expected')))
    check({g:len(v) for g,v in groups.items()}==dict(paid=4138,both=3,reverse=3,**{'ratchet-forward':83,'ratchet-reverse':83,'stratified':181}),'Wrong historical native control inventory')
    check(groups['both']<=groups['paid'] and groups['ratchet-forward']<=groups['paid'],'Unexpected forward inclusion')
    return groups
def reverse(w,execute):
    meta,ident=inspect(w,plans=False);identity,engine,_=select(w/'runner-identity.json');floor=inventory(w/'original-inputs')
    protected=sorted(floor['reverse']|floor['ratchet-reverse']);check(len(protected)==86,'Reverse controls lost')
    t=w/'independent-reverse';shard='historical-reverse';actual=t/'results/inflight'/(shard+'.jsonl')
    if execute:
        t.mkdir(exist_ok=False);(t/'results/incidents').mkdir(parents=True);(t/'results/inflight').mkdir()
        catalog=source_hashes(w/'original-inputs',meta['dataset'])
        for c in protected:check(catalog[c[0]]==c[2] and catalog[c[3]]==c[5],'Wrong reverse original source')
        with (t/'jobs.tsv').open('x') as f:
            for i,c in enumerate(protected):f.write('\t'.join(('paid',*c,str(i)))+'\n')
        atomic(t/'contract.json',dict(candidateIdentitySha256=identity,candidateCommit=engine['commit'],candidateJarSha256=engine['jar'],originalInventories=ARCHIVE,expandedInputsSha256=sha(t/'jobs.tsv'),rows=86,checkerSha256=sha(Path(__file__))))
        cmd=['nice','-n','14','taskset','-c','31','java','-Xmx400m','-XX:+UseSerialGC','-XX:ActiveProcessorCount=1','-Dorg.slf4j.simpleLogger.defaultLogLevel=warn','-cp',str(w/'runner-classes')+':'+str(w/'engine/candidate.jar')+':'+str(w/'original-inputs/lib/*'),'is.fivefivefive.CanDis.ExhaustiveNativeReplay',str(w/'original-inputs/classified-data'),str(t/'results'),'6']
        result=subprocess.run(cmd,input=f'{shard}\t{t}/jobs.tsv\t0\n',text=True,capture_output=True)
        (t/'stdout.log').write_text(result.stdout);(t/'stderr.log').write_text(result.stderr)
        check(result.returncode==0 and json.loads(result.stdout)['rows']==len(protected),'Candidate reverse worker failed')
    rec=jsonfile(t/'contract.json');check(rec['candidateIdentitySha256']==identity and rec['expandedInputsSha256']==sha(t/'jobs.tsv') and rec['checkerSha256']==sha(Path(__file__)), 'Changed reverse controls or verifier')
    status=collections.Counter();floorwise=collections.Counter()
    with actual.open() as out,(t/'jobs.tsv').open() as spec:
        for i,(c,line,job) in enumerate(itertools.zip_longest(protected,out,spec)):
            check(c is not None and line and job and job=='\t'.join(('paid',*c,str(i)))+'\n','Missing/unbound reverse inputs or observations')
            r=json.loads(line);check(r['ordinal']==i and (r['left'],r['leftPredicate'],r['right'],r['rightPredicate'],r['expected'])==(c[0],c[1],c[3],c[4],int(c[6])),'Foreign reverse native observation')
            ok=check_native(r,int(c[6]));check(r['checked'] is ok,'Reverse native checker disagreement')
            if not ok:check_incident(t,shard,i,['paid',*c],r)
            state='MATCHED' if ok else 'UNBOUND_MATCH' if r['status']=='MATCHED' else r['status'];status[state]+=1
            for name in ('reverse','ratchet-reverse'):
                if c in floor[name]:floorwise[(name,state)]+=1
    verdict=dict(status='VERIFIED' if status=={'MATCHED':86} else 'BLOCKED',directions=86,native=dict(status),cohorts={g:{state:cnt for (n,state),cnt in floorwise.items() if n==g} for g in ('reverse','ratchet-reverse')},candidateIdentitySha256=identity,candidateJarSha256=engine['jar'],originalBoundCostsChecked=True,commitmentReceiptSha256=sha(actual),inputRegistrationSha256=sha(t/'contract.json'))
    atomic(t/'receipt.json',verdict);return verdict
def forwards(archive,w):
    identity,engine,spec=select(w/'runner-identity.json');groups=inventory(w/'original-inputs');names=('both','paid','ratchet-forward','stratified')
    demandref=w/'original-inputs'/PUBLISHED['references'][0]
    check(sha(demandref)==PUBLISHED['references'][1],'Changed native reference source selections')
    with gzip.open(demandref,'rt') as f:refs={(r['source'],r['operator'],r['sha']):r['id'] for r in map(json.loads,f)}
    jobs=collections.defaultdict(dict)
    for name in names:
        for p,pr,h,q,qr,qh,cost in groups[name]: jobs[p].setdefault(refs[q,qr,qh],set()).add(name)
    summary=jsonfile(archive/'summary.json');check(summary['producerIdentitySha256']==identity and summary['complete'] is True,'Unregistered or incomplete candidate archive')
    seen=set();counts=collections.Counter()
    for chunk in summary['chunks']:
        path=archive/chunk['path'];check(sha(path)==chunk['sha256'],'Changed native ranking commitment file')
        with gzip.open(path,'rt') as f:
            for p,entries in map(json.loads,f):
                if p not in jobs:continue
                for v in entries:
                    i=v[0]
                    if i not in jobs[p]:continue
                    check((p,i) not in seen,'Repeated protected forward comparison');seen.add((p,i));state='MATCHED' if v[1] in ('F','T') else 'NONCONFORMING'
                    for name in jobs[p][i]:counts[name,state]+=1
    check(len(seen)==sum(map(len,jobs.values())) and all(sum(v for (n,_),v in counts.items() if n==g)==len(groups[g]) for g in names),'Missing protected forward identities')
    return dict(status='VERIFIED' if all(s=='MATCHED' for _,s in counts) else 'BLOCKED',distinct=len(seen),counts={n:{s:v for (g,s),v in counts.items() if g==n} for n in names},sourceSummarySha256=sha(archive/'summary.json'))
if __name__=='__main__':
    a=argparse.ArgumentParser(description=__doc__);a.add_argument('workspace',type=Path);a.add_argument('--run-reverse',action='store_true');a.add_argument('--forward-archive',type=Path);ns=a.parse_args()
    print(json.dumps(forwards(ns.forward_archive,ns.workspace.resolve()) if ns.forward_archive else reverse(ns.workspace.resolve(),ns.run_reverse),sort_keys=True))
