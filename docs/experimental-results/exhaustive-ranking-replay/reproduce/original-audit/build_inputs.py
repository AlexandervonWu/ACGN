"""Construct the complete released incorrect-submission/reference job corpus from immutable source evidence."""
import argparse, collections, csv, gzip, hashlib, json, os, subprocess
from pathlib import Path

SCHEMA='acgn-exhaustive-paid-ranking-inputs-v1'
RELEASE='0ef41a42'
MEASURED='9693595eb4f60c6c70b6d8d174ee309d1fdcf9aa'
PUBLICATION=Path('docs/experimental-results/historical-retention')
CATALOG=Path('docs/experimental-results/2026-11-25/references.jsonl.gz')
NROWS=1894168
NFILES=42386
CAP=2048

def require(ok,msg):
    if not ok:raise ValueError(msg)

def sha(path):
    h=hashlib.sha256()
    with path.open('rb') as fp:
        for block in iter(lambda:fp.read(4*1024**2),b''):h.update(block)
    return h.hexdigest()
def jsonrows(path):
    with gzip.open(path,'rt') as fp:
        yield from map(json.loads,fp)
def table(path):
    with gzip.open(path,'rt',newline='') as fp: yield from csv.DictReader(fp)
def git(repo,*args):
    return subprocess.check_output(['git','-C',str(repo),*map(str,args)])
def blob(data):
    return hashlib.sha1(b'blob '+str(len(data)).encode()+b'\0'+data).hexdigest()
def tree(repo,rev,*paths):
    raw=git(repo,'ls-tree','-r','-z',rev,'--',*paths)
    result={}
    for entry in raw.split(b'\0'):
        if not entry:continue
        info,name=entry.split(b'\t',1);mode,kind,oid=info.split(b' ')
        require(mode==b'100644' and kind==b'blob',f'Unexpected object type for {name!r}')
        result[name.decode()]=oid.decode()
    return result
def writejson(path,x):
    raw=json.dumps(x,indent=2,sort_keys=True,ensure_ascii=False)+'\n'
    tmp=path.with_suffix(path.suffix+'.tmp');tmp.write_text(raw);tmp.replace(path)
