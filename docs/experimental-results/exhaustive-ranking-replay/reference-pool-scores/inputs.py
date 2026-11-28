"""Reconstruct all published unordered correct-reference selections and their original zero classification."""
import collections
import csv
import gzip
import hashlib
import itertools
import json
from pathlib import Path

D = Path(__file__).resolve().parent
W = D.parent
CATALOG = W/'cohort/reference-catalog.tsv'
SCORES = W/'frozen/docs/experimental-results/historical-retention/correct-pool-pairs.jsonl.gz'
COHORT = '074fbe5573ccf33de100f85cc14a7d0f33c297271b933401ee061d066da99ff5'
ORIGINAL = 'da470f79361d72e8a9e1e6feb8e68a4658c0b6152b8f89cb8ec61c49f48fccb4'
def check(ok,msg):
    if not ok:raise ValueError(msg)
def sha(p):
    h=hashlib.sha256()
    with p.open('rb') as f:
        for block in iter(lambda:f.read(1024*1024),b''):h.update(block)
    return h.hexdigest()
def read(p):return json.loads(p.read_bytes())
def record(p,v):
    data=(json.dumps(v,indent=2,sort_keys=True)+'\n').encode()
    if p.exists():check(p.read_bytes()==data,'Changed immutable artifact '+str(p))
    else:p.write_bytes(data)
def catalog(path=CATALOG):
    with path.open() as f:return list(csv.DictReader(f,delimiter='\t'))
def build():
    check(sha(W/'cohort/manifest.json')==COHORT and sha(SCORES)==ORIGINAL,'Changed original release')
    meta=read(W/'cohort/manifest.json')
    refs=catalog()
    check(sha(CATALOG)==meta['supportingFiles']['reference-catalog.tsv'], 'Changed source catalog')
    pools=collections.defaultdict(list);names={};checked={}
    for r in refs:
        i=int(r['referenceId']);group=(r['questionSet'],r['invariantId'])
        pools[group].append(i);k=(r['source'],r['name']);check(k not in names,'Duplicate selector');names[k]=i
        p=W/'frozen/classified-data'/r['source']
        if p not in checked:checked[p]=sha(p)
        check(checked[p]==r['sourceSha256'],'Source hash drift')
    check(len(refs)==4496 and len(pools)==181,'Wrong reference catalog')
    allkeys={tuple(sorted(pair)):pool for pool,ids in pools.items() for pair in itertools.combinations(ids,2)}
    check(len(allkeys)==132032,'Observed pool universe changed')
    full={};positive=[]
    with gzip.open(SCORES,'rt') as f:
        for line in f:
            r=json.loads(line);a=names[r['leftSource'],r['left']];b=names[r['rightSource'],r['right']]
            k=tuple(sorted((a,b)));pool=(r['questionSet'],r['invariantId']);z=r['structuralZero']
            check(type(z) is bool and k not in full and allkeys.get(k)==pool,'Invalid original pool identity')
            full[k]=(a,b,z)
            if not z:positive.append((a,b))
    check(allkeys.keys()==full.keys() and len(positive)==112761,'Incomplete original positive/zero partition')
    prior=W/'previously-covered';zset=set()
    for s in read(prior/'manifest.json')['shards']:
        if s['kind']=='zero':
            check(sha(prior/s['path'])==s['sha256'],'Changed native-zero input')
            for l in (prior/s['path']).read_bytes().splitlines():
                j=json.loads(l);zset.add((j['a'][5],j['b'][5]))
    check(zset=={(a,b) for a,b,z in full.values() if z} and len(zset)==19271,'Incorrect positive complement')
    groups=collections.defaultdict(list)
    for a,b in positive:groups[allkeys[tuple(sorted((a,b)))]].append((a,b))
    ordered=[]
    for pool,batch in sorted(groups.items()):
        loc={j:i for i,j in enumerate(pools[pool])}
        ordered.extend(sorted(batch,key=lambda x:(loc[x[0]]//16,loc[x[1]]//16,x)))
    jobs=D/'jobs';jobs.mkdir(exist_ok=True);shards=[]
    for start in range(0,len(ordered),384):
        batch=ordered[start:start+384];p=jobs/f'p{start//384:03}.tsv'
        b=''.join(f'{a}\t{b}\n' for a,b in batch).encode()
        if p.exists():check(p.read_bytes()==b,'Changed input')
        else:p.write_bytes(b)
        shards.append(dict(name=p.name,rows=len(batch),sha256=sha(p)))
    stat=dict(positiveRows=len(ordered),nativeZeroRows=len(zset),allPairs=len(full),catalogSha256=sha(CATALOG),originalZeroDecisionsSha256=ORIGINAL,sourceFiles=len(checked),originalScoreCostsStored=False,shards=shards)
    record(D/'inputs.json',stat)
    return stat
if __name__=='__main__':print(build()['positiveRows'])
