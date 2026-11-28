"""Re-execute archived v3.2 models byte-for-byte using the source-repair candidate's scoped reader and Alloy solver."""
import argparse,csv,gzip,hashlib,itertools,json,subprocess,sys,time
from pathlib import Path
src=Path(__file__).resolve().parent;p=src.parent;w=p.parent;sys.path.insert(0,str(p))
from run import registered,atomic,sha,check
def jobs():
    inv=w/'frozen/docs/experimental-results/2026-11-25/references.jsonl.gz';pairs=p/'upstream/pairs.csv.gz'
    m=json.loads((p/'manifest.json').read_bytes())['originalInputs']
    for path in (inv,pairs):check(sha(path)==m['docs/experimental-results/2026-11-25/'+path.name],'Changed original command source')
    with gzip.open(inv,'rt') as f:catalog={r['id']:r for r in map(json.loads,f)}
    with gzip.open(pairs,'rt') as f:
        for row in csv.DictReader(f):
            if not row['forward'] and row['native']!='SAT':continue
            a,b=map(int,(row['left'],row['right']));x,y=catalog[a],catalog[b]
            source=x['base']+'\n'+x['code']+y['code']+'\ncheck correct { '+x['selected']+' iff '+y['selected']+' }\n'
            check(hashlib.sha256(source.encode()).hexdigest()==row['root_sha256'] and row['forward']==row['reverse'],'Archived pair command digest or selector drift')
            yield dict(pair=[a,b],sha256=row['root_sha256'],source=source,native=row['native'],rules=row['forward'].split('|') if row['forward'] else [])
def launch(t):
    ident=registered(t);root=t/'archived-commands';root.mkdir(exist_ok=False);(root/'classes').mkdir()
    inputs=list(jobs());check(len(inputs)==1339 and len({tuple(j['pair']) for j in inputs})==1339,'Incomplete archived native controls')
    with (root/'input.jsonl').open('x') as f:
        for r in inputs:f.write(json.dumps(r,separators=(',',':'))+'\n')
    cp=str(t/'candidate.jar')+':'+str(w/'frozen/lib/*')
    subprocess.run(['javac','--release','17','-encoding','UTF-8','-cp',cp,'-d',str(root/'classes'),str(src/'CheckCommands.java')],check=True)
    registration=dict(schema='acgn-archived-original-fixed-command-live-v1',candidateCommit=ident['candidateCommit'],candidateJarSha256=sha(t/'candidate.jar'),candidateSidecarIdentitySha256=sha(t/'identity.json'),inputSha256=sha(root/'input.jsonl'),driverSha256=sha(src/'CheckCommands.java'),classSha256=sha(root/'classes/CheckCommands.class'),checkerSha256=sha(Path(__file__)),commands=len(inputs))
    atomic(root/'registration.json',registration)
    command=['nice','-n','15','taskset','-c','30','java','-Xmx384m','-XX:+UseSerialGC','-XX:ActiveProcessorCount=1','-Dorg.slf4j.simpleLogger.defaultLogLevel=warn','-cp',str(root/'classes')+':'+cp,'CheckCommands',str(root/'input.jsonl'),str(root/'comparison.als'),str(root/'results.jsonl')]
    with (root/'solver.log').open('wb') as f:subprocess.run(command,check=True,stdout=f,stderr=f)
    verify(t)
def verify(t):
    root=t/'archived-commands';reg=json.loads((root/'registration.json').read_bytes());check(sha(t/'candidate.jar')==reg['candidateJarSha256'] and sha(t/'identity.json')==reg['candidateSidecarIdentitySha256'] and sha(root/'classes/CheckCommands.class')==reg['classSha256'] and sha(src/'CheckCommands.java')==reg['driverSha256'] and sha(Path(__file__))==reg['checkerSha256'] and sha(root/'input.jsonl')==reg['inputSha256'],'Changed candidate command verifier/input/JAR')
    counts={};errors=[]
    with (root/'input.jsonl').open() as jf,(root/'results.jsonl').open() as rf:
        for j,cached,r in itertools.zip_longest(jobs(),map(json.loads,jf),map(json.loads,rf)):
            check(j and cached==j and r and (r['pair'],r['sha256'])==(j['pair'],j['sha256']),'Missing, misordered or substituted archived command')
            d=r.get('decision',{});key=d.get('native','ERROR')
            counts[key]=counts.get(key,0)+1
            if r.get('parsedSourceSha256')!=j['sha256'] or j['native']!=key or sorted(d.get('rules',[]))!=sorted(j['rules']):errors.append(r['pair'])
    status='VERIFIED' if counts=={'SAT':105,'UNSAT':1234} and not errors else 'BLOCKED'
    receipt=dict(status=status,candidateCommit=reg['candidateCommit'],candidateJarSha256=reg['candidateJarSha256'],native=counts,total=sum(counts.values()),unexpected=errors,originalRegistrationSha256=sha(root/'registration.json'),rawSha256=sha(root/'results.jsonl'))
    atomic(root/'receipt.json',receipt);print(json.dumps(receipt,sort_keys=True),flush=True);return receipt
if __name__=='__main__':
    a=argparse.ArgumentParser(description=__doc__);a.add_argument('run',type=Path);a.add_argument('--verify-only',action='store_true');args=a.parse_args();(verify if args.verify_only else launch)(args.run.resolve())
