"""Verify a distributed exhaustive native-witness archive against the immutable original ranking export."""
import argparse
from array import array
from collections import Counter
import csv
import gzip
import hashlib
import json
from pathlib import Path
import re
import sys

from native_commitment import SerializedNumber, check_programs
from registry import select as registered_selection

RUNNER = 'a2cf64f0889624b0dc675b73d80f5b34caca2d73c9448b788713463b8abc3f02'
COHORT = '074fbe5573ccf33de100f85cc14a7d0f33c297271b933401ee061d066da99ff5'
JAR = 'a4c30092d064b8fa39011d888b2a9898a8b5060588e3356bb98e8ba34543217e'
BASE = Path('docs/experimental-results/historical-retention')
PUBLISHED = {
    'scores': (BASE/'ranking-scores.jsonl.gz', '5ca73249a44b97f9290a4bd12923802c808fddbf168564daaf8c04d373b14778'),
    'pairs': (BASE/'paired-comparisons.jsonl.gz', 'dc99a6ef526998e865c3c1bddd274088aa30faad86e165deaa528f602184bf0c'),
    'references': (Path('docs/experimental-results/2026-11-25/references.jsonl.gz'), 'a135caa38f3c6720fb5c00581fe4a72808068081c6e2a2d7b4f4e44ed3e51524'),
}
DIGEST = re.compile(r'[0-9a-f]{64}')
def demand(value, msg):
    if not value:
        raise ValueError(msg)
def sha(path):
    h=hashlib.sha256()
    with path.open('rb') as stream:
        for buf in iter(lambda: stream.read(1024*1024), b''):
            h.update(buf)
    return h.hexdigest()
def loadz(path):
    with gzip.open(path, 'rt') as f:
        yield from map(json.loads, f)
def real_digest(d):
    return type(d) is str and DIGEST.fullmatch(d) is not None
def originals(root):
    paths = {}
    for k, (rel, digest) in PUBLISHED.items():
        path = root/rel
        demand(sha(path)==digest, 'Published input changed: '+str(path))
        paths[k] = path
    return paths
def source_row_index(root):
    with gzip.open(root/'source-index.tsv.gz','rt',newline='') as stream:
        reader=csv.DictReader(stream,delimiter='\t')
        demand(reader.fieldnames==['source','chunk','uncompressedOffset','comparisons'],'Malformed native source index')
        yield from reader
def source_hashes(root, meta):
    original = root/'classified-data'
    digest=hashlib.sha256(); hashes={}; size=0
    for p in sorted(original.rglob('*.als')):
        name=p.relative_to(original).as_posix();data=p.read_bytes()
        digest.update(name.encode()+b'\0'+data+b'\xff');size+=len(data)
        hashes[name]=hashlib.sha256(data).hexdigest()
    demand((len(hashes),size,digest.hexdigest())==(meta['fileCount'],meta['bytes'],meta['sha256']),'Original classified corpus changed')
    return hashes
def validate_incidents(archive, ledger, sources, refs, subs):
    nonmatch = {}
    paths = set()
    for obj in loadz(archive/'nonmatching.jsonl.gz'):
        r = obj['observation']; p = r['left']; i = obj['referenceId']
        demand(type(i) is int and (p,i) not in nonmatch and p in ledger and i in refs,'Unknown or repeated native incident')
        ref = refs[i]
        demand((r['kind'],r['leftPredicate'],r['right'],r['rightPredicate'])==('paid',subs[p],ref['source'],ref['operator']),'Nonmatching observation belongs to different original selectors')
        ids,costs=ledger[p]
        demand(r['expected']==costs[ids.index(i)] and r['checked'] is False, 'Nonmatching observation score or verdict changed')
        demand(sources[p]==obj['leftSha256'] and sources[ref['source']]==ref['sha']==obj['rightSha256'], 'Incident source hashes differ')
        rel = r['incidentPath']; expected_shard=obj['shard']
        demand(re.fullmatch(r'shard-\d{4}', expected_shard) and type(r['ordinal']) is int and re.fullmatch(r'incidents/'+expected_shard+'-'+str(r['ordinal'])+r'-[0-9a-f-]{36}\.json\.gz',rel) and rel not in paths, 'Unsafe or repeated native incident name')
        artifact=archive/rel
        demand(sha(artifact)==r['incidentSha256'],'Original incident SHA mismatch')
        with gzip.open(artifact,'rt') as stream: original=json.load(stream,parse_float=SerializedNumber)
        demand(original['identity']=={k:v for k,v in r.items() if k not in ('incidentPath','incidentSha256')} and original['leftSha256']==obj['leftSha256'] and original['rightSha256']==obj['rightSha256'], 'Incorrect incident archive identity')
        if r['status']!='WORKER_ERROR':
            evidence=original['nativeComparatorEvidence']
            demand((evidence['status'],evidence['reason'])==(r['status'],r['reason']), 'Original native outcome differs')
            check_programs(evidence,r)
        paths.add(rel);nonmatch[p,i]=r
    demand(paths=={p.relative_to(archive).as_posix() for p in (archive/'incidents').glob('*.json.gz')},'Missing or extraneous whole incident archive')
    return nonmatch
