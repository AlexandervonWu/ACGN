"""Reconstruct the original student/oracle, reference zero, authenticated command and SAT control inventories."""
import collections,csv,gzip,hashlib,itertools,json,subprocess,sys
from pathlib import Path
p=Path(__file__).resolve().parent;w=p.parent;frozen=w/'frozen'
sys.path.insert(0,str(w/'cohort'))
from verify_compact import COHORT,source_hashes,sha,demand
from verify_inputs import atomic,jsonfile,jrows
release='0ef41a420deb5772e3ce0f709ad2730215b48215'
repo=Path('/home/augustus/.codex/worktrees/v33-release/ACGN')
base=Path('docs/experimental-results/historical-retention');v32=Path('docs/experimental-results/2026-11-25')
def original(name,restore=False):
    path=frozen/name
    data=subprocess.check_output(['git','-C',str(repo),'show',release+':'+str(name)])
    if restore:
        path=p/'upstream'/name.name;path.parent.mkdir(exist_ok=True)
        if not path.exists():path.write_bytes(data)
    demand(path.read_bytes()==data,'Published data mismatch: '+str(name));return path
def encode(v):return (json.dumps(v,sort_keys=True,separators=(',',':'),ensure_ascii=False)+'\n').encode()
def make():
    meta=jsonfile(w/'cohort/manifest.json');demand(sha(w/'cohort/manifest.json')==COHORT,'Changed measured original corpus')
    src=source_hashes(frozen,meta['dataset'])
    names={'paired':base/'paired-comparisons.jsonl.gz','refpairs':base/'correct-pool-pairs.jsonl.gz','catalog':v32/'references.jsonl.gz','slottedPaired':base/'original-slotted-zero-paths.txt','slottedRefs':base/'slotted-reference-pairs.csv.gz','floor':base/'historical-pairs.json.gz','before':v32/'pairs.csv.gz','oldZeroInputs':base/'native-reference-inputs.tsv.gz'}
    files={k:original(v,k=='before') for k,v in names.items()}
    paired={r['path']:r for r in jrows(files['paired'])}
    refs={r['id']:r for r in jrows(files['catalog'])}
    ids={(r['source'],r['name']):i for i,r in refs.items()};scopeids={}
    for _,group in itertools.groupby(sorted(refs.values(),key=lambda r:(r['group'],r['id'])),key=lambda r:r['group']):
        for i,r in enumerate(group):scopeids[r['id']]=i
    sp=set(files['slottedPaired'].read_text().splitlines())
    with gzip.open(files['slottedRefs'],'rt') as f:sr={tuple(sorted((int(r['left']),int(r['right'])))) for r in csv.DictReader(f) if int(r['distance'])==0}
    with gzip.open(files['before'],'rt') as f:sat={tuple(sorted((int(r['left']),int(r['right'])))) for r in csv.DictReader(f) if r['native']=='SAT'}
    with gzip.open(files['floor'],'rt') as f:floor=json.load(f)['claims']
    def ref(i):
        r=refs[i];ps=paired[r['source']];op=r['operator']
        peer=ps['right'] if op==ps['left'] else ps['left']
        demand(r['sha']==src[r['source']] and op in (ps['left'],ps['right']) and peer!=op,'Unexpected source role')
        return [r['source'],op,r['sha'],peer,scopeids[i],i]
    def refkey(record):
        a,b=record['a'],record['b'];return tuple(sorted(((a[0],a[1]),(b[0],b[1]))))
    jobs=collections.defaultdict(list)
    for path,r in sorted(paired.items()):
        cmd=r['decisions']
        jobs['paired'].append(dict(kind='paired',a=[path,r['left'],src[path]],b=[path,r['right'],src[path]],expected=r['distance'],folder=r['status'],slotted=path in sp,commands=cmd))
    oldzero=set()
    with gzip.open(files['oldZeroInputs'],'rt') as f:
        for raw in f:
            kind,lf,lp,lh,rf,rp,rh,cost=raw.rstrip('\n').split('\t')
            if kind=='zero':
                demand(src[lf]==lh and src[rf]==rh and cost=='0','Wrong reference source or scalar')
                oldzero.add(((lf,lp),(rf,rp)))
    zeroids=set();fixedids=set();satids=set()
    for r in jrows(files['refpairs']):
        aa=ids[r['leftSource'],r['left']];bb=ids[r['rightSource'],r['right']]
        ai,bi=sorted((aa,bb));key=ai,bi
        a,b=ref(aa),ref(bb)
        if r['structuralZero']:
            jobs['zero'].append(dict(kind='zero',a=a,b=b,expected=0,slotted=key in sr))
            zeroids.add(key)
        if r['scopeStatus']=='FIXED_COMMAND_RULE' or key in sat:
            kind='fixed' if r['scopeStatus']=='FIXED_COMMAND_RULE' else 'sat-control'
            want={k:r.get(k) for k in ['rules','bitwidth','traceMin','traceMax','carrierBounds','scopeStatus']}
            jobs[kind].append(dict(kind=kind,a=a,b=b,scoped=want,structuralZero=r['structuralZero']))
            (fixedids if kind=='fixed' else satids).add(key)
    demand({refkey(r) for r in jobs['zero']}=={tuple(sorted(x)) for x in oldzero}=={tuple(sorted(((a,b),(c,d)))) for _,_,a,b,c,d in floor['poolStructural']},'Incorrect zero floor')
    demand({refkey(r) for r in jobs['fixed']}=={tuple(sorted(((a,b),(c,d)))) for _,_,a,b,c,d in floor['poolFixedCommand']},'Incorrect fixed-command floor')
    actual_fixed={(r['a'][0],r['a'][1],r['b'][1],d['check'],d['ordinal'],json.dumps({k:d[k] for k in ('bitwidth','traceMin','traceMax','carrierBounds')},sort_keys=True,separators=(',',':'))) for r in jobs['paired'] for d in r['commands'] if d['basis']=='FIXED_COMMAND_RULE'}
    demand(actual_fixed==set(map(tuple,floor['pairedFixedCommand'])) and len(actual_fixed)==347,'Incorrect paired command floor')
    demand({(r['a'][0],r['a'][1],r['b'][1]) for r in jobs['paired'] if r['expected']==0}==set(map(tuple,floor['pairedStructural'])),'Incorrect paired zero floor')
    demand(len(sp)==2228 and sp<={r['a'][0] for r in jobs['paired'] if r['expected']==0} and len(sr)==8952 and sr<=zeroids and sat==satids and not sat&(zeroids|fixedids),'Incorrect original Slotted or negative-control floor')
    totals={k:len(rs) for k,rs in jobs.items()}
    demand(totals==dict(paired=61598,zero=19271,fixed=1234,**{'sat-control':105}),'Incomplete native/scope cohorts')
    out=p/'jobs';out.mkdir(exist_ok=True);shards=[];all_inputs=hashlib.sha256()
    for kind,rows in jobs.items():
        if kind!='paired':rows.sort(key=lambda r:(r['a'][5],r['b'][5]))
        for n,offset in enumerate(range(0,len(rows),256)):
            batch=rows[offset:offset+256];name=f'{kind}-{n:03d}.jsonl';data=b''.join(map(encode,batch));all_inputs.update(data)
            dest=out/name
            if dest.exists(): demand(dest.read_bytes()==data,'Change in frozen supplemental cohort')
            else:dest.write_bytes(data)
            shards.append(dict(path='jobs/'+name,kind=kind,rows=len(batch),sha256=sha(dest)))
    result=dict(schema='acgn-historical-retention-replay-sidecar-v1',originalRelease=release,originalScoreProducer=meta['measuredRunId'],dataset=meta['dataset'],scoresFromOriginal=True,sha256=all_inputs.hexdigest(),totals=totals,originalSlotted={'paired':len(sp),'reference':len(sr)},fixedPaired=347,originalInputs={str(names[k]):sha(path) for k,path in files.items()},shards=shards,generatorSha256=sha(Path(__file__)))
    dest=p/'manifest.json'
    if dest.exists():demand(jsonfile(dest)==result,'Supplementary manifest changed')
    else:atomic(dest,result)
    print(totals,sha(dest))
if __name__=='__main__':make()
