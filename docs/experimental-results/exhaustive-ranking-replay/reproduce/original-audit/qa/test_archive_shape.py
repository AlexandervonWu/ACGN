"""Exercise the entire archive encoder/decoder on an explicitly synthetic catalog with one real negative control.

No generated commitment here is admissible native evidence. The full temporary archive is removed on exit.
"""
import collections
import csv
import gzip
import itertools
import json
import sys
import tempfile
from pathlib import Path

cohort=Path(__file__).resolve().parents[1];w=cohort.parent;sys.path.insert(0,str(cohort))
from verify_results import Compact,sha,atomic,REGISTERED_COHORT,REGISTERED_RUNNER
from verify_compact import verify,originals,loadz,JAR
from lookup_native import lookup
from test_verifiers import get_case

def run():
    shard,ordinal,negative_cells,negative=get_case(w,'MISMATCH')
    upstream=originals(w/'frozen');cat={r['id']:(r['source'],r['operator']) for r in loadz(upstream['references'])}
    neg_id=next(i for i,t in cat.items() if t==(negative['right'],negative['rightPredicate']))
    m=json.loads((cohort/'manifest.json').read_bytes())
    mock='f'*64
    with tempfile.TemporaryDirectory(dir=cohort/'qa',prefix='FORMAT-TEST-ONLY-') as tmp:
        archive=Path(tmp);c=Compact(archive,w/'results');modes=collections.Counter()
        selections=sorted(loadz(upstream['scores']),key=lambda v:(v[0].split('/')[0],cat[v[1][0]][1].rstrip('cC'),v[0]))
        for source,ids,fast,cert in selections:
            for rid in ids:
                if source==negative['left'] and rid==neg_id:c.add(negative_cells,negative,negative['status'],rid,shard)
                else:
                    flat=rid%2==0;kind='FLAT_ACTIONS' if flat else 'TEMPORAL_BLOCK_EFFECTS';modes[kind]+=1
                    c.add(['paid',source],dict(sequenceKind=kind,fastActionCount=4,fastBlockCount=2,fastSequenceSha256=mock),'MATCHED',rid,'TEST-ONLY')
        c.close()
        bindings=[dict(shard=s['id'],inputSha256=s['sha256'],rows=s['rows'],resultSha256=mock,receiptSha256=mock) for s in m['shards']]
        atomic(archive/'shard-bindings.json',bindings)
        summary=dict(schema='exhaustive-native-ranking-commitments-v1',complete=True,status='BLOCKED',
                     measuredJarSha256=JAR,inputManifestSha256=REGISTERED_COHORT,producerIdentitySha256=REGISTERED_RUNNER,
                     orderedProgramCheckerSha256=sha(cohort/'native_commitment.py'),required=1059,shardsChecked=1059,submissions=42386,
                     references=4496,rows=1894168,checkedOrderedNativeWitnesses=1894167,matchedModes=dict(modes),nonconforming=1,
                     failures=[{'status':'MISMATCH','reason':negative['reason'],'count':1}],chunks=c.chunks,
                     sourceIndexSha256=sha(archive/'source-index.tsv.gz'),nonmatchingSha256=sha(archive/'nonmatching.jsonl.gz'),
                     shardBindingsSha256=sha(archive/'shard-bindings.json'),
                     declaredMatches=dict(status='MATCHED',reason='CHECKED_NATIVE_ACTIONS_EQUAL',endpointCorrespondenceChecked=True,fixedChoiceReplaysChecked=True,sourceCertificatesChecked=True,nativeSequencesEqual=True))
        atomic(archive/'summary.json',summary)
        result=verify(archive,w/'frozen',cohort/'manifest.json',w/'runner-identity.json')
        assert result['status']=='BLOCKED' and result['nonconforming']==1
        lookup1=lookup(archive,w/'frozen',negative['left'],str(neg_id))
        lookup2=lookup(archive,w/'frozen',negative['left'],negative['right']+'#'+negative['rightPredicate'])
        assert lookup1==lookup2 and lookup1['native']['incidentSha256']==negative['incidentSha256']
        print(json.dumps({'purpose':'SYNTHETIC_FORMAT_QUALIFICATION_ONLY','effectiveStatus':'PASS','shapeRows':result['rows'],'closureClaim':False,'chunkCount':len(c.chunks),'negativeControlLookup':True}))
if __name__=='__main__':run()
