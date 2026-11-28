from pathlib import Path
import collections,csv,gzip,hashlib,itertools,json,subprocess
a=Path(__file__).resolve().parent;w=a.parent
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
read=lambda p:json.loads(p.read_bytes())
m=read(w/'final-handoff/final-started.json'); v=Path(m['candidateRoot']);rt=read(v/'runner-identity.json')
assert sha(v/'runner-identity.json')==m['identitySha256'] and sha(v/'engine/candidate.jar')==m['jarSha256']
driver=v/'runner/ExhaustiveNativeReplay.java';assert sha(driver)==rt['files']['runner/ExhaustiveNativeReplay.java']
text=driver.read_text().replace('public final class ExhaustiveNativeReplay','public final class TemporalCapture')
original='            compareSequences(evidence,row);'
new='''            compareSequences(evidence,row);
            copy(evidence,row,"fastBlocks","certifiedBlocks");'''
assert text.count(original)==1
src=a/'TemporalCapture.java';src.write_text(text.replace(original,new))
subprocess.run(['javac','--release','17','-encoding','UTF-8','-cp',str(v/'engine/candidate.jar')+':'+str(w/'frozen/lib/*'),'-d',str(a/'classes'),str(src)],check=True)
lib={k:h for k,h in rt['files'].items() if k.startswith('original-inputs/lib/')}
for name,h in lib.items():assert sha(v/name)==h
with (w/'cohort/reference-catalog.tsv').open() as f: refs={(r['source'],r['predicate']):int(r['referenceId']) for r in csv.DictReader(f,delimiter='\t')}
with (w/'cohort/source-catalog.tsv').open() as f:sc={r['source']:r for r in csv.DictReader(f,delimiter='\t')}
compact=v/'independent-final';summary=read(compact/'summary.json')
assert summary['matchedModes']['TEMPORAL_BLOCK_EFFECTS']==26673
expected={}
for p in sorted(compact.glob('native-ranking-*.jsonl.gz')):
 with gzip.open(p,'rt') as f:
  for line in f:
   path,edges=json.loads(line)
   for i,mode,n,h in edges:
    if mode=='T':
     key=path,i;assert key not in expected;expected[key]=(n,h)
assert len(expected)==26673
manifest=read(w/'cohort/manifest.json'); fullrows=0; selected=[]; boundaries={}
for s in manifest['shards']:
 name=s['id']; jobs=w/'cohort/jobs'/(name+'.tsv');raw=v/'results'/(name+'.jsonl');receipt=v/'results'/(name+'.receipt.json')
 r=read(receipt);assert sha(raw)==r['outputSha256'] and sha(jobs)==s['sha256']==r['inputSha256'] and r['identitySha256']==m['identitySha256']
 size=0; hits=0
 with raw.open('rb') as rr,jobs.open('rb') as jj:
  for ordinal,(x,j) in enumerate(itertools.zip_longest(rr,jj)):
   assert x and j;size+=1
   if b'TEMPORAL_BLOCK_EFFECTS' not in x:continue
   row=json.loads(x); q=j.decode().rstrip('\n').split('\t');key=q[1],refs[(q[4],q[5])]
   nc,arch=expected.pop(key)
   assert row['ordinal']==ordinal and row['sequenceKind']=='TEMPORAL_BLOCK_EFFECTS' and row['status']=='MATCHED' and row['expected']==row['fastDistance']==row['certifiedDistance']==int(q[7]) and row['fastSequenceSha256']==row['certifiedSequenceSha256']==arch and row['fastBlockCount']==row['certifiedBlockCount']==nc
   assert q[2]==row['leftPredicate'] and q[5]==row['rightPredicate'] and (row['left'],row['right'])==(q[1],q[4])
   hits+=1;selected.append((q,[key[0],key[1],name,ordinal,nc,arch]))
 assert size==s['rows']==r['rows'];fullrows+=size
 if hits:boundaries[name]=dict(temporal=hits,raw=r['outputSha256'],receipt=sha(receipt),input=r['inputSha256'])
assert fullrows==1894168 and not expected and len(selected)==26673
order=sorted(selected,key=lambda t:(t[0][1],t[0][2],t[1][1]))
chunks=[];index=[];total=0
for n in range(0,len(order),160):
 seq=order[n:n+160];name=f'time-{n//160:03d}';path=a/'jobs'/(name+'.tsv'); data=''.join('\t'.join(q+[str(i)])+'\n' for i,(q,_) in enumerate(seq));path.write_text(data)
 chunks.append(dict(name=name,rows=len(seq),sha256=sha(path)))
 for i,(q,meta) in enumerate(seq):index.append([name,i,*meta,q[2],q[3],q[4],q[5],q[6],int(q[7])])
with (a/'expected.jsonl').open('w') as f:
 for z in index:f.write(json.dumps(z,separators=(',',':'))+'\n')
receipt=dict(selected=len(order),originalRows=fullrows,identity=sha(v/'runner-identity.json'),commit=m['commit'],jar=m['jarSha256'],finalSummary=sha(compact/'summary.json'),inputManifest=sha(w/'cohort/manifest.json'),cohortScript=sha(Path(__file__)),originalJava=sha(driver),captureJava=sha(src),captureClasses={str(p.relative_to(a)):sha(p) for p in sorted((a/'classes').rglob('*.class'))},libs=lib,shards=chunks,rankSourceShards=boundaries,expectedSha256=sha(a/'expected.jsonl'))
(a/'manifest.json').write_text(json.dumps(receipt,sort_keys=True,indent=2)+'\n')
print('AUTHORIZED',len(order),sha(a/'manifest.json'),flush=True)
