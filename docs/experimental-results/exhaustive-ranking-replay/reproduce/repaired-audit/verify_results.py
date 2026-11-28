"""Audit raw native receipts against every published ranking leaf and emit a compact, indexed witness archive."""
import argparse, collections, csv, datetime, gzip, hashlib, itertools, json, os, re, shutil, sys, tempfile
from contextlib import ExitStack
from pathlib import Path
from verify_inputs import check,sha,atomic,jsonfile,verify as verify_inputs
from native_commitment import SerializedNumber,check_programs
from registry import ORIGINAL_INPUT,inspect as register_candidate,select as registered_selection


REGISTERED_COHORT='074fbe5573ccf33de100f85cc14a7d0f33c297271b933401ee061d066da99ff5'
HEX=re.compile(r'[0-9a-f]{64}')
UUID=re.compile(r'[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}')
FLAGS=('endpointCorrespondenceChecked','sourceCertificatesChecked','fixedChoiceReplaysChecked','nativeSequencesEqual')
FIELDS=('kind','left','leftPredicate','right','rightPredicate')
def proper_int(n):return type(n) is int and n>=0
def hash_ok(s):return isinstance(s,str) and HEX.fullmatch(s) is not None
def check_native(r,expected):
    if r.get('status')!='MATCHED' or r.get('reason')!='CHECKED_NATIVE_ACTIONS_EQUAL':return False
    if any(r.get(k) is not True for k in FLAGS) or any(not proper_int(r.get(k)) or r[k]!=expected for k in ('fastDistance','certifiedDistance')):return False
    if not hash_ok(r.get('fastSequenceSha256')) or r['fastSequenceSha256']!=r.get('certifiedSequenceSha256'):return False
    if 'firstDifference' in r:return False
    if r.get('sequenceKind')=='FLAT_ACTIONS':
        if any(k in r for k in ('orderedBlockEffectsEqual','fastBlockCount','certifiedBlockCount')):return False
        a,b=r.get('fastActionCount'),r.get('certifiedActionCount')
    elif r.get('sequenceKind')=='TEMPORAL_BLOCK_EFFECTS':
        if r.get('orderedBlockEffectsEqual') is not True:return False
        a,b=r.get('fastBlockCount'),r.get('certifiedBlockCount')
    else:return False
    return proper_int(a) and proper_int(b) and a==b
def resolve_under(base,rel):
    q=(base/rel).resolve()
    check(isinstance(rel,str) and str(Path(rel))==rel and not Path(rel).is_absolute() and q.is_relative_to(base.resolve()),f'Untrusted external path: {rel}')
    return q
def check_incident(w,shard,ordinal,cells,r):
    rel=r.get('incidentPath');h=r.get('incidentSha256')
    check(isinstance(rel,str) and re.fullmatch(r'incidents/'+shard+'-'+str(ordinal)+'-'+UUID.pattern+r'\.json\.gz',rel) and hash_ok(h),'Malformed or substituted incident location')
    p=resolve_under(w/'results',rel);check(sha(p)==h,'Incident artifact SHA mismatch')
    with gzip.open(p,'rt') as f:a=json.load(f,parse_float=SerializedNumber)
    check(a.get('identity')=={k:v for k,v in r.items() if k not in ('incidentPath','incidentSha256')} and a.get('leftSha256')==cells[3] and a.get('rightSha256')==cells[6],'Native incident belongs to another selection')
    check('nativeComparatorEvidence' in a,'Missing native incident evidence')
    e=a['nativeComparatorEvidence']
    if e is not None:
        check(isinstance(e,dict),'Malformed native incident evidence')
        if r['status']!='WORKER_ERROR':
            check(e.get('status')==r['status'] and e.get('reason')==r['reason'],'Native incident status/reason mismatch')
            check_programs(e,r)
    elif r['status']!='WORKER_ERROR':raise ValueError('Missing full comparator evidence for returned status')
    if r['status']=='MISMATCH':
        check(e is not None and 'firstDifference' in e and e['firstDifference']==r.get('firstDifference') and e.get('endpointCorrespondenceChecked') is True and e.get('fixedChoiceReplaysChecked') is True,'No verified native divergence')
