"""One read-only observation of the 2026-11-27 reboot recovery of final ranking."""
import collections
import datetime as dt
import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys
import zipfile

w = Path(sys.argv[1]).resolve()
out = Path(sys.argv[2]).resolve()
def h(b):
    return hashlib.sha256(b).hexdigest()
def filehash(p):
    with p.open('rb') as stream:
        state = hashlib.sha256()
        for block in iter(lambda: stream.read(1048576), b""):
            state.update(block)
        return state.hexdigest()
def load(p):
    return json.loads(p.read_bytes())
def require(ok, msg):
    if not ok:
        raise ValueError(msg)
def stamp(timestamp):
    return dt.datetime.fromtimestamp(timestamp,dt.timezone.utc).isoformat()
marker = w/'final-handoff/final-started.json'
expected_marker = '46d5aec5875f00a876bbda5db448e2357332017f276e72b8438e237eff8a049a'
require(filehash(marker)==expected_marker,'Final start marker changed')
mk = load(marker)
v = Path(mk['candidateRoot'])
ident = Path(mk['candidateIdentity'])
spec = load(ident)
co = v/'cohort'
res = v/'results'
manifest = load(co/'manifest.json')
plan = load(v/'plans/manifest.json')
boot = next(int(l.split()[1]) for l in Path('/proc/stat').read_text().splitlines() if l.startswith('btime '))
require(stamp(boot).startswith('2026-11-28T03:16:35'), 'Unexpected boot')
unit = mk['systemdUnit']
props = ('MainPID','ControlGroup','InvocationID','ActiveEnterTimestamp','ActiveState','FragmentPath')
cmd = ['systemctl','--user','show',unit] + [f'--property={p}' for p in props]
service=dict(l.split('=',1) for l in subprocess.check_output(cmd,text=True).splitlines())
require(service['ActiveState']=='active' and Path(service['FragmentPath']).resolve()==v/unit,'Wrong supervisor unit')
main = Path('/proc')/service['MainPID']
require((main/'cwd').resolve()==v and (main/'cmdline').read_bytes().split(b'\0')[1:3]==[b'-B',os.fsencode(v/'runner/supervise.py')],'Wrong supervisor command')
cp=f"{v}/runner-classes:{v}/engine/candidate.jar:{v}/original-inputs/lib/*"
cg=Path('/sys/fs/cgroup')/service['ControlGroup'].lstrip('/')
pids=[int(p) for p in (cg/'cgroup.procs').read_text().split()]
javas=[]
for pid in pids:
    d=Path('/proc')/str(pid)
    if (d/'comm').read_text().strip()!='java':
        continue
    args=(d/'cmdline').read_bytes().decode().rstrip('\0').split('\0')
    index=args.index('-cp')
    require(args[index+1:]==[cp,'is.fivefivefive.CanDis.ExhaustiveNativeReplay',str(v/'original-inputs/classified-data'),str(res),'2'],f'JVM {pid}: command')
    require((d/'cwd').resolve()==v and str((d/'exe').resolve())=='/usr/lib/jvm/java-17-openjdk-amd64/bin/java',f'JVM {pid}: current directory/executable')
    env_keys={x.split(b'=',1)[0] for x in (d/'environ').read_bytes().split(b'\0') if x}
    require(not env_keys.intersection({b'JAVA_TOOL_OPTIONS',b'_JAVA_OPTIONS',b'JDK_JAVA_OPTIONS'}),'JVM option injection')
    javas.append(pid)
require(len(javas)>0,'No live JVM')
binding={'candidateIdentity':'identitySha256','candidateBuildReceipt':'buildReceiptSha256','engineJar':'jarSha256',
         'expandedHistoricalFloor':'expandedFloorSha256','originalAttestation':'originalAttestationSha256',
         'originalInputRecount':'originalInputRecountSha256','preflightAudit':'preflightAuditSha256',
         'rootFreeze':'rootFreezeSha256','rootFreezeAuthority':'rootFreezeAuthoritySha256'}
for pathkey,hashkey in binding.items():
    require(filehash(Path(mk[pathkey]))==mk[hashkey],pathkey)
for path,expected in spec['files'].items():
    require(filehash(v/path)==expected,path)
