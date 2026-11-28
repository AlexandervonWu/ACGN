"""Recount every original protected edge and command against actually emitted candidate native receipts."""
from collections import Counter
import csv,gzip,hashlib,itertools,json
from pathlib import Path
import sys
P=Path(__file__).resolve().parent;W=P.parent;sys.path.insert(0,str(W/'cohort'))
from verify_inputs import atomic,sha,check,jsonfile
from verify_results import check_native,proper_int
from native_commitment import check_programs,SerializedNumber
def scoped(j,row):
    expected={k:v for k,v in j['scoped'].items() if v is not None}
    scope=dict(row.get('scope',{}));native=scope.pop('native',None)
    hit=scope.get('scopeStatus')=='FIXED_COMMAND_RULE'
    if scope!=expected or native!=('UNSAT' if hit else None if scope.get('scopeStatus')=='NO_COMMON_COMMAND' else 'NOT_RUN'):return False
    if j['kind']=='fixed':return hit and bool(scope.get('rules'))
    return not hit and proper_int(row.get('fastDistance')) and row['fastDistance']>0 and row['fastDistance']==row.get('certifiedDistance')
def verdict(t,raw,row):
    j=json.loads(raw);kind=j['kind'];expected=j.get('expected')
    check(hashlib.sha256(raw).hexdigest()==row['inputSha256'] and (row['kind'],row['a'],row['b'])==(kind,j['a'],j['b']),'Wrong original endpoints, roles or job SHA')
    if kind in ('paired','zero'):
        native=check_native(row,expected)
        state='MATCHED' if native else ('SCALAR_DRIFT' if row['status']=='MATCHED' and (row.get('fastDistance'),row.get('certifiedDistance'))!=(expected,expected) else 'UNBOUND_MATCH' if row['status']=='MATCHED' else row['status'])
        if kind=='paired' and native:
            fv=row.get('scanFast',[]);cv=row.get('scanCertified',[])
            bound=(row.get('scanCostBindingChecked') is True and isinstance(fv,list) and len(fv)==4 and all(proper_int(n) for n in fv) and fv==cv and fv[0]==sum(fv[1:])==expected)
            if not bound:state='INVALID_SCAN_BINDING'
            elif row.get('commands')!=j['commands']:state='CHANGED_ORIGINAL_COMMAND'
    else:
        state='SCOPE_RETAINED' if scoped(j,row) and row['status']=='SCOPE_RETAINED' else row['status']
        check(state!='SCOPE_RETAINED' or scoped(j,row),'Wrong declared surviving command')
    positive=state in ('MATCHED','SCOPE_RETAINED');check(row.get('accepted') is positive,'Candidate checker and independent audit disagree')
    if not positive:
        fname=row['incident'];d=t/'results'/fname
        check(d.resolve().is_relative_to((t/'results/incidents').resolve()) and sha(d)==row['incidentSha256'],'Native failure archive changed')
        with gzip.open(d,'rt') as f:rec=json.load(f,parse_float=SerializedNumber)
        check(rec['job']==j and rec['originalObservation']=={k:v for k,v in row.items() if k not in ('incident','incidentSha256')},'Loss receipt belongs to another job')
        if rec['comparator'] is not None and row['status']!='WORKER_ERROR':
            check((row['status'],row['reason'])==(rec['comparator']['status'],rec['comparator']['reason']),'Lost native status or reason')
            check_programs(rec['comparator'],row)
    else:check('incident' not in row and 'incidentSha256' not in row,'Unexpected positive failure pointer')
    return state
def each(t,s,receipt):
    jobs=P/s['path'];out=t/'results'/jobs.name;digest=hashlib.sha256();n=0
    check((receipt['shard'],receipt['identitySha256'],receipt['candidateJarSha256'],receipt['inputSha256'])==(jobs.stem,sha(t/'identity.json'),jsonfile(t/'identity.json')['candidateJarSha256'],sha(jobs)) and receipt['inputSha256']==s['sha256'],'Unbound candidate shard')
    with jobs.open('rb') as jf,out.open('rb') as rf:
        for i,(job,line) in enumerate(itertools.zip_longest(jf,rf)):
            check(job and line and line.endswith(b'\n'),'Missing, truncated or extraneous native row');digest.update(line)
            row=json.loads(line);check(type(row['ordinal']) is int and row['ordinal']==i,'Reordered native observation');state=verdict(t,job,row)
            n+=1;yield json.loads(job),row,state
    check(receipt['outputSha256']==digest.hexdigest() and n==s['rows']==receipt['rows'],'Wrong paired/ref shard coverage or hash')
def audit_shard(t,s,receipt):
    states=Counter(state for _,_,state in each(t,s,receipt))
    if 'observed' in receipt:check(dict(states)==receipt['observed'],'Wrong shard state counts')
    return states
