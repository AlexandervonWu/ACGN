"""Pack native projections and source-authority tables from both cold repetitions and one warmed replay."""
import argparse,csv,gzip,hashlib,json,lzma,shutil
from pathlib import Path
from occurrences import canonical,digest,project,require

def sha(b):return hashlib.sha256(b).hexdigest()

def main():
    ap=argparse.ArgumentParser(description=__doc__)
    for name in ("release","cold","warm","output"):ap.add_argument(name,type=Path)
    a=ap.parse_args()
    with (a.release/"previously-matched-program-changes.csv").open(newline="") as f: table=list(csv.DictReader(f))
    receipts={};witnesses={};observations=[]; examples=a.output/"example";examples.mkdir(exist_ok=True)
    for n,row in enumerate(table):
        for prof,indir,reps in (("cold",a.cold,2),("warm",a.warm,1)):
            for label in ("original","repaired"):
                for r in range(reps):
                    src=indir/f"{n:03d}-{label}-{r}.json.gz";raw=gzip.decompress(src.read_bytes())
                    w=project(raw,int(row["distance"]),int(row[label+"Count"]))
                    wid=digest(w)
                    if wid in witnesses:require(canonical(witnesses[wid])==canonical(w),"Witness hash collision")
                    else:witnesses[wid]=w
                    raw_id=sha(raw);receipts.setdefault(raw_id,src)
                    observations.append([n,label,prof,r,raw_id,wid])
                    if n==0 and r==0:shutil.copyfile(src,examples/(label+"-"+prof+".json.gz"))
    with lzma.open(a.output/"native-receipts.jsonl.xz","wb",preset=3) as stream:
        for raw_id,src in receipts.items():
            raw=gzip.decompress(src.read_bytes());require(raw.endswith(b"\n") and raw.count(b"\n")==1 and sha(raw)==raw_id,"Changed original JSON receipt");stream.write(raw)
    for name,data in (("witnesses",[[k,witnesses[k]] for k in sorted(witnesses)]),("observations",observations)):
        text="".join(canonical(x)+"\n" for x in data).encode()
        (a.output/(name+".jsonl.gz")).write_bytes(gzip.compress(text,mtime=0))
    for name,path in (("cold",a.cold),("warm",a.warm)):
        shutil.copyfile(path/"capture-receipt.json",a.output/(name+"-capture.json"))
if __name__=="__main__":main()