classes=set(str(p.relative_to(v)) for p in (v/'runner-classes').rglob('*') if p.is_file())
require(classes=={p for p in spec['files'] if p.startswith('runner-classes/')},'Unexpected shadow classes')
libs=set(str(p.relative_to(v)) for p in (v/'original-inputs/lib').iterdir() if p.suffix.lower()=='.jar')
require(libs=={p for p in spec['files'] if p.startswith('original-inputs/lib/')},'Unregistered library')
require((v/'original-inputs').resolve()==(w/'frozen').resolve() and co.resolve()==w/'cohort','Input mapping')
require(filehash(co/'manifest.json')==spec['inputManifestSha256'] and filehash(w/'runner-identity.json')==spec['originalProducer']['baselineNativeRunnerIdentitySha256'],'Lost original producer authority')
require(manifest['measuredRunId']==spec['originalProducer']['runId']==mk['originalScoreRunId'] and manifest['jarSha256']==spec['originalProducer']['jarSha256'],'Original provenance')
require(mk['candidateRunId']==spec['candidateRunId'] and mk['commit']==spec['engine']['commit'] and mk['jarSha256']==spec['engine']['jarSha256'],'Final provenance')
require(manifest['rows']==spec['rows']==1894168 and len(manifest['shards'])==1059,'Cohort size')
dataset=v/'original-inputs/classified-data'
meta=manifest['dataset']
hd=hashlib.sha256()
size=0
sources={}
for p in sorted(dataset.rglob('*.als')):
    name=p.relative_to(dataset).as_posix()
    data=p.read_bytes()
    size+=len(data)
    sources[name]=h(data)
    hd.update(name.encode()+b'\0'+data+b'\xff')
require((len(sources),size,hd.hexdigest())==(meta['fileCount'],meta['bytes'],meta['sha256']),'Frozen corpus drift')
selected={}
for s in manifest['shards']:
    sid=s['id']
    require(filehash(co/s['path'])==s['sha256'] and filehash(v/'plans'/(sid+'.tsv'))==plan[sid],'Input or plan drift '+sid)
    selected[sid]=s
require(set(selected)==set(plan),'Nonexhaustive execution plans')
preboot=[]
for r in sorted(res.glob('*.receipt.json')):
    if r.stat().st_mtime<boot:
        preboot.append(r)
preboot_ids=set()
sealed=[]
status=collections.Counter()
valid_independent=0
unusable_independent=[]
for path in preboot:
    receipt=load(path)
    sid=receipt['shard']
    s=selected[sid]
    raw=res/(sid+'.jsonl')
    data=raw.read_bytes()
    checks=dict(inputSha256=s['sha256'],executionPlanSha256=plan[sid],identitySha256=mk['identitySha256'],
                jarSha256=mk['jarSha256'],engineCommit=mk['commit'],candidateRunId=mk['candidateRunId'],
                originalScoreRunId=mk['originalScoreRunId'],engineBuildReceiptSha256=mk['buildReceiptSha256'],
                rows=s['rows'],outputSha256=h(data))
    require(all(receipt.get(k)==expected for k,expected in checks.items()),'Bad preboot receipt '+sid)
    require(data.endswith(b'\n') and data.count(b'\n')==s['rows'] and sum(receipt['statusCounts'].values())==s['rows'] and receipt['measurement']['rows']==s['rows'],'Torn preboot shard '+sid)
    record_sha=filehash(path)
    ind_path=v/'independent-checkpoints'/(sid+'.json')
    try:
        ind=load(ind_path)
        require(ind['receiptSha256']==record_sha and ind['outputSha256']==checks['outputSha256'] and ind['rows']==s['rows'],'Independent checkpoint binding mismatch')
        valid_independent+=1
    except (ValueError,FileNotFoundError) as exc:
        unusable_independent.append(dict(shard=sid,error=str(exc),bytes=ind_path.stat().st_size if ind_path.is_file() else None))
    sealed.append([sid,s['rows'],record_sha,checks['outputSha256']])
    preboot_ids.add(sid)
    status.update(receipt['statusCounts'])
require(len(preboot_ids)==len(preboot),'Repeated receipt identity')
orphans=sorted(p.name for p in res.glob('*.jsonl') if p.stat().st_mtime<boot and p.stem not in preboot_ids)
require(not orphans,'Sealed ledger with no preboot receipt '+str(orphans))
summaries=[]
for line in (v/'resources.jsonl').read_bytes().splitlines():
    try:
        r=json.loads(line)
        if dt.datetime.fromisoformat(r['at']).timestamp()<boot:summaries.append(r)
    except ValueError:pass
for p in v.glob('progress.json.tmp-*'):
    if p.stat().st_mtime<boot:
        try:summaries.append(load(p))
        except ValueError:pass
