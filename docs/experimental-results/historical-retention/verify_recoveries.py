"""Check run artifacts independent of the research report before promotion."""
import csv,gzip,hashlib,json
from collections import Counter
from pathlib import Path
import sys
repo=Path.cwd();out=Path(sys.argv[1]);base=repo/'docs/experimental-results'
def read(file):
 with gzip.open(file,'rt') as f:return list(map(json.loads,f))
def positives(dir,refs):
 ids={(r['source'],r['name']):r['id'] for r in refs}
 return {tuple(sorted(ids[r[q+'Source'],r[q]] for q in ('left','right'))) for r in read(dir/'correct-pool-pairs.jsonl.gz') if r['structuralZero']}
refs=read(base/'2026-11-25/references.jsonl.gz'); prior=positives(base/'v3.3',refs);current=positives(out,refs)
assert len(refs)==4496 and prior<current
native=read(out/'native-pool-gains.jsonl.gz')
assert len(native)==len(current-prior) and {tuple(r['ids']) for r in native}==current-prior and all(r['native']=='UNSAT' for r in native)
paired=list(csv.DictReader((out/'repaired-student-oracle.csv').open()))
assert len(paired)==6 and all(r['currentFastDistance']==r['currentCertifiedDistance']=='0' and r['nativeAtArchivedCommand']=='UNSAT' for r in paired)
pool=list(csv.DictReader((out/'repaired-reference-pairs.csv').open()))
assert len(pool)==1382 and {(int(r['leftId']),int(r['rightId'])) for r in pool}<=current-prior
assert all(int(r['v33FastDistance'])>0 and r['v33FastDistance']==r['v33CertifiedDistance'] and r['currentFastDistance']==r['currentCertifiedDistance']=='0' for r in pool)
print(f'{len(native)} gained structural reference pairs have matching native outcomes. {len(pool)} historical or original Slotted recoveries and {len(paired)} original-file recoveries match the new ledgers.')
