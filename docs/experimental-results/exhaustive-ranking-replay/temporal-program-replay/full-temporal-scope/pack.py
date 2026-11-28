from pathlib import Path
import collections,csv,gzip,hashlib,json,os,shutil,subprocess,sys,tempfile
from zipfile import ZipFile, ZIP_STORED
a=Path(__file__).resolve().parent;w=a.parent;release=w/'release-export';source=release/'temporal-program-replay'
sys.path[:0]=[str(source),str(release/'reproduce/original-audit')]
from occurrences import offset_between,canonical,digest
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
read=lambda p:json.loads(p.read_bytes())
def write(p,s):p.write_text(json.dumps(s,indent=2,sort_keys=True)+'\n')
def compress(p,b):
 with p.open('wb') as f,gzip.GzipFile(filename='',mode='wb',fileobj=f,compresslevel=7,mtime=0) as g:g.write(b)
def imp_read(p):
 with gzip.open(p,'rt') as f:yield from map(json.loads,f)
m=read(a/'manifest.json');ended=read(a/'captured.json');audit=read(a/'recount.json')
assert ended['rows']==audit['fullTemporalRows']==26673 and audit['checked']['strictRawChanged']==196
assert ended['manifest']==audit['selectedManifest']==sha(a/'manifest.json')
assert sha(a/'prepare.py')==m['cohortScript'] and sha(a/'audit.py')==audit['auditCode']
tmp=a/'portable-stage';tmp.mkdir(exist_ok=True);out=tmp/'full-temporal-scope';out.mkdir(exist_ok=True)
for src,n in [('manifest.json','capture-manifest.json'),('recount.json','raw-recount.json'),('captured.json','producer.json'),('portable.py','verify.py'),('TemporalCapture.java','TemporalCapture.java'),('prepare.py','prepare.py'),('run.py','run.py'),('audit.py','audit.py'),('replay_one.py','replay_one.py'),('pack.py','pack.py')]:shutil.copyfile(a/src,out/n)
shutil.copytree(a/'classes',out/'classes',dirs_exist_ok=True)
compress(out/'selected-jobs.jsonl.gz',(a/'expected.jsonl').read_bytes())
sources=sorted((a/'results').glob('time-*.jsonl.gz'));group=[];groups=[];size=0
for f in sources:
 if group and size+f.stat().st_size>24_000_000:groups.append(group);group=[];size=0
 group.append(f);size+=f.stat().st_size
if group:groups.append(group)
binds={}; selected_rows=[]; offsets={}; frozen={}
for h,wt in imp_read(source/'witnesses.jsonl.gz'):frozen[h]=wt['program']
cold={int(ix):frozen[h] for ix,arm,pr,rep,_,h in imp_read(source/'observations.jsonl.gz') if (arm,pr,rep)==('repaired','cold',0)}
with (release/'previously-matched-program-changes.csv').open() as f: controls={(row['submission'],int(row['referenceId'])):ix for ix,row in enumerate(csv.DictReader(f))}
for i,pack in enumerate(groups):
 name=f'native-blocks-{i:02d}.zip'
 with ZipFile(out/name,'w',compression=ZIP_STORED) as zz:
  for raw in pack:
   n=raw.name.split('.')[0];rec=a/'results'/(n+'.receipt.json');san=a/'audit'/(n+'.json')
   assert sha(san)==audit['shards'][n] and sha(rec)==ended['shards'][n] and sha(raw)==read(san)['capture']
   compact=a/'audit'/(n+'.jsonl.gz');assert sha(compact)==read(san)['summary']
   rows=list(imp_read(compact));selected_rows.extend(rows)
   interest={j:controls[(v[0],v[1])] for j,v in enumerate(rows) if (v[0],v[1]) in controls}
   if interest:
    for j,r in enumerate(imp_read(raw)):
     if j in interest:
      ix=interest[j];program=[[b['component'],b['effect']] for b in r['fastBlocks']]
      assert digest(program)==r['fastSequenceSha256']
      offsets[ix]=offset_between({'program':cold[ix]},{'program':program})
   for path in (raw,rec):zz.writestr(path.name,path.read_bytes())
   binds[n]=dict(bundle=name,native=sha(raw),receipt=sha(rec))
