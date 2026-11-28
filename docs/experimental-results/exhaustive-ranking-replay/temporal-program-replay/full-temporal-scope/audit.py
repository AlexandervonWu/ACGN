"""Hash and examine every source-bound temporal program on both arms, retaining raw lineage identifiers."""
import collections,concurrent.futures,csv,gzip,hashlib,io,itertools,json,os,re,sys,time
from pathlib import Path
A=Path(__file__).resolve().parent
W=A.parent
R=A/'results';OUT=A/'audit'
sys.path.insert(0,str(W/'cohort'))
from native_commitment import canonical, check_programs, SerializedNumber
from verify_results import check_native
from verify_inputs import sha,jsonfile
def check(c,msg):
    if not c:raise ValueError(msg)
def readrows(p):
    with p.open() as f:return [json.loads(l) for l in f]
def write(p,obj):
    tmp=p.with_suffix(p.suffix+'.tmp');tmp.write_text(json.dumps(obj,indent=2,sort_keys=True)+'\n');tmp.replace(p)
def enc(x):return json.dumps(x,separators=(',',':'),ensure_ascii=False)
def refs_check(row, a, source, target):
    return (row['left'],row['leftPredicate'],row['right'],row['rightPredicate'],row['ordinal'],row['expected'])==(a[2],a[8],a[10],a[11],a[1],a[-1]) and source==a[9] and target==a[12]

def find_labels(blocks):
    found=[];suspicious=[]
    def scan(obj,path,local=False):
        if isinstance(obj,dict):
            for k,v in obj.items():
                p=path+(k,)
                if local and k=='sourceOccurrence':
                    check(type(v) is int and v>=0,'Invalid sourceOccurrence scalar')
                    found.append([p,v])
                scan(v,p,k=='localBinding')
        elif isinstance(obj,list):
            for i,v in enumerate(obj):scan(v,path+(i,))
        elif isinstance(obj,str):
            value=obj.strip()
            if value and value[0] in '{["':
                try:inner=json.loads(value)
                except (ValueError,RecursionError):
                    if 'localBinding' in value and 'sourceOccurrence' in value:suspicious.append([path,obj])
                else:
                    if inner!=obj:scan(inner,path+('<encoded-json>',),local)
            elif 'localBinding' in value and 'sourceOccurrence' in value:
                suspicious.append([path,obj])
    scan(blocks,())
    return found,suspicious

def relevant(path):
    return len(path)>1 and path[1]=='effect'
