"""Rebuild a committed candidate twice against the original frozen replay dependencies."""
import argparse, hashlib, json, os, shutil, subprocess, time, zipfile
from pathlib import Path

parser=argparse.ArgumentParser(description=__doc__)
parser.add_argument("revision");parser.add_argument("dest", type=Path)
args=parser.parse_args();dest=args.dest.resolve()
repo=Path(subprocess.check_output(['git','rev-parse','--show-toplevel'],text=True).strip())
commit=subprocess.check_output(['git','rev-parse','--verify',args.revision+'^{commit}'],text=True).strip()
w=Path(__file__).resolve().parents[1];base=w/'frozen';dest.mkdir(parents=True,exist_ok=False)
source=dest/'source';source.mkdir()
with subprocess.Popen(['git','archive',commit,'src','lib'],cwd=repo,stdout=subprocess.PIPE) as git:
    subprocess.run(['tar','-x','-C',str(source)],stdin=git.stdout,check=True);git.stdout.close()
    if git.wait():raise RuntimeError('Failed to isolate Git snapshot')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def census(root,suffix):return {str(p.relative_to(root)):sha(p) for p in sorted(root.rglob('*'+suffix))}
libs=census(source/'lib','.jar')
if libs!=census(base/'lib','.jar'):raise RuntimeError('Candidate dependencies differ from original experiment')
src=sorted((source/'src').rglob('*.java'));runlogs=[];sets=[]
for name in ['a','b']:
    build=dest/name;build.mkdir()
    with (dest/(name+'.log')).open('w') as log:
        stamp=time.time()
        subprocess.run(['javac','-J-XX:ActiveProcessorCount=2','-J-Xmx650m','--release','17','-encoding','UTF-8','-cp',str(source/'lib/*'),'-d',str(build),*map(str,src)],stdout=log,stderr=subprocess.STDOUT,check=True)
        jar=dest/(name+'.jar')
        subprocess.run(['jar','--create','--file',str(jar),'--date=2000-01-01T00:00:00Z','-C',str(build),'.'],stdout=log,stderr=subprocess.STDOUT,check=True)
        runlogs.append({'build':name,'elapsedSeconds':time.time()-stamp,'logSha256':sha(dest/(name+'.log'))})
    m=census(build,'.class');sets.append(m)
    with zipfile.ZipFile(jar) as archive: assert {n:hashlib.sha256(archive.read(n)).hexdigest() for n in archive.namelist() if n.endswith('.class')}==m
if not sets[0] or sets[0]!=sets[1] or sha(dest/'a.jar')!=sha(dest/'b.jar'):raise RuntimeError('Independent clean builds differ')
with zipfile.ZipFile(base/'measured.jar') as z: before={n:hashlib.sha256(z.read(n)).hexdigest() for n in z.namelist() if n.endswith('.class')}
original=base/'docs/experimental-results/historical-retention/run-receipt.json'
upstream=json.loads(original.read_bytes())['git']['commit']
diff=subprocess.check_output(['git','diff','--name-only',upstream,commit,'--','src'],cwd=repo,text=True).splitlines()
def inventory(file,m):
    payload=''.join(f"{v}  {k}\n" for k,v in sorted(m.items())).encode();(dest/file).write_bytes(payload)
    return hashlib.sha256(payload).hexdigest()
summary={'schema':'acgn-ranking-replay-reproducible-build-v1','git':{'commit':commit,'tree':subprocess.check_output(['git','rev-parse',commit+':src'],text=True).strip()},'buildSource':'git archive of committed src and lib','sourceFiles':len(src),'sourceManifestSha256':inventory('sources.sha256',census(source/'src','.java')),'classfiles':len(sets[0]),'classfileManifestSha256':inventory('classes.sha256',sets[0]),'dependencies':libs,'builds':runlogs,'buildsByteIdentical':True,'javac':subprocess.check_output(['javac','-version'],text=True).strip(),'experimentJar':{'sha256':sha(dest/'a.jar'),'path':'a.jar'},'originalCommit':upstream,'originalJarSha256':sha(base/'measured.jar'),'changedFiles':diff,'changedClasses':sorted(k for k in set(before)|set(sets[0]) if before.get(k)!=sets[0].get(k))}
(dest/'build-receipt.json').write_text(json.dumps(summary,indent=2,sort_keys=True)+'\n')
print(commit,summary['experimentJar'],len(summary['changedClasses']),'changed classfiles')
