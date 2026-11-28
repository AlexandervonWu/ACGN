"""Produce complete paired scalar results on a frozen engine with resumable checked shards."""
import argparse
import concurrent.futures
import fcntl
import os
import queue
import shutil
import subprocess
import sys
import threading
import time
from pathlib import Path
from inputs import W,D,CATALOG,build,check,read,record,sha

BASELINE='a4c30092d064b8fa39011d888b2a9898a8b5060588e3356bb98e8ba34543217e'
BASE_RUNNER='a2cf64f0889624b0dc675b73d80f5b34caca2d73c9448b788713463b8abc3f02'
REG='dc19adc38f2c2da7a24fafa043829cdaa295ece6c1e2264b6723f9d1190b499d'
def memory():
    return int(next(x for x in Path('/proc/meminfo').read_text().splitlines() if x.startswith('MemAvailable:')).split()[1])/1048576
def identity(final):
    if not final:
        p=W/'runner-identity.json'
        check(sha(p)==BASE_RUNNER,'Original runner differs')
        r=read(p);check(r['jarSha256']==BASELINE,'Original JAR registration changed')
        return dict(commit=r['sourceCommit'],jar=W/'frozen/measured.jar',sha=BASELINE,marker=sha(p),id='original')
    h=W/'final-audit-handoff-v2'
    st=read(h/'final-consumer-registration.json')
    check(sha(h/'final-consumer-registration.json')==REG and sha(h/'handoff_contract.py')==st['files']['final-audit-handoff-v2/handoff_contract.py'],'Invalid handoff reader')
    sys.path.insert(0,str(h));from handoff_contract import read_marker
    m=read_marker(W)
    return dict(commit=m['commit'],jar=m['jar'],sha=m['jarSha256'],marker=m['markerSha256'],id='final-'+m['uuid'])
def observed(inp,output):
    jobs=inp.read_text().splitlines();rows=output.read_text().splitlines()
    check(len(jobs)==len(rows) and all(r.startswith(j+'\t') for j,r in zip(jobs,rows)),'Rows or selection differ')
    measures=[tuple(map(int,r.split('\t'))) for r in rows]
    check(all(len(r)==4 and min(r[2:])>=0 for r in measures),'Incomplete numeric observations')
    return dict(rows=len(rows),unmatchedArms=sum(f!=c for a,b,f,c in measures),fastZeros=sum(f==0 for a,b,f,c in measures),certifiedZeros=sum(c==0 for a,b,f,c in measures))
def run(final,cpus):
    m=build();e=identity(final);place=D/e['id'];place.mkdir(exist_ok=True);out=place/'results';out.mkdir(exist_ok=True)
    locked=(place/'run.lock').open('a');fcntl.flock(locked,fcntl.LOCK_EX|fcntl.LOCK_NB)
    frozen=D/'registration.json';contract=read(frozen)
    for n,h in contract['files'].items():check(sha(D/n)==h,'Changed scalar program '+n)
    jar=e['jar'];check(sha(jar)==e['sha'],'Wrong exact JAR')
    libs=read(W/'runner-identity.json')['files']
    dep={p.name:sha(p) for p in (W/'frozen/lib').glob('*.jar')};check(dep=={n[11:]:h for n,h in libs.items() if n.startswith('frozen/lib/')},'Changed dependencies')
    classes=place/'classes'
    if not (place/'identity.json').exists():
        classes.mkdir(exist_ok=True)
        subprocess.run(['javac','--release','17','-encoding','UTF-8','-cp',f'{jar}:{W}/frozen/lib/*','-d',str(classes),str(D/'PoolScalars.java')],check=True)
    generated={q.relative_to(classes).as_posix():sha(q) for q in classes.rglob('*.class')};check(len(generated)==4,'Unexpected driver bytecode')
    ident=dict(sourceCommit=e['commit'],jarSha256=e['sha'],execution=e['id'],authorizationSha256=e['marker'],inputManifestSha256=sha(D/'inputs.json'),driverRegistrationSha256=sha(frozen),runtime=dep,classes=generated)
    record(place/'identity.json',ident);salt=sha(place/'identity.json')
    q=queue.Queue()
    for s in m['shards']:
        inp=D/'jobs'/s['name'];res=out/s['name'];marker=res.with_suffix('.json')
        if marker.exists():
            expected=read(marker);check(expected==dict(**observed(inp,res),input=sha(inp),output=sha(res),identity=salt),'Invalid closed shard')
        else:q.put(s)
    stop=threading.Event()
    def worker(cpu):
        j=None;log=None
        current=None
        def close():
            nonlocal j,log,current
            if j:
                if j.poll() is None:j.stdin.close()
                j.wait();log.close();j=None;current=None
        try:
            while not stop.is_set():
                try:s=q.get_nowait()
                except queue.Empty:break
                inp=D/'jobs'/s['name'];result=out/s['name']
                for attempt,(heap,cache) in enumerate([(650,16),(1200,4),(2100,2)]):
                    # The productionLine_v2 models build large proof terms. Leave room for the measured ranking.
                    need_memory=8.0+heap/1024
                    while memory()<need_memory and not stop.is_set():close();time.sleep(5)
                    if stop.is_set():return
                    if j is not None and current!=(heap,cache):close()
                    if j is None:
                        log=(place/f'jvm-{cpu}.log').open('ab')
                        cmd=['nice','-n','17','taskset','-c',str(cpu),'java','-Xms120m',f'-Xmx{heap}m',f'-Dacgn.pool.cache={cache}','-XX:+UseParallelGC','-XX:ParallelGCThreads=1','-XX:ActiveProcessorCount=1','-cp',f'{classes}:{jar}:{W}/frozen/lib/*','is.fivefivefive.CanDis.PoolScalars',str(W/'frozen/classified-data'),str(CATALOG)]
                        j=subprocess.Popen(cmd,stdin=subprocess.PIPE,stdout=subprocess.PIPE,stderr=log,text=True,bufsize=1);current=(heap,cache)
                    tmp=out/f'.{s["name"]}.{time.time_ns()}'
                    j.stdin.write(str(inp)+'\t'+str(tmp)+'\n');j.stdin.flush()
                    ack=j.stdout.readline().strip()
                    if ack==str(s['rows']):
                        tally=observed(inp,tmp);check(tally['rows']==s['rows'],'Missing scalar measurements')
                        tmp.replace(result);record(result.with_suffix('.json'),dict(**tally,input=sha(inp),output=sha(result),identity=salt));break
                    close()
                    if attempt==2:raise RuntimeError('Scalar comparison failed after reserved-memory retries: '+s['name'])
        except BaseException:stop.set();raise
        finally:close()
    with concurrent.futures.ThreadPoolExecutor(len(cpus)) as pool:
        for future in concurrent.futures.as_completed([pool.submit(worker,n) for n in cpus]):future.result()
    receipts={s['name']:sha((out/s['name']).with_suffix('.json')) for s in m['shards']}
    record(place/'completion.json',dict(identity=salt,inputs=sha(D/'inputs.json'),shards=receipts,rows=m['positiveRows']))
if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--final',action='store_true');p.add_argument('--cpus',required=True);a=p.parse_args();run(a.final,list(map(int,a.cpus.split(','))))