def native_rows(w,s,receipt):
    shard=s['id'];jobs=w/'cohort'/s['path'];ledger=w/'results'/f'{shard}.jsonl'
    digest,registered,identity=registered_selection(w/'runner-identity.json')
    plan=jsonfile(w/'plans/manifest.json')[shard]
    check(receipt['shard']==shard and receipt['identitySha256']==digest and receipt['jarSha256']==registered['jar'] and receipt['candidateRunId']==registered['uuid'] and receipt['engineCommit']==registered['commit'] and receipt['engineBuildReceiptSha256']==registered['build'] and receipt['originalScoreRunId']==identity['originalProducer']['runId'] and receipt['executionPlanSha256']==plan,'Native shard is bound to another verifier, execution order or score producer')
    check(receipt['inputSha256']==s['sha256']==sha(jobs) and receipt['rows']==s['rows'],'Incorrect shard input hash/length')
    check(0<=receipt['resumedRows']<=s['rows'] and receipt['measurement']['shard']==shard and receipt['measurement']['rows']==s['rows'] and receipt['measurement']['newRows']==s['rows']-receipt['resumedRows'],'Returned incomplete execution extent')
    check(datetime.datetime.fromisoformat(receipt['finishedAt'])>=datetime.datetime.fromisoformat(receipt['startedAt']),'Invalid shard time interval')
    count=collections.Counter();output_hash=hashlib.sha256()
    with jobs.open('rb') as fp,ledger.open('rb') as results:
        for ordinal,(job,line) in enumerate(itertools.zip_longest(fp,results)):
            check(job is not None and line is not None and line.endswith(b'\n'),f'Missing/extra/truncated native output at {shard}:{ordinal}')
            output_hash.update(line);cells=job[:-1].decode().split('\t')
            r=json.loads(line);expected=int(cells[7])
            check(tuple(r[k] for k in FIELDS)==tuple(cells[i] for i in (0,1,2,4,5)) and type(r['ordinal']) is int and r['ordinal']==ordinal and type(r['expected']) is int and r['expected']==expected,'Native output identity/score differs from original input')
            passed=check_native(r,expected)
            check(type(r.get('checked')) is bool and r['checked']==passed,'Producer/verifier disagreement on validation')
            check(isinstance(r.get('reason'),str) and r['reason'],'Missing native reason')
            check(r['status'] in ('MATCHED','MISMATCH','INVALID_REPLAY','UNCHECKABLE','ERROR','WORKER_ERROR'),'Unknown native result')
            state='UNBOUND_MATCH' if r['status']=='MATCHED' and not passed else r['status']
            if not passed:check_incident(w,shard,ordinal,cells,r)
            else:check('incidentPath' not in r and 'incidentSha256' not in r,'Unexpected incident pointer on a successful replay')
            count[state]+=1
            yield cells,r,state
    check(sum(count.values())==s['rows'] and dict(count)==receipt['statusCounts'] and output_hash.hexdigest()==receipt['outputSha256'],'Shard output digest, count or aggregate differs: '+shard)

def open_gz(stack,path):
    raw=stack.enter_context(path.open('xb'))
    return stack.enter_context(gzip.GzipFile(filename='',fileobj=raw,mode='wb',mtime=0,compresslevel=6))
