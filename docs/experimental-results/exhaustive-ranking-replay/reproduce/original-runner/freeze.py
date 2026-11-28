"""Bind a fresh output root to one measured JAR and the immutable census inputs."""
import hashlib,json,subprocess,sys
from pathlib import Path
root=Path(__file__).resolve().parents[1]
def sha(path):
    h=hashlib.sha256()
    with path.open('rb') as f:
        while data:=f.read(1048576):h.update(data)
    return h.hexdigest()
def require(v,msg):
    if not v:raise ValueError(msg)
mfile=root/'cohort/manifest.json';m=json.loads(mfile.read_bytes())
jar=root/'frozen/measured.jar'
release=root/'frozen/docs/experimental-results/historical-retention/run-receipt.json'
r=json.loads(release.read_bytes())
require(r['experimentJar']['sha256']==sha(jar)==m['jarSha256'],'JAR differs from measurement')
require(m['rows']==1894168 and m['submissions']==42386 and m['measuredCommit']==r['git']['commit'] and m['measuredRunId']==r['runId'],'Incorrect source measurement')
paths=[jar,release,*sorted((root/'runner').glob('*.py')),*sorted((root/'runner').glob('*.java')),*sorted((root/'runner').glob('*.sh')),*sorted((root/'runner-classes').rglob('*.class'))]
for lib in r['dependencies']:
    p=root/'frozen'/lib['path'];require(sha(p)==lib['sha256'],'Changed runtime dependency '+str(p));paths.append(p)
libs=set((root/'frozen/lib').glob('*.jar'));require(libs==set(p for p in paths if p.parent==root/'frozen/lib' and p.suffix=='.jar'),'Classpath includes an extra JAR')
for k,v in m['supportingFiles'].items():require(sha(root/'cohort'/k)==v,'Changed original catalog')
config=json.loads((root/'runner-control.json').read_bytes())
identity=dict(schema='acgn-paid-native-census-runner-v1',sourceRunId=m['measuredRunId'],sourceCommit=m['measuredCommit'],
              rows=m['rows'],submissions=m['submissions'],shards=len(m['shards']),dataset=m['dataset'],
              inputManifestSha256=sha(mfile),jarSha256=sha(jar),files={str(p.relative_to(root)):sha(p) for p in paths},
              javaVersion=subprocess.check_output(['java','-version'],stderr=subprocess.STDOUT,text=True),
              nativeEntry='NativeOperationComparison.compare(Canonical.Prepared, Canonical.Prepared, CanonicalAlloyPipeline.Prepared, CanonicalAlloyPipeline.Prepared)',
              costSource='Frozen full ranked reference index, both arms',
              cache='Original immutable endpoint path / selected predicate / SHA-256; no comparison-result reuse',
              initialControl=config,verification='Every non-matching, invalid, unknown, incomplete or unbound row is preserved; any such result fails whole-corpus checked equality.')
with (root/'runner-identity.json').open('x') as f:json.dump(identity,f,indent=2,sort_keys=True);f.write('\n')
print(sha(root/'runner-identity.json'))