def validate_entry(item, critical):
    demand(isinstance(item,list) and len(item) in (3,4) and type(item[0]) is int, 'Malformed compact entry')
    mode=item[1]
    if critical is not None:
        demand(item==[item[0],'!',critical['incidentSha256']], 'Lost or misclassified nonconforming witness')
        return '!'
    demand(mode in ('F','T') and len(item)==4 and type(item[2]) is int and item[2]>=0 and real_digest(item[3]),'Malformed checked commitment')
    return mode
def verify(archive, frozen, cohort_manifest, runner):
    s=json.loads((archive/'summary.json').read_bytes())
    demand(s['schema']=='candidate-exhaustive-native-ranking-commitments-v1' and s['complete'] is True,'Incomplete compact archive')
    digest,registered,native=registered_selection(runner)
    demand(s['producerIdentitySha256']==digest and s['candidateRunId']==registered['uuid'] and s['measuredCommit']==registered['commit'] and s['measuredJarSha256']==registered['jar'] and s['candidateBuildReceiptSha256']==registered['build'] and s['executionPlansSha256']==registered['plan'],'Unregistered candidate engine, build or execution order')
    demand(s['inputManifestSha256']==sha(cohort_manifest)==COHORT and (s['sourceRunId'],s['originalScoreCommit'],s['originalScoreJarSha256'])==(native['originalProducer']['runId'],native['originalProducer']['commit'],JAR),'Unregistered original score provenance')
    plan_path=archive/'execution-plan-hashes.json';demand(sha(plan_path)==registered['plan'],'Candidate plan-binding manifest changed');plans=json.loads(plan_path.read_bytes())
    demand(s['declaredMatches']==dict(status='MATCHED',reason='CHECKED_NATIVE_ACTIONS_EQUAL',endpointCorrespondenceChecked=True,fixedChoiceReplaysChecked=True,sourceCertificatesChecked=True,nativeSequencesEqual=True),'Unchecked successful status convention')
    demand(s['orderedProgramCheckerSha256']==sha(Path(__file__).with_name('native_commitment.py')),'Original ordered program verifier changed')
    for name, field in {'shard-bindings.json':'shardBindingsSha256','source-index.tsv.gz':'sourceIndexSha256','nonmatching.jsonl.gz':'nonmatchingSha256'}.items():
        demand(sha(archive/name)==s[field], 'Archive hash mismatch: '+name)
    bindings=json.loads((archive/'shard-bindings.json').read_bytes()); meta=json.loads(cohort_manifest.read_bytes()); expected_shards=meta['shards']
    demand(len(bindings)==len(expected_shards)==s['required']==s['shardsChecked']==1059,'Incomplete shard bindings')
    for a,b in zip(bindings,expected_shards):
        demand((a['shard'],a['rows'],a['inputSha256'])==(b['id'],b['rows'],b['sha256']) and a['planSha256']==plans[b['id']] and real_digest(a['resultSha256']) and real_digest(a['receiptSha256']), 'Inconsistent shard identities')
    upstream=originals(frozen)
    refs={r['id']:r for r in loadz(upstream['references'])}
    subs={r['path']:r['left'] for r in loadz(upstream['pairs']) if r['status']!='CORRECT'}
    ledger={}
    for p,ids,fast,cert in loadz(upstream['scores']):
        demand(p not in ledger and p in subs and fast==cert and len(ids)==len(fast) and ids==sorted(set(ids)) and all(type(x) is int and x>0 for x in fast),'Invalid published ranking leaf')
        ledger[p]=array('H',ids),array('I',fast)
    demand(len(refs)==s['references']==4496 and subs.keys()==ledger.keys() and len(ledger)==s['submissions']==42386,'Released reference or submission inventory changed')
    sources=source_hashes(frozen,meta['dataset'])
    demand(all(sources[r['source']]==r['sha'] for r in refs.values()),'Reference SHA differs from original source')
    nonmatch=validate_incidents(archive,ledger,sources,refs,subs)
    shard_no=0; native_ordinal=0; shard_input=hashlib.sha256(); complete_inputs=hashlib.sha256()
    chunks=s['chunks']; modes=Counter(); totals=Counter(); seen=set(); count=0
    index=iter(source_row_index(archive))
    for n,chunk in enumerate(chunks):
        name=f'native-ranking-{n:03d}.jsonl.gz'; path=archive/name; nr=0; ns=0
        demand(chunk['path']==name and path.stat().st_size==chunk['bytes'] and sha(path)==chunk['sha256'],'Compact native file hash or name changed')
        with gzip.open(path,'rb') as stream:
            while True:
                offset=stream.tell(); raw=stream.readline()
                if not raw: break
                p,entries=json.loads(raw)
                demand(p not in seen and p in ledger and isinstance(entries,list),'Missing/duplicate source in compact witness file')
                row = next(index, None)
                demand(row is not None and (row['source'],row['chunk'],row['uncompressedOffset'],row['comparisons'])==(p,name,str(offset),str(len(entries))), 'Incorrect native lookup offset or count')
                ids,scores=ledger[p]
                demand(len(entries)==len(ids),'Missing native witnesses for '+p)
                for ref_id,expected,edge in zip(ids,scores,entries):
                    demand(edge[0]==ref_id,'Unexpected or out-of-order reference selection')
                    bad=nonmatch.get((p,ref_id))
                    ref=refs[ref_id]; target=expected_shards[shard_no]
                    data=('\t'.join(('paid',p,subs[p],sources[p],ref['source'],ref['operator'],ref['sha'],str(expected)))+'\n').encode()
                    shard_input.update(data);complete_inputs.update(data)
                    if bad is not None:
                        demand(bad['incidentPath'].startswith('incidents/'+target['id']+'-') and bad['ordinal']==native_ordinal,'Native incident lies outside its input shard or ordinal')
                    native_ordinal+=1
                    if native_ordinal==target['rows']:
                        demand(shard_input.hexdigest()==target['sha256'],'Compact commitments do not reconstruct the original source/role/score input shard')
                        shard_no+=1;native_ordinal=0;shard_input=hashlib.sha256()
                    mode=validate_entry(edge,bad)
                    if mode=='!':totals[(bad['status'] if bad['status']!='MATCHED' else 'UNBOUND_MATCH',bad['reason'])]+=1
                    else:modes['FLAT_ACTIONS' if mode=='F' else 'TEMPORAL_BLOCK_EFFECTS']+=1
                seen.add(p);count+=len(entries);nr+=len(entries);ns+=1
        demand((nr,ns)==(chunk['rows'],chunk['submissions']) and 0<nr<=100000,'Chunk extent changed')
    demand(next(index,None) is None and {p.name for p in archive.glob('native-ranking-*.jsonl.gz')}=={c['path'] for c in chunks},'Extra lookup entry or compact chunk')
    demand(shard_no==len(expected_shards) and native_ordinal==0 and complete_inputs.hexdigest()==meta['combinedInputsSha256'],'Compact selections do not recreate the original complete input digest')
    failures=[dict(status=k,reason=r,count=n) for (k,r),n in sorted(totals.items())]
    status='INFRASTRUCTURE_FAILURE' if any(k=='WORKER_ERROR' for k,_ in totals) else 'BLOCKED' if totals else 'VERIFIED'
    demand(seen==subs.keys() and count==s['rows']==1894168 and sum(modes.values())==s['checkedOrderedNativeWitnesses'] and sum(totals.values())==s['nonconforming']==len(nonmatch) and dict(modes)==s['matchedModes'] and failures==s['failures'] and s['status']==status,'Compact census differs from recorded verdict')
    return {'status':status,'rows':count,'checked':sum(modes.values()),'nonconforming':len(nonmatch),'summarySha256':sha(archive/'summary.json')}
if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('archive',type=Path);parser.add_argument('frozen',type=Path);parser.add_argument('cohort_manifest',type=Path);parser.add_argument('runner_identity',type=Path)
    args=parser.parse_args()
    report=verify(args.archive,args.frozen,args.cohort_manifest,args.runner_identity)
    print(json.dumps(report,sort_keys=True));sys.exit(0 if report['status']=='VERIFIED' else 2)