def encode(x):return (json.dumps(x,separators=(',',':'),ensure_ascii=False)+'\n').encode()
class Compact:
    def __init__(self,base,incident_root):
        self.incident_root=incident_root;(base/'incidents').mkdir()
        self.root=base;self.stack=ExitStack();self.chunk_stack=ExitStack();self.index=open_gz(self.stack,base/'source-index.tsv.gz')
        self.incidents=open_gz(self.stack,base/'nonmatching.jsonl.gz');self.chunks=[];self.group=None;self.edge=[];self.file=None;self.n=0;self.submissions=0;self.known=set()
        self.index.write(b'source\tchunk\tuncompressedOffset\tcomparisons\n')
    def flush_source(self):
        if not self.edge:return
        if self.file is None or self.n+len(self.edge)>100000:
            self.end_chunk();name=f'native-ranking-{len(self.chunks):03d}.jsonl.gz';self.file=open_gz(self.chunk_stack,self.root/name);self.n=0;self.submissions=0;self.name=name
        source=self.group;check(source not in self.known,'Repeated noncontiguous source in compact archive')
        check([r[0] for r in self.edge]==sorted({r[0] for r in self.edge}),'Rank IDs duplicated or misordered')
        self.known.add(source);self.index.write(f'{source}\t{self.name}\t{self.file.tell()}\t{len(self.edge)}\n'.encode())
        self.file.write(encode([source,self.edge]));self.n+=len(self.edge);self.submissions+=1;self.edge=[]
    def end_chunk(self):
        if self.file is None:return
        self.chunk_stack.close();self.chunk_stack=ExitStack()
        file=self.root/self.name
        self.chunks.append(dict(path=file.name,rows=self.n,submissions=self.submissions,sha256=sha(file),bytes=file.stat().st_size))
        self.file=None
    def add(self,cells,r,state,i,shard):
        source=cells[1]
        if source!=self.group:
            self.flush_source();self.group=source
        if state=='MATCHED':
            m='F' if r['sequenceKind']=='FLAT_ACTIONS' else 'T';count=r['fastActionCount'] if m=='F' else r['fastBlockCount']
            self.edge.append([i,m,count,r['fastSequenceSha256']])
        else:
            self.edge.append([i,'!',r['incidentSha256']])
            src=self.incident_root/r['incidentPath'];dest=self.root/r['incidentPath']
            try:os.link(src,dest)
            except OSError:shutil.copyfile(src,dest)
            check(sha(dest)==r['incidentSha256'],'Changed incident during archival')
            self.incidents.write(encode({'shard':shard,'referenceId':i,'leftSha256':cells[3],'rightSha256':cells[6],'observation':r}))
    def close(self):
        self.flush_source();self.end_chunk();self.stack.close()
