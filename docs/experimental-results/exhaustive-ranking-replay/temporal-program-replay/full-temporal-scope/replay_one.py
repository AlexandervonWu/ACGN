"""Re-run one archived temporal comparison using the measured final binary and original predicate selections."""
import argparse
import gzip
import hashlib
import json
from pathlib import Path
import subprocess
import tempfile

def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def main():
    d=Path(__file__).resolve().parent;p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('submission');p.add_argument('reference_id',type=int);p.add_argument('--repo',required=True,type=Path);p.add_argument('--jar',required=True,type=Path)
    p.add_argument('--libs',required=True,type=Path);p.add_argument('--output',required=True,type=Path)
    a=p.parse_args();m=json.loads((d/'capture-manifest.json').read_bytes())
    if sha(a.jar)!=m['jar'] or any(sha(a.libs/Path(name).name)!=expected for name,expected in m['libs'].items()):p.error('Supply the exact final JAR and eight registered dependencies')
    with gzip.open(d/'selected-jobs.jsonl.gz','rt') as f:candidates=[z for line in f if (z:=json.loads(line))[2:4]==[a.submission,a.reference_id]]
    if len(candidates)!=1:p.error('This selector is outside the measured temporal cohort')
    z=candidates[0];cp=f'{d}/classes:{a.jar.resolve()}:{a.libs.resolve()}/*'
    with tempfile.TemporaryDirectory() as tmp:
        t=Path(tmp);(t/'incidents').mkdir();(t/'inflight').mkdir();job=t/'selected.tsv'
        job.write_text('\t'.join(['paid',z[2],z[8],z[9],z[10],z[11],z[12],str(z[-1]),'0'])+'\n')
        proc=subprocess.run(['java','-Xmx850m','-XX:+UseParallelGC','-XX:ParallelGCThreads=1','-XX:ActiveProcessorCount=1','-cp',cp,'is.fivefivefive.CanDis.TemporalCapture',str((a.repo/'classified-data').resolve()),str(t),'12'],input=f'selected\t{job}\t0\n',capture_output=True,text=True,check=True)
        receipt=json.loads(proc.stdout);require=receipt['rows']==receipt['newRows']==1
        if not require:raise ValueError('Original comparator did not return one native result')
        with a.output.open('xb') as f:f.write((t/'inflight/selected.jsonl').read_bytes())
if __name__=='__main__':main()