assert len(offsets)==196
write(out/'fresh-replay-offsets.json',[[k,offsets[k]] for k in sorted(offsets)])
compress(out/'pair-observations.jsonl.gz',''.join(json.dumps(r,separators=(',',':'))+'\n' for r in selected_rows).encode())
(out/'README.md').write_text("""# All temporal ranking comparisons

A fresh replay of each of the 26,673 temporal comparisons in the closed final ranking corpus returned identical Fast Rewrite and Certified scores and ordered block effects. On 26,477 inputs the fresh digest also exactly reproduced the original final-run digest. The other 196 inputs carry a process-local occurrence number for a bound variable inside the ordered effect. All 196 are present in the separate comparison across releases. The archive preserves the literal numerical IDs and both original block arrays for every fresh comparison.

Run this reader from the release directory with the ACGN checkout containing the original classified corpus and the published scores.

    python3 -B temporal-program-replay/full-temporal-scope/verify.py --archive . --repo /path/to/ACGN

For a single run in a fresh JVM, pass its submission path, reference ID, frozen final JAR, runtime dependencies and a new output filename.

    python3 -B temporal-program-replay/full-temporal-scope/replay_one.py SUBMISSION REFERENCE_ID --repo /path/to/ACGN --jar /path/to/final.jar --libs /path/to/lib --output /tmp/native-program.json

The input table selects the complete temporal class from the final ranking archive. Each row retains submission and reference selectors and hashes, positive expected score, original measured shard and ordinal, block count and the measured final digest. Each compact observation records those source identities, both fresh program commitments, a SHA-256 of the complete raw JSON line, local-occurrence counts and the affected endpoint. The ZIP members retain the full native arrays, including entries and effects, with per-shard worker acknowledgments. Fresh replay offsets are measured separately against clean JVM observations. The portable reader checks exact native JSON commitments before calculating any allocator shifts. It compares the entire fresh effect program with the independent cold replay after translating only the named binding-occurrence field. The parent directory holds the separate owner and phase evidence.

The structural and ranking correctness claims use the native comparator within each execution. The archive retains the process-local binding numbers. Translating those numbers by the recorded, pair-specific allocator offsets reproduces the exact archived final commitments for all 196 observations.
""")
files={p.relative_to(out).as_posix():sha(p) for p in sorted(out.rglob('*')) if p.is_file() and p.name not in ('inventory.json','summary.json')}
write(out/'inventory.json',dict(schema='acgn-complete-temporal-replay-v1',commit=m['commit'],jar=m['jar'],captureManifestSha256=sha(out/'capture-manifest.json'),files=files,nativeCaptures=binds))
cmd=[sys.executable,'-B',str(out/'verify.py'),'--archive',str(release),'--repo',str(w/'frozen')]
v=subprocess.run([*cmd,'--produce'],check=True,capture_output=True);(out/'summary.json').write_bytes(v.stdout)
result=read(out/'summary.json');assert result['status']=='VERIFIED' and result['supplementaryTemporalRows']==26673
result_target=source/'full-temporal-scope'
if result_target.exists() and 'archiveCommitmentsReconstructedWithOnlyLocalOccurrenceTranslation' not in read(result_target/'summary.json'):
    result_target.rename(a/'initial-portable-scope')
if not result_target.exists():out.rename(result_target)
checked=subprocess.run([sys.executable,'-B',str(result_target/'verify.py'),'--archive',str(release),'--repo',str(w/'frozen')],capture_output=True,check=True)
assert json.loads(checked.stdout)==result
earlier=a/'published.json'
if earlier.exists() and 'archiveCommitmentsReconstructedWithOnlyLocalOccurrenceTranslation' not in read(earlier)['latestVerifiedResult']:
    earlier.rename(a/'initial-portable-receipt.json')
write(a/'published.json',dict(status='VERIFIED',folder='temporal-program-replay/full-temporal-scope',summarySha256=sha(result_target/'summary.json'),inventorySha256=sha(result_target/'inventory.json'),portableCheckerSha256=sha(result_target/'verify.py'),rows=26673,jar=m['jar'],latestVerifiedResult=result))
print('VERIFIED',sha(a/'published.json'),flush=True)
