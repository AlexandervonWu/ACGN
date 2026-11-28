from pathlib import Path
import collections,concurrent.futures,datetime,gzip,hashlib,json,os,queue,shutil,subprocess,threading,time
a=Path(__file__).resolve().parent;w=a.parent;r=a/'results'
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
read=lambda p:json.loads(p.read_bytes())
m=read(a/'manifest.json');v=Path(read(w/'final-handoff/final-started.json')['candidateRoot'])
assert sha(v/'engine/candidate.jar')==m['jar'] and sha(a/'TemporalCapture.java')==m['captureJava']
for i,x in m['captureClasses'].items():assert sha(a/i)==x
def write(p,o):
 tmp=p.with_suffix(p.suffix+'.tmp');tmp.write_text(json.dumps(o,sort_keys=True,indent=2)+'\n');tmp.replace(p)
def memory():return float(next(l for l in Path('/proc/meminfo').read_text().splitlines() if l.startswith('MemAvailable:')).split()[1])/1048576
q=queue.Queue()
for s in m['shards']:
 if not (r/(s['name']+'.receipt.json')).exists():q.put(s)
def worker(cpu):
 ps=None;log=None
 def close():
  nonlocal ps,log
  if ps:
   if ps.poll() is None:ps.stdin.close()
   ps.wait();log.close();ps=log=None
 try:
  while True:
   try:s=q.get_nowait()
   except queue.Empty:return
   name=s['name'];job=a/'jobs'/(name+'.tsv');assert sha(job)==s['sha256']
   for attempt,heap in enumerate([450,850,1600]):
    if attempt:close()
    while memory()<6+(heap/1024):time.sleep(3)
    if not ps:
     log=(a/'logs'/f'cpu-{cpu}-{time.time_ns()}.log').open('wb')
     cmd=['nice','-n','12','taskset','-c',str(cpu),'java','-Xms150m',f'-Xmx{heap}m','-XX:+UseParallelGC','-XX:ParallelGCThreads=1','-XX:ActiveProcessorCount=1','-Dorg.slf4j.simpleLogger.defaultLogLevel=warn','-cp',f'{a}/classes:{v}/engine/candidate.jar:{w}/frozen/lib/*','is.fivefivefive.CanDis.TemporalCapture',str(w/'frozen/classified-data'),str(r),'12']
     ps=subprocess.Popen(cmd,stdin=subprocess.PIPE,stdout=subprocess.PIPE,stderr=log,text=True,bufsize=1)
    raw=r/'inflight'/(name+'.jsonl')
    if raw.exists():raw.rename(raw.with_suffix('.before-'+str(time.time_ns())))
    start=time.time();ps.stdin.write(f'{name}\t{job}\t0\n');ps.stdin.flush()
    answer=ps.stdout.readline()
    if not answer:
     close();continue
    ack=json.loads(answer);assert ack['shard']==name and ack['rows']==ack['newRows']==s['rows']
    classified=collections.Counter()
    out=r/(name+'.jsonl.gz');tmp=out.with_suffix('.gz.tmp')
    with raw.open('rb') as source,tmp.open('wb') as f,gzip.GzipFile(filename='',mode='wb',fileobj=f,compresslevel=3,mtime=0) as gz:
     for line in source:
      row=json.loads(line);classified[row['status']]+=1;gz.write(line)
    assert sum(classified.values())==s['rows'];tmp.replace(out)
    write(r/(name+'.receipt.json'),dict(captureStarted=start,end=time.time(),raw=sha(raw),compressed=sha(out),native=dict(classified),cpu=cpu,jvm=ps.pid,ack=ack,manifest=sha(a/'manifest.json'),input=s['sha256'],jar=m['jar']))
    raw.unlink();break
   else:raise RuntimeError('Continued JVM failure: '+name)
 finally:close()
with concurrent.futures.ThreadPoolExecutor(max_workers=18) as ex:
 fs=[ex.submit(worker,n) for n in range(18)]
 for future in concurrent.futures.as_completed(fs):future.result()
write(a/'captured.json',dict(rows=sum(s['rows'] for s in m['shards']),shards={s['name']:sha(r/(s['name']+'.receipt.json')) for s in m['shards']},manifest=sha(a/'manifest.json'),runtime=sha(Path(__file__)),jar=m['jar']))