latest=max(summaries,key=lambda r:r['at'])
require(latest['completedShards']==len(sealed),'Preboot checkpoint seals vs last observation')
partial=[]
for old in sorted(latest['running'],key=lambda r:r['shard']):
    sid=old['shard']
    s=selected[sid]
    require(sid not in preboot_ids,'Overlap')
    oldcount=old['rows']
    plan_fields=[l.split('\t') for l in (v/'plans'/(sid+'.tsv')).read_text().splitlines()]
    try:
        with (res/'inflight'/(sid+'.jsonl')).open('rb') as stream:
            data=stream.read(os.fstat(stream.fileno()).st_size)
        total=len(data.split(b'\n'))-1
        lines=data.split(b'\n')[:total]
        trailing=len(data)-data.rfind(b'\n')-1 if data else 0
        mode='INFLIGHT'
    except FileNotFoundError:
        data=(res/(sid+'.jsonl')).read_bytes()
        source_order=data.splitlines()
        lines=[source_order[int(fields[-1])] for fields in plan_fields]
        total=len(lines)
        trailing=0
        mode='SEALED_AFTER_BOOT'
    digest=hashlib.sha256()
    for i,line in enumerate(lines):
        row=json.loads(line);f=plan_fields[i]
        require(row['ordinal']==int(f[8]) and [row[k] for k in ('kind','left','leftPredicate','right','rightPredicate')]==[f[j] for j in (0,1,2,4,5)] and row['expected']==int(f[7]),'Broken inflight identity '+sid)
        require(sources[f[1]]==f[3] and sources[f[4]]==f[6],'Wrong endpoint '+sid)
        require(row['status']=='MATCHED' and row['reason']=='CHECKED_NATIVE_ACTIONS_EQUAL' and all(row[k] is True for k in ('checked','fixedChoiceReplaysChecked','endpointCorrespondenceChecked','sourceCertificatesChecked','nativeSequencesEqual')) and row['fastDistance']==row['expected']==row['certifiedDistance'] and len(row['fastSequenceSha256'])==64 and row['fastSequenceSha256']==row['certifiedSequenceSha256'],'Broken native commitments '+sid)
        if row['sequenceKind']=='FLAT_ACTIONS':
            require(type(row['fastActionCount']) is int and row['fastActionCount']==row['certifiedActionCount'],'Flat count '+sid)
        else:
            require(row['sequenceKind']=='TEMPORAL_BLOCK_EFFECTS' and row['orderedBlockEffectsEqual'] is True and type(row['fastBlockCount']) is int and row['fastBlockCount']==row['certifiedBlockCount'],'Temporal count '+sid)
        digest.update(line+b'\n')
    require(total<=s['rows'],'Oversized prefix '+sid)
    partial.append(dict(shard=sid,before=oldcount,checkedCompleteLines=total,storage=mode,prefixSha256=digest.hexdigest(),ignoredUnterminatedTailBytes=trailing))
details=out/'verified-seals.jsonl'
details.write_text(''.join(json.dumps(row,separators=(',',':'))+'\n' for row in sealed))
prefixes=out/'verified-recovered-prefixes.json'
prefixes.write_text(json.dumps(partial,sort_keys=True,indent=2)+'\n')
report=dict(schema='acgn-post-power-readonly-checkpoint-audit-v1',status='VERIFIED_PRODUCER_RECOVERY',observedAt=dt.datetime.now(dt.timezone.utc).isoformat(),
            bootId=Path('/proc/sys/kernel/random/boot_id').read_text().strip(),bootTime=stamp(boot),unit=unit,systemd=service,workerPidsAtObservation=sorted(javas),
            unitSha256=filehash(v/unit),actualJvmClasspath=cp,classpathRegisteredLibraries=len(libs),classpathRegisteredDriverClasses=len(classes),
            credentialFilesVerified=len(spec['files']),markerSha256=expected_marker,run=mk['candidateRunId'],commit=mk['commit'],jarSha256=mk['jarSha256'],
            runnerIdentitySha256=mk['identitySha256'],originalScoreRun=mk['originalScoreRunId'],manifestSha256=spec['inputManifestSha256'],
            originalInputsVerified=len(selected),plansVerified=len(plan),registeredRows=spec['rows'],dataset=meta,
            sealedPrebootShards=len(sealed),sealedPrebootRows=sum(row[1] for row in sealed),sealedPrebootStatus=dict(status),sealsSha256=filehash(details),sealedLedgerOrphans=orphans,
            independentReceiptsWithBothHashes=valid_independent,unusableIndependentAuxiliary=unusable_independent,
            lastPrebootTelemetryTime=latest['at'],lastPrebootReportedRows=latest['attemptedRows'],lastPrebootUnsealedReportedRows=sum(x['before'] for x in partial),
            affectedInflightShards=len(partial),recoveredInflightCheckedCompleteLines=sum(x['checkedCompleteLines'] for x in partial),
            recoveredShardsAtOrBeyondLastTelemetry=sum(x['checkedCompleteLines']>=x['before'] for x in partial),
            recoveredPrefixesSha256=filehash(prefixes),recoveryBoundary='Latest preboot telemetry contains counts only for partial shards. Inflight audit revalidates observed source identities, planned order, scalar distances, and native commitments read after reboot; any unflushed rows are eligible for recomputation. No historical prefix hash existed for independent byte-for-byte comparison.',
            auditSourceSha256=filehash(Path(__file__)))
(out/'receipt.json').write_text(json.dumps(report,indent=2,sort_keys=True)+'\n')
print(json.dumps({k:report[k] for k in ('sealedPrebootShards','sealedPrebootRows','affectedInflightShards','recoveredInflightCheckedCompleteLines','recoveredShardsAtOrBeyondLastTelemetry','independentReceiptsWithBothHashes','unusableIndependentAuxiliary','status')}))