class Classes:
    def __init__(self):self.parents={}
    def root(self,a):
        while a!=self.parents.get(a,a):
            b=self.parents[a];self.parents[a]=self.parents.get(b,b);a=b
        return a
    def join(self,a,b):
        self.parents.setdefault(a,a);self.parents.setdefault(b,b);self.parents[self.root(a)]=self.root(b)
    def equal(self,a,b):return self.root(a)==self.root(b)
    def pairs(self):
        return sum(n*(n-1)//2 for n in Counter(self.root(a) for a in self.parents).values())
def recount(t):
    from run import registered
    from prepare import make
    reg=registered(t);make();meta=jsonfile(P/'manifest.json');states=Counter();kinds=Counter();mode=Counter();stats=Counter()
    graph=Classes();global_graph=Classes();sat=[];receipts=[];loss=[];seen=set()
    expected={Path(s['path']).stem for s in meta['shards']}
    check(expected=={p.name.removesuffix('.receipt.json') for p in (t/'results').glob('*.receipt.json')}=={p.stem for p in (t/'results').glob('*.jsonl')},'Unaccounted shard inputs or results')
    for s in meta['shards']:
        name=Path(s['path']).stem;path=t/'results'/(name+'.receipt.json');rec=jsonfile(path);c=Counter()
        for j,r,state in each(t,s,rec):
            kind=j['kind'];key=(kind,*j['a'][:2],*j['b'][:2])
            check(key not in seen,'Duplicated native selection');seen.add(key);c[state]+=1;states[state]+=1;kinds[kind]+=1
            passed=r['accepted']
            if not passed:loss.append(dict(shard=name,ordinal=r['ordinal'],kind=kind,a=j['a'][:2],b=j['b'][:2],state=state,reason=r.get('reason'),incident=r['incident'],incidentSha256=r['incidentSha256']))
            if kind in ('zero','paired') and passed:
                mode[kind+':'+r['sequenceKind']]+=1
                if j['slotted']:stats['originalSlotted'+kind.capitalize()]+=1
                if j['expected']==0:stats[kind+'StructuralZero']+=1
                if kind=='paired':stats['pairedFixedCommand']+=sum(d['basis']=='FIXED_COMMAND_RULE' for d in r['commands'])
            if kind=='zero' and passed:
                global_graph.join(j['a'][5],j['b'][5]);graph.join(j['a'][5],j['b'][5])
            if kind=='fixed' and passed:graph.join(j['a'][5],j['b'][5]);stats['poolFixedCommand']+=1
            if kind=='sat-control':sat.append((j['a'][5],j['b'][5]))
        check(dict(c)==rec['observed'],'Incorrect shard summaries')
        receipts.append(dict(shard=name,receiptSha256=sha(path),inputSha256=s['sha256'],outputSha256=rec['outputSha256']))
    check(dict(kinds)==meta['totals'] and len(seen)==82208,'Incomplete protected source cohort')
    connected=[v for v in sat if graph.equal(*v)]
    stats.update({'poolStructuralComponentPairs':global_graph.pairs(),'poolCommandComponentPairs':graph.pairs(),'previousSatControls':len(sat)})
    if not loss:
        want=dict(originalSlottedPaired=2228,originalSlottedZero=8952,pairedStructuralZero=5137,zeroStructuralZero=19271,pairedFixedCommand=347,poolFixedCommand=1234,poolStructuralComponentPairs=19271,poolCommandComponentPairs=20629,previousSatControls=105)
        check(stats==want,'Native/direct/component history does not reproduce expected inventories')
    atomic(t/'losses.json',loss);atomic(t/'shard-bindings.json',receipts)
    status='INFRASTRUCTURE_FAILURE' if states['WORKER_ERROR'] else 'BLOCKED' if loss or connected else 'VERIFIED'
    out=dict(status=status,complete=True,sourceCommit=reg['candidateCommit'],candidateJarSha256=reg['candidateJarSha256'],candidateRunId=reg['runId'],identitySha256=sha(t/'identity.json'),inputManifestSha256=sha(P/'manifest.json'),originalScoreProducer=reg['originalScoreRunId'],cohorts=dict(kinds),nativeObservations=dict(states),matchedModes=dict(mode),historical=dict(stats),connectedHistoricalSatControls=connected,nonconforming=len(loss),lossLedgerSha256=sha(t/'losses.json'),receiptLedgerSha256=sha(t/'shard-bindings.json'),completedShards=len(expected),checkerSha256=sha(Path(__file__)))
    atomic(t/'verification.json',out);return out
if __name__=='__main__':print(json.dumps(recount(Path(sys.argv[1]).resolve()),sort_keys=True))
