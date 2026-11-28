"""Look up an original submission-to-reference witness by immutable reference ID or path#predicate."""
import argparse
import csv
import gzip
import json
from pathlib import Path
from registry import CANDIDATES
from verify_compact import COHORT,JAR,RUNNER,originals,source_hashes,source_row_index,loadz,demand,validate_entry,sha


def lookup(archive, frozen, source, ref):
    paths=originals(frozen)
    receipt=frozen/'docs/experimental-results/historical-retention/run-receipt.json'
    demand(sha(receipt)=='f4c4cafb055bb942b2aeaed7db5b7f6758be8cb8f690b0670d311228e6854a47','Original source provenance changed')
    dataset=json.loads(receipt.read_bytes())['dataset']
    verified_sources=source_hashes(frozen,dict(fileCount=dataset['fileCount'],bytes=dataset['byteCount'],sha256=dataset['sha256']))
    refs=list(loadz(paths['references']))
    if ref.isdigit():
        selected=[r for r in refs if r['id']==int(ref)]
    else:
        selected=[r for r in refs if r['source']+'#'+r['operator']==ref]
    demand(len(selected)==1,'Unknown original reference ID or path#predicate')
    reference=selected[0]; rid=reference['id']
    demand(verified_sources[reference['source']]==reference['sha'],'Original reference source changed')
    index=next((r for r in source_row_index(archive) if r['source']==source),None)
    demand(index is not None,'Submission absent from the proposed ranking cohort')
    summary=json.loads((archive/'summary.json').read_bytes())
    demand(summary.get('complete') is True and summary.get('inputManifestSha256')==COHORT and summary.get('producerIdentitySha256') in CANDIDATES and summary.get('measuredJarSha256')==CANDIDATES[summary['producerIdentitySha256']]['jar'] and summary.get('measuredCommit')==CANDIDATES[summary['producerIdentitySha256']]['commit'] and summary.get('originalScoreJarSha256')==JAR,'Unregistered compact census')
    demand(sha(archive/'source-index.tsv.gz')==summary['sourceIndexSha256'],'Changed native source index')
    chunk=next(c for c in summary['chunks'] if c['path']==index['chunk'])
    from re import fullmatch
    demand(fullmatch(r'native-ranking-\d{3}\.jsonl\.gz',chunk['path']) and sha(archive/chunk['path'])==chunk['sha256'],'Changed native commitment chunk')
    with gzip.open(archive/chunk['path'],'rb') as f:
        f.seek(int(index['uncompressedOffset'])); label,group=json.loads(f.readline())
    demand(label==source and len(group)==int(index['comparisons']),'Invalid native source index position')
    entry=next((v for v in group if v[0]==rid),None)
    demand(entry is not None,'This reference was not compared with the specified submission')
    p,ids,fast,cert=next(x for x in loadz(paths['scores']) if x[0]==source)
    at=ids.index(rid)
    demand(fast[at]==cert[at], 'Original score discrepancy')
    student=next(r for r in loadz(paths['pairs']) if r['path']==source)
    result=dict(submission={'path':source,'predicate':student['left'],'sha256':verified_sources[source]},
                reference={'id':rid,'path':reference['source'],'predicate':reference['operator'],'sha256':reference['sha']},
                expected=fast[at],measuredJarSha256=summary['measuredJarSha256'],producerIdentitySha256=summary['producerIdentitySha256'])
    if entry[1]=='!':
        demand(sha(archive/'nonmatching.jsonl.gz')==summary['nonmatchingSha256'],'Changed nonconforming ledger')
        record=next(x for x in loadz(archive/'nonmatching.jsonl.gz') if x['observation']['left']==source and x['referenceId']==rid)
        row=record['observation'];validate_entry(entry,row)
        demand(sha(archive/row['incidentPath'])==row['incidentSha256'],'Native divergence receipt changed')
        result.update(native=row)
    else:
        validate_entry(entry,None)
        result.update(native=dict(status='MATCHED',reason='CHECKED_NATIVE_ACTIONS_EQUAL',fastDistance=fast[at],certifiedDistance=cert[at],
                                 sequenceKind='FLAT_ACTIONS' if entry[1]=='F' else 'TEMPORAL_BLOCK_EFFECTS',count=entry[2],
                                 sharedOrderedSequenceSha256=entry[3],endpointCorrespondenceChecked=True,sourceCertificatesChecked=True,
                                 fixedChoiceReplaysChecked=True,nativeSequencesEqual=True))
    return result
if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('archive',type=Path);parser.add_argument('frozen',type=Path);parser.add_argument('submission');parser.add_argument('reference')
    opt=parser.parse_args();print(json.dumps(lookup(opt.archive,opt.frozen,opt.submission,opt.reference),indent=2,sort_keys=True))
