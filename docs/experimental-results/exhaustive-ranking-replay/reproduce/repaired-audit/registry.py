"""Register the candidate native engine separately from the original immutable ranking-score producer."""
import hashlib,json
from pathlib import Path
from verify_inputs import check,sha,jsonfile

ORIGINAL_INPUT='074fbe5573ccf33de100f85cc14a7d0f33c297271b933401ee061d066da99ff5'
ORIGINAL_RUNNER='a2cf64f0889624b0dc675b73d80f5b34caca2d73c9448b788713463b8abc3f02'
ORIGINAL_JAR='a4c30092d064b8fa39011d888b2a9898a8b5060588e3356bb98e8ba34543217e'
CANDIDATES={'71e64001db8aa2255956584de45a5c80baefcdd3905564ac2124067d64b79d62': {'uuid': '617d9fb3-5c46-419b-a596-e167f973985e', 'commit': '177500afd23b74d3d3695b9c38fb6ad0c0709838', 'jar': '79e63cd786f7da185185a078ffd7979c036b8034abd1643b5797ae8dd1613bdd', 'plan': '7455a1437326f595d46008ea601583eb2eb10ed4fa4736bbc6ecf52aa6aec861', 'build': '8144a8dd5b061e591519a49c35e0a7ff80c53f44dc96e07be4a44719998788f5'}}
def select(identity):
    identity=Path(identity);digest=sha(identity);check(digest in CANDIDATES,'Unregistered candidate native runner')
    expected=CANDIDATES[digest];src=jsonfile(identity);base=src['originalProducer'];engine=src['engine']
    check(src['schema']=='acgn-paid-native-candidate-replay-v1' and src['scoreAuthority']=='originalProducer' and src['candidateRunId']==expected['uuid'] and engine['role']=='REPAIR_CANDIDATE' and engine['commit']==expected['commit'] and engine['jarSha256']==expected['jar'] and engine['buildReceiptSha256']==expected['build'],'Candidate execution identity differs')
    check(base['baselineNativeRunnerIdentitySha256']==ORIGINAL_RUNNER and base['jarSha256']==ORIGINAL_JAR and base['rankingManifestSha256']==src['inputManifestSha256']==ORIGINAL_INPUT and src['files']['plans/manifest.json']==expected['plan'],'Original ranking provenance or candidate order differs')
    return digest,expected,src
def inspect(w,plans=True):
    digest,expected,src=select(w/'runner-identity.json')
    meta=jsonfile(w/'cohort/manifest.json')
    check(sha(w/'cohort/manifest.json')==ORIGINAL_INPUT and meta['measuredRunId']==src['originalProducer']['runId'] and meta['measuredCommit']==src['originalProducer']['commit'] and meta['combinedInputsSha256']==src['originalProducer']['combinedInputsSha256'],'Original score/leaf digest differs')
    check(meta['rows']==src['rows']==1894168 and meta['submissions']==src['submissions']==42386 and len(meta['shards'])==src['shards']==1059,'Incomplete original/candidate cohorts')
    build=jsonfile(w/src['engine']['buildReceipt']);check(build['git']['commit']==expected['commit'] and build['experimentJar']['sha256']==expected['jar'] and build['buildsByteIdentical'] is True,'Wrong candidate build or reproducibility receipt')
    expected_inputs={'engine/candidate.jar','engine/build-receipt.json','plans/manifest.json'}|{str(f.relative_to(w)) for f in (w/'runner').glob('*') if f.is_file()}|{str(f.relative_to(w)) for f in (w/'runner-classes').rglob('*.class')}|{'original-inputs/lib/'+f.name for f in (w/'original-inputs/lib').glob('*.jar')}
    check(expected_inputs==src['files'].keys(),'Additional or missing candidate driver/runtime files')
    for path,h in src['files'].items():check(sha(w/path)==h,'Changed candidate verifier or runtime: '+path)
    if plans:verify_plans(w,meta,expected)
    return meta,src
def verify_plans(w,meta,expected):
    table=jsonfile(w/'plans/manifest.json')
    check(sha(w/'plans/manifest.json')==expected['plan'] and set(table)=={s['id'] for s in meta['shards']}=={p.stem for p in (w/'plans').glob('*.tsv')},'Unregistered/unaccounted execution plan')
    combined=hashlib.sha256();rows=0
    for s in meta['shards']:
        shard=s['id'];job_path=w/'cohort'/s['path'];data=job_path.read_bytes()
        check(hashlib.sha256(data).hexdigest()==s['sha256'],'Original job shard changed')
        original=data.splitlines(keepends=True);plan=w/'plans'/(shard+'.tsv')
        check(sha(plan)==table[shard],'Unregistered execution order')
        seen=bytearray(len(original))
        with plan.open('rb') as stream:
            for line in stream:
                check(line.endswith(b'\n'),'Truncated execution plan')
                raw,token=line[:-1].rsplit(b'\t',1);ordinal=int(token)
                check(0<=ordinal<len(original) and token==str(ordinal).encode() and not seen[ordinal] and raw+b'\n'==original[ordinal],'Non-bijective execution order or changed source/role/distance selector')
                seen[ordinal]=1;rows+=1
        check(all(seen) and len(seen)==s['rows'],'Candidate did not plan every original ordinal')
        combined.update(data)
    check(rows==meta['rows'] and combined.hexdigest()==meta['combinedInputsSha256'],'Incorrect complete candidate input authority')
    return rows