def audit(w,partial,selected,output):
    full=not partial and not selected
    meta,identity=register_candidate(w,plans=full)
    digest,registered,_=registered_selection(w/'runner-identity.json')
    baseline=(w/'cohort').resolve().parent
    check((w/'original-inputs').resolve()==(baseline/'frozen').resolve(),'Unregistered original source root')
    if full:
        input_result=verify_inputs(baseline,w/'cohort')
        check(input_result['status']=='VERIFIED' and input_result['manifestSha256']==REGISTERED_COHORT,'Input check failed')
    else:
        input_result=jsonfile(w/'cohort/input-recount.json')
        check(input_result['status']=='VERIFIED' and input_result['manifestSha256']==REGISTERED_COHORT,'Previously validated inputs unbound')
    refs={(r['source'],r['predicate']):int(r['referenceId']) for r in csv.DictReader((w/'cohort/reference-catalog.tsv').open(),delimiter='\t')}
    expected={s['id'] for s in meta['shards']};done={f.name.removesuffix('.receipt.json') for f in (w/'results').glob('shard-*.receipt.json')}
    check(done<=expected,'Unregistered native shard receipt')
    scope=set(selected) if selected else done if partial else expected
    check(scope<=expected and scope<=done,'Native shard receipts missing')
    if full:
        check(done==expected and {f.stem for f in (w/'results').glob('shard-*.jsonl')}==expected,'Cohort ledger files missing or unexpected')
    compact=Compact(output,w/'results') if output else None
    failure=collections.Counter();modes=collections.Counter();total=0;shard_records=[]
    for s in meta['shards']:
        shard=s['id']
        if shard not in scope:continue
        p=w/f'results/{shard}.receipt.json';receipt=jsonfile(p)
        for cells,r,state in native_rows(w,s,receipt):
            total+=1
            if state=='MATCHED':modes[r['sequenceKind']]+=1
            else:failure[state,r['reason']]+=1
            if compact:compact.add(cells,r,state,refs[cells[4],cells[5]],shard)
        shard_records.append(dict(shard=shard,rows=s['rows'],inputSha256=s['sha256'],resultSha256=receipt['outputSha256'],receiptSha256=sha(p),planSha256=receipt['executionPlanSha256']))
    if compact:compact.close()
    check(total==sum(s['rows'] for s in meta['shards'] if s['id'] in scope),'Recount differs from shard populations')
    infra=any(k[0]=='WORKER_ERROR' for k in failure)
    state='INFRASTRUCTURE_FAILURE' if infra else 'BLOCKED' if failure else 'VERIFIED' if full else 'PARTIAL'
    answer=dict(status=state,complete=full,releaseCommit=meta['releaseCommit'],measuredCommit=registered['commit'],
                measuredJarSha256=registered['jar'],candidateRunId=registered['uuid'],sourceRunId=identity['originalProducer']['runId'],originalScoreCommit=meta['measuredCommit'],originalScoreJarSha256=meta['jarSha256'],inputManifestSha256=REGISTERED_COHORT,
                producerIdentitySha256=digest,executionPlansSha256=registered['plan'],candidateBuildReceiptSha256=registered['build'],inputCheckerSha256=input_result['checkerSha256'],checkerSha256=sha(Path(__file__).resolve()),orderedProgramCheckerSha256=sha(Path(__file__).resolve().with_name('native_commitment.py')),
                required=len(expected),shardsChecked=len(scope),rows=total,checkedOrderedNativeWitnesses=sum(modes.values()),matchedModes=dict(modes),
                nonconforming=sum(failure.values()),failures=[dict(status=k,reason=r,count=n) for (k,r),n in sorted(failure.items())])
    if output:
        check(len(compact.known)==42386 and total==1894168,'Incomplete compact release output')
        shutil.copyfile(w/'plans/manifest.json',output/'execution-plan-hashes.json')
        atomic(output/'shard-bindings.json',shard_records)
        answer.update(schema='candidate-exhaustive-native-ranking-commitments-v1',submissions=len(compact.known),references=4496,
                      declaredMatches=dict(status='MATCHED',reason='CHECKED_NATIVE_ACTIONS_EQUAL',endpointCorrespondenceChecked=True,
                          fixedChoiceReplaysChecked=True,sourceCertificatesChecked=True,nativeSequencesEqual=True),
                      sequences={'F':'FLAT_ACTIONS','T':'TEMPORAL_BLOCK_EFFECTS','!':'nonconforming native replay, full incident digest follows'},
                      chunks=compact.chunks,sourceIndexSha256=sha(output/'source-index.tsv.gz'),nonmatchingSha256=sha(output/'nonmatching.jsonl.gz'),shardBindingsSha256=sha(output/'shard-bindings.json'))
        atomic(output/'summary.json',answer)
    return answer
if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--workspace',type=Path,required=True);p.add_argument('--partial',action='store_true');p.add_argument('--shard',action='append',default=[]);p.add_argument('--output',type=Path)
    args=p.parse_args()
    if (args.partial or args.shard) and args.output:p.error('Complete final recount required for release packaging')
    output=args.output or args.workspace/'independent-final';stage=None
    try:
        if not (args.partial or args.shard):
            check(not output.exists(),'Final output must be a new directory')
            stage=Path(tempfile.mkdtemp(prefix='.'+output.name+'.',dir=output.parent))
        result=audit(args.workspace,args.partial,args.shard,stage)
        if stage:stage.rename(output);stage=None
        print(json.dumps({k:v for k,v in result.items() if k not in ('chunks','declaredMatches','sequences')},sort_keys=True))
        if result['status'] in ('INFRASTRUCTURE_FAILURE','BLOCKED'):sys.exit(2)
    except Exception as error:
        print('INFRASTRUCTURE_FAILURE: '+str(error),file=sys.stderr);raise
    finally:
        if stage:shutil.rmtree(stage,ignore_errors=True)
