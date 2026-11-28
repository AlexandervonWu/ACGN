"""Make independently recounted compact candidate-retention evidence and the combined scope/trace verdict."""
import argparse
from contextlib import ExitStack
import csv,gzip,hashlib,io,itertools,json,os,shutil,tempfile
from pathlib import Path
import time
from recount import P,W,each,recount
from run import registered,sha,atomic,jsonfile,check

def verify_build(t):
    i=registered(t);b=jsonfile(t/'build-receipt')
    check(b['git']['commit']==i['candidateCommit'] and b['experimentJar']['sha256']==i['candidateJarSha256']==sha(t/'candidate.jar') and b['buildsByteIdentical'] is True,'Unbound candidate revision, checksum or independent rebuild')
    return i

def package(t):
    reg=verify_build(t)
    summary=recount(t)
    import importlib.util
    ac=P/'archived-commands/check.py';spec=importlib.util.spec_from_file_location('archived_verify',ac);module=importlib.util.module_from_spec(spec);spec.loader.exec_module(module)
    native=module.verify(t);meta=jsonfile(P/'manifest.json');release=t/'compact'
    if release.exists():
        checks=jsonfile(release/'SHA256.json')
        for pc,v in checks.items():check(sha(release/pc)==v,'Changed compact result')
        return jsonfile(release/'combined-verdict.json')
    with tempfile.TemporaryDirectory(dir=t,prefix='stage-') as d:
        root=Path(d);stage=root/'compact';stage.mkdir()
        def write_gz(stack,path):
            raw=stack.enter_context(path.open('xb'))
            return stack.enter_context(gzip.GzipFile(filename='',fileobj=raw,mode='wb',mtime=0,compresslevel=6))
        ledgerchecks={}
        with ExitStack() as stack:
            files={k:write_gz(stack,stage/(k+'.jsonl.gz')) for k in ('paired','zero','fixed','sat-control')}
            for s in meta['shards']:
                sp=Path(s['path']);rf=t/'results'/sp.with_suffix('.receipt.json').name
                for j,r,state in each(t,s,jsonfile(rf)):
                    out={'a':j['a'][:3],'b':j['b'][:3],'state':state}
                    if 'expected' in j:
                        out.update(expected=j['expected'],observedFast=r.get('fastDistance'),observedCertified=r.get('certifiedDistance'),slotted=j['slotted'])
                    if j['kind']=='paired':
                        out.update(components=r.get('scanFast'),scanCostBindingChecked=r.get('scanCostBindingChecked'),commands=r.get('commands'))
                    if j['kind']!='paired':out['referenceIds']=[j['a'][5],j['b'][5]]
                    if state=='MATCHED':
                        temporal=r['sequenceKind']=='TEMPORAL_BLOCK_EFFECTS'
                        out.update(sequenceKind=r['sequenceKind'],orderedLength=r['fastBlockCount' if temporal else 'fastActionCount'],sharedSha256=r['fastSequenceSha256'])
                    if 'scope' in r:out['scope']=r['scope']
                    if not r['accepted']:
                        out['incidentSha256']=r['incidentSha256'];out['incident']=r['incident']
                        dest=stage/r['incident'];dest.parent.mkdir(exist_ok=True);os.link(t/'results'/r['incident'],dest)
                    files[j['kind']].write((json.dumps(out,sort_keys=True,separators=(',',':'))+'\n').encode())
        for n in ('verification.json','losses.json','shard-bindings.json','identity.json','build-receipt'):
            shutil.copyfile(t/n,stage/n)
        with (t/'archived-commands/results.jsonl').open('rb') as raw,ExitStack() as stack:
            target=write_gz(stack,stage/'archived-original-command-results.jsonl.gz');shutil.copyfileobj(raw,target)
        shutil.copyfile(t/'archived-commands/receipt.json',stage/'archived-original-command-receipt.json')
        shutil.copyfile(t/'archived-commands/registration.json',stage/'archived-original-command-registration.json')
        verdict=dict(status='VERIFIED' if summary['status']==native['status']=='VERIFIED' else 'INFRASTRUCTURE_FAILURE' if summary['status']=='INFRASTRUCTURE_FAILURE' else 'BLOCKED',candidateSha256=reg['candidateJarSha256'],candidateCommit=reg['candidateCommit'],runIdentitySha256=sha(t/'identity.json'),originalInputSha256=sha(P/'manifest.json'),sourceNativeCommands=summary['cohorts'],nativeCheckedStates=summary['nativeObservations'],sourceHistory=summary['historical'],exactArchivedNativeOutcomes=native['native'],nonconformingNativeOrCommandJobs=summary['nonconforming'],connectedHistoricalSatControls=summary['connectedHistoricalSatControls'],originalCommandsWithUnexpectedResult=native['unexpected'],rawVerdictSha256=sha(t/'verification.json'))
        atomic(stage/'combined-verdict.json',verdict);atomic(stage/'SHA256.json',{str(f.relative_to(stage)):sha(f) for f in sorted(stage.rglob('*')) if f.is_file()});stage.rename(release)
    return verdict
if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('run',type=Path);p.add_argument('--wait',action='store_true');p.add_argument('--build-only',action='store_true')
    args=p.parse_args();root=args.run.resolve()
    if args.build_only:
        r=verify_build(root);print('VERIFIED',r['candidateCommit'],r['candidateJarSha256']);raise SystemExit
    if args.wait:
        while not (root/'verification.json').exists() or not (root/'archived-commands/receipt.json').exists():time.sleep(30)
    print(json.dumps(package(root),sort_keys=True))