def worker(params):
    n,s,selected,mhash,gate,driverhash=params
    os.sched_setaffinity(0,set(range(18,28)));os.nice(1)
    ck=R/(n+'.receipt.json');receipt=jsonfile(ck);data=R/(n+'.jsonl.gz')
    check(receipt['jar']==gate and receipt['manifest']==mhash and receipt['input']==s['sha256'] and receipt['compressed']==sha(data),'Invalid capture receipt')
    footprint=hashlib.sha256();modes=collections.Counter();witness=[]
    compact=OUT/(n+'.jsonl.gz');tmp=compact.with_suffix('.tmp')
    with gzip.open(data,'rb') as f,tmp.open('wb') as raw,gzip.GzipFile(filename='',mode='wb',fileobj=raw,mtime=0,compresslevel=6) as g:
        for z,line in itertools.zip_longest(selected,f):
            check(z is not None and line and line.endswith(b'\n'),'Missing or additional native result')
            footprint.update(line)
            row=json.loads(line,parse_float=SerializedNumber); origshard,origord=z[4:6]; blockcount,archived=z[6:8]
            check(refs_check(row,z,z[9],z[12]),'Different original endpoints, ordinals or numeric rank')
            src=(W/'frozen/classified-data')/z[2]; tgt=(W/'frozen/classified-data')/z[10]
            check(sha(src)==z[9] and sha(tgt)==z[12],'Changed original endpoint')
            check(row['sequenceKind']=='TEMPORAL_BLOCK_EFFECTS' and row['checked'] and check_native(row,z[-1]),'Native checks failed')
            check_programs(row,row)
            check(row['fastBlockCount']==row['certifiedBlockCount']==blockcount,'Block count drift')
            h=row['fastSequenceSha256']; modes['rows']+=1;modes['strictRawUnchanged' if h==archived else 'strictRawChanged']+=1
            found={};susp={}
            possible=(b'localBinding' in line and b'sourceOccurrence' in line) or b'\\u' in line
            for arm in ('fast','certified'):
                found[arm],susp[arm]=find_labels(row[arm+'Blocks']) if possible else ([],[])
            check(not any(susp.values()),'Unclassified nested text with potential local-variable occurrence: '+str(z[:7])+': '+str(susp)[:2400])
            effects={arm:[v for v in ls if relevant(v[0])] for arm,ls in found.items()}
            check(effects['fast']==effects['certified'],'Local-variable effects differ between native arms')
            has=bool(effects['fast']);anywhere=any(found.values())
            modes['withCommittedLocalOccurrence']+=has;modes['withAnyNativeBlockLocalOccurrence']+=anywhere
            cell='labelled' if has else 'unlabelled';modes[cell+('RawEqual' if h==archived else 'RawDifferent')]+=1
            roles=sorted(set('source' if 'source' in p else 'target' if 'target' in p else 'other' for p,v in effects['fast']))
            rawsha=hashlib.sha256(line).hexdigest()
            payload=[z[2],z[3],z[8],z[9],z[10],z[11],z[12],z[-1],origshard,origord,blockcount,archived,row['fastSequenceSha256'],row['certifiedSequenceSha256'],rawsha,len(effects['fast']),len(found['fast']),len(found['certified']),roles]
            g.write((enc(payload)+'\n').encode())
            if anywhere or h!=archived:
                witness.append(dict(pair=[z[2],z[3]],capture=[n,z[1]],original=[origshard,origord],fresh=h,archived=archived,roles=roles,
                                    localOccurrencePaths=found,canonicalEffectOccurrences=effects['fast'],rawRowSha256=rawsha))
    check(footprint.hexdigest()==receipt['raw'] and modes['rows']==s['rows'],'Incorrect native raw length or hash')
    tmp.replace(compact)
    witness_file=OUT/(n+'.labels.jsonl.gz')
    with witness_file.open('wb') as f,gzip.GzipFile(filename='',mode='wb',fileobj=f,mtime=0) as g:
        for x in witness:g.write((enc(x)+'\n').encode())
    write(OUT/(n+'.json'),dict(counts=dict(modes),labels=sha(witness_file),summary=sha(compact),capture=sha(data),captureReceipt=sha(ck),input=s['sha256'],evidenceJar=gate,rawRows=footprint.hexdigest(),auditCode=driverhash))
    return n

def main():
    OUT.mkdir(exist_ok=True); m=jsonfile(A/'manifest.json'); ms=sha(A/'manifest.json'); code=sha(Path(__file__)); lookup=collections.defaultdict(list)
    for row in readrows(A/'expected.jsonl'):lookup[row[0]].append(row)
    specs={s['name']:s for s in m['shards']}; pending=set(specs);busy={}
    with concurrent.futures.ProcessPoolExecutor(max_workers=8) as ex:
        while pending or busy:
            for f in list(busy):
                if f.done():name=f.result();check(name==busy.pop(f),'Wrong child acknowledgement')
            for n in sorted(pending):
                if (R/(n+'.receipt.json')).exists() and len(busy)<12:
                    pending.remove(n);f=ex.submit(worker,(n,specs[n],lookup[n],ms,m['jar'],code));busy[f]=n
            if pending or busy:time.sleep(2)
    counts=collections.Counter(); binds={}
    for n in sorted(specs):
        p=OUT/(n+'.json');v=jsonfile(p);counts.update(v['counts']);binds[n]=sha(p);check(v['auditCode']==code and v['evidenceJar']==m['jar'],'Changed audit code or candidate')
    check(counts['rows']==26673,'Incomplete supplementary cohort')
    write(A/'recount.json',dict(checked=dict(counts),shards=binds,jar=m['jar'],commit=m['commit'],fullRankingInputs=1894168,fullTemporalRows=26673,selectedManifest=ms,auditCode=code))
if __name__=='__main__':main()