def release_rows(frozen,repo,output,raw_exclusions):
    output.mkdir(exist_ok=True);jobs=output/'jobs';jobs.mkdir()
    rel=git(repo,'rev-parse',RELEASE).decode().strip()
    data_tree=git(repo,'rev-parse',rel+':classified-data').decode().strip()
    require(data_tree==git(repo,'rev-parse',MEASURED+':classified-data').decode().strip(),'Corpus changed between measured and evidence commits')
    files=[PUBLICATION/x for x in ('ranking-scores.jsonl.gz','nearest-distances.csv.gz','paired-comparisons.jsonl.gz','run-receipt.json','headlines.json','ranking-score-parity.json')]+[CATALOG]
    blobs=tree(repo,rel,*files);upstream={}
    for p in files:
        content=(frozen/p).read_bytes();require(blob(content)==blobs[p.as_posix()],f'Changed published file {p}')
        upstream[p.as_posix()]=dict(sha256=hashlib.sha256(content).hexdigest(),gitBlob=blob(content),bytes=len(content))
    base=frozen/PUBLICATION;receipt=json.loads((base/'run-receipt.json').read_bytes())
    require(receipt['status']=='complete' and receipt['fullManifestVerified'] and receipt['git']=={'commit':MEASURED,'dirty':False},'Unexpected run identity')
    headline=json.loads((base/'headlines.json').read_bytes())
    require(headline['nearest']['comparisons']==NROWS and headline['nearest']['submissions']==NFILES and headline['nearest']['numericRankingDisagreements']==0,'Expected published ranking cohort')
    catalog=list(jsonrows(frozen/CATALOG));refs={r['id']:r for r in catalog}
    require(len(refs)==len(catalog)==4496 and sorted(refs)==list(range(len(refs))),'Reference IDs incomplete')
    by_pool=collections.defaultdict(set);name_id={}
    for r in refs.values():
        g=tuple(r['group']);by_pool[g].add(r['id']);k=r['source'],r['name'];require(k not in name_id,'Reference alias collision');name_id[k]=r['id']
    require(len(by_pool)==181 and len({(r['source'],r['operator']) for r in catalog})==4496,'Ambiguous reference identity')
    source_rows={}
    for r in jsonrows(base/'paired-comparisons.jsonl.gz'):
        require(r['path'] not in source_rows,'Duplicate original-source pair')
        source_rows[r['path']]=(r['left'],r['right'],r['status'])
    incorrect={s for s,(_,_,status) in source_rows.items() if status!='CORRECT'}
    require(len(source_rows)==61598 and len(incorrect)==NFILES,'Expected measured incorrect source identities')
    need=incorrect|{r['source'] for r in catalog}
    data=frozen/'classified-data'
    corpus_blobs=tree(repo,rel,'classified-data');h=hashlib.sha256();bytecount=0;hashes={}
    for key,oid in sorted(corpus_blobs.items()):
        name=key[len('classified-data/'):];require(name.endswith('.als'),'Unexpected dataset object')
        contents=(data/name).read_bytes();require(blob(contents)==oid,f'Changed original source: {name}')
        h.update(name.encode());h.update(b'\0');h.update(contents);h.update(b'\xff');bytecount+=len(contents)
        if name in need:hashes[name]=hashlib.sha256(contents).hexdigest()
    require((len(corpus_blobs),bytecount,h.hexdigest())==(receipt['dataset']['fileCount'],receipt['dataset']['byteCount'],receipt['dataset']['sha256']),'Whole corpus does not match measured receipt')
    require(hashes.keys()==need,'Missing ranked source')
    for r in refs.values():
        require(r['source'] in source_rows and r['operator']==source_rows[r['source']][r['kind']=='oracle'] and r['sha']==hashes[r['source']],f'Wrong selected catalog predicate or source digest at ID {r["id"]}')
    nearest={r['path']:(int(r['legacyCanonicalDistance']),int(r['canonicalDistance'])) for r in table(base/'nearest-distances.csv.gz')}
    require(nearest.keys()==incorrect,'Nearest and original cohorts differ')
    by=gzip.open(base/'ranking-scores.jsonl.gz','rb');rows=collections.defaultdict(list);gaps=set();seen=set();total=0
    for line in by:
        path,ids,fast,cert=json.loads(line);require(path in incorrect and path not in seen,'Missing or duplicated ranking source');seen.add(path)
        left=source_rows[path][0];group=(path.split('/')[0],left);require(group in by_pool and ids and ids==sorted(set(ids)) and set(ids)<=by_pool[group],'Incorrect reference pool')
        require(fast==cert and len(ids)==len(fast) and all(type(x) is int and x>0 for x in fast) and nearest[path]==(min(fast),min(cert)),f'Invalid ranking scores at {path}')
        gaps.update((path,missing) for missing in by_pool[group]-set(ids));total+=len(ids)
        rows[group].append((path,line))
    by.close()
    require(seen==incorrect and total==NROWS and len(gaps)==21,'Full published selection not recovered')
    # The original producer excludes an AST-identical external reference. Match
    # its exact 21 decisions by path and finite catalog ID.
    if raw_exclusions:
        with raw_exclusions.open(newline='') as fp:
            exclusions={(r['incorrectPath'],name_id[r['referenceSource'],r['referenceName']]) for r in csv.DictReader(fp)}
        require(exclusions==gaps,'Missing references disagree with original AST-identity exclusion ledger')
    writejson(output/'ast-identical-exclusions.json',[{'source':p,'referenceId':i} for p,i in sorted(gaps)])
    with (output/'source-catalog.tsv').open('w') as fp:
        fp.write('source\tstudentPredicate\toraclePredicate\tstatus\tsourceSha256\tgitBlob\n')
        for path in sorted(need):
            fp.write('\t'.join([path,*source_rows[path],hashes[path],corpus_blobs['classified-data/'+path]])+'\n')
    with (output/'reference-catalog.tsv').open('w') as fp:
        fp.write('referenceId\tquestionSet\tinvariantId\tname\tkind\tsource\tpredicate\tsourceSha256\n')
        for i,r in sorted(refs.items()):
            fp.write('\t'.join([str(i),*r['group'],r['name'],r['kind'],r['source'],r['operator'],r['sha']])+'\n')
    shards=[];digest=hashlib.sha256()
    def emit(pool,subset):
        ident=f'shard-{len(shards):04d}';relpath='jobs/'+ident+'.tsv';m=0;weight=[]
        with (output/relpath).open('xb') as f:
            for path,line in subset:
                _,ids,fast,_=json.loads(line)
                for i,cost in zip(ids,fast):
                    r=refs[i];raw='\t'.join(['paid',path,source_rows[path][0],hashes[path],r['source'],r['operator'],r['sha'],str(cost)]).encode()+b'\n'
                    f.write(raw);digest.update(raw);m+=1;weight.append(cost)
        shards.append(dict(id=ident,path=relpath,sha256=sha(output/relpath),rows=m,submissions=len(subset),pool=list(pool),expectedScoreSum=sum(weight),expectedScoreMax=max(weight)))
    for pool,ls in sorted(rows.items()):
        counts=[(path,line,len(json.loads(line)[1])) for path,line in sorted(ls)]
        width=0;part=[]
        for path,line,n in counts:
            if part and n+width>CAP:emit(pool,part);part=[];width=0
            part.append((path,line));width+=n
        if part:emit(pool,part)
    require(sum(s['rows'] for s in shards)==NROWS,'Sharding lost scored pairs')
    m=dict(schema=SCHEMA,releaseCommit=rel,measuredCommit=MEASURED,measuredRunId=receipt['runId'],jarSha256=receipt['experimentJar']['sha256'],
           dataset=dict(gitTree=data_tree,fileCount=len(corpus_blobs),bytes=bytecount,sha256=h.hexdigest()),
           upstream=upstream,rows=total,submissions=len(seen),references=len(refs),pools=len(rows),shards=shards,
           selectedSourceFiles=len(need),excludedAstIdentical=21,maxShardRows=CAP,
           combinedInputsSha256=digest.hexdigest(),generatorSha256=sha(Path(__file__).resolve()),
           supportingFiles={p:sha(output/p) for p in ('source-catalog.tsv','reference-catalog.tsv','ast-identical-exclusions.json')})
    if raw_exclusions:m['producerAstExclusionsSha256']=sha(raw_exclusions)
    writejson(output/'manifest.json',m)
    print(f"{total:,} exact ranking pairs, {len(seen):,} sources, {len(shards)} shards; SHA-256 {sha(output/'manifest.json')}")
if __name__=='__main__':
    ap=argparse.ArgumentParser(description=__doc__);ap.add_argument('--repo',type=Path,required=True);ap.add_argument('--frozen',type=Path,required=True);ap.add_argument('--output',type=Path,required=True);ap.add_argument('--producer-ast-exclusions',type=Path)
    a=ap.parse_args();release_rows(a.frozen,a.repo,a.output,a.producer_ast_exclusions)
