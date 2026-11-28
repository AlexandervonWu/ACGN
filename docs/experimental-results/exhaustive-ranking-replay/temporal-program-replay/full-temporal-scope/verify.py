"""Recount archived and fresh ordered temporal programs directly from the two native block arrays."""
import argparse
import collections
import concurrent.futures
import csv
import gzip
import hashlib
import itertools
import json
import os
from pathlib import Path
import sys
from zipfile import ZipFile

HERE=Path(__file__).resolve().parent
def require(ok,message):
    if not ok:raise ValueError(message)
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def read(p):return json.loads(p.read_bytes())
def digest(s):return hashlib.sha256(s).hexdigest()
def gzrows(p):
    with gzip.open(p,'rt') as f:yield from map(json.loads,f)
def load_imports(release):
    sys.path[:0]=[str(release/'reproduce'),str(release/'reproduce/original-audit'),str(release/'temporal-program-replay'),str(HERE)]
    global canonical,SerializedNumber,check_programs,check_native,find_labels,offset_between,archived_label_reconstruction
    from native_commitment import canonical,SerializedNumber,check_programs
    from verify_results import check_native
    from audit import find_labels
    from occurrences import offset_between,archived_label_reconstruction
def select(release,repo):
    from compare_censuses import open_archive,comparisons
    from compare_programs import published
    summary,inc=open_archive(release/'repaired')
    require(not inc and summary['status']=='VERIFIED','Final full ranking census unfinished')
    table={};sources=set()
    for (source,ref),item in comparisons(release/'repaired',summary):
        if item[1]=='T':
            k=source,ref;require(k not in table,'Duplicate temporal selection')
            table[k]={'blocks':item[2],'archive':item[3]};sources.add(source)
    require(len(table)==26673,'Incomplete temporal universe')
    refs={r['id']:r for r in published(repo,'references')}
    predicates={r['path']:r['left'] for r in published(repo,'paired') if r['path'] in sources}
    for source,ids,fast,cert in published(repo,'scores'):
        if source not in sources:continue
        for rid,f,c in zip(ids,fast,cert,strict=True):
            k=source,rid
            if k not in table:continue
            require(f==c and f>0,'Official numeric rank mismatch')
            q=refs[rid];table[k].update(score=f,pred=predicates[source],target=q['source'],targetPred=q['operator'],targetHash=q['sha'])
    for j in table.values():require('score' in j,'Unscored temporal pair')
    return table
def strict_block_worker(args):
    spans,expected,outcomes,bundle,cold,offsets=args;tot=collections.Counter();offset_rows={};all_programs=set();known_keys=set()
    with ZipFile(HERE/bundle) as zz:
        for n,binding in spans:
            receipt=json.loads(zz.read(n+'.receipt.json'));comp=zz.read(n+'.jsonl.gz')
            require(digest(comp)==receipt['compressed']==binding['native'] and digest(zz.read(n+'.receipt.json'))==binding['receipt'],'Supplementary native capture changed')
            checksum=hashlib.sha256();summary_rows=outcomes[n]
            require(receipt['jar']==META['jar'] and receipt['manifest']==META['captureManifestSha256'],'Foreign native measurement')
            for meta,ledger,line in itertools.zip_longest(expected[n],summary_rows,gzip.decompress(comp).splitlines(keepends=True)):
                require(meta and ledger and line and line.endswith(b'\n'),'Incomplete native program')
                row=json.loads(line,parse_float=SerializedNumber);checksum.update(line); orig=meta[4:6]
                key=(meta[2],meta[3]); blockcount,archived=meta[6:8]
                require((row['ordinal'],row['left'],row['leftPredicate'],row['right'],row['rightPredicate'])==(meta[1],key[0],meta[8],meta[10],meta[11]),'Different selected submission, source predicate or reference')
                require(check_native(row,meta[-1]) and row['expected']==meta[-1] and row['checked'] and row['sequenceKind']=='TEMPORAL_BLOCK_EFFECTS' and row['fastBlockCount']==row['certifiedBlockCount']==blockcount,'Failed native cost, block length, replay or source control')
                check_programs(row,row);h=row['fastSequenceSha256'];has=(b'localBinding' in line and b'sourceOccurrence' in line) or b'\\u' in line
                found={};effects={}
                for arm in ('fast','certified'):
                    ls,susp=find_labels(row[arm+'Blocks']) if has else ([],[])
                    require(not susp,'Unparsed string may embed an occurrence label')
                    found[arm]=ls;effects[arm]=[x for x in ls if len(x[0])>1 and x[0][1]=='effect']
                require(effects['fast']==effects['certified'],'Raw effect occurrence paths differ across native arms')
                roles=sorted({'source' if 'source' in p else 'target' if 'target' in p else 'other' for p,v in effects['fast']})
                rawsha=digest(line);predicted=[*meta[2:4],meta[8],meta[9],meta[10],meta[11],meta[12],meta[-1],*orig,blockcount,archived,h,row['certifiedSequenceSha256'],rawsha,len(effects['fast']),len(found['fast']),len(found['certified']),roles]
                require(predicted==ledger,'Source-bound compact row differs from the full raw replay')
                if effects['fast'] or h!=archived or found['certified'] or found['fast']:
                    require(key in cold and effects['fast'] and h!=archived and roles in (['source'],['target']), 'Different unclassified temporal exception')
                    program=[[b['component'],b['effect']] for b in row['fastBlocks']]
                    baseline,ident=cold[key]
                    move=offset_between({'program':baseline},{'program':program})
                    shifted=archived_label_reconstruction(baseline,move)
                    require(canonical(shifted)==canonical(program) and digest(canonical(shifted).encode())==h,'Another operation property changed in the fresh allocated program')
                    offset_rows[ident]=move
                    known_keys.add(key);tot['sourceLocalPairs' if roles==['source'] else 'targetLocalPairs']+=1
                    archived_lineage=archived_label_reconstruction(program,offsets[key]-move)
                    require(digest(canonical(archived_lineage).encode())==archived,'Could not reconstruct the recorded within-run bytes for independently certified allocator offset')
                    tot['reconstructedFinalArchivedPrograms']+=1
                else:require(key not in cold,'Rank-change table contains an unlabelled program')
                tot['temporalRows']+=1;tot['withinReplayStrictlyMatched']+=1;tot['archivedRawEqual' if h==archived else 'archivedRawDifferent']+=1;tot['pairsWithLocalOccurrence']+=bool(effects['fast'])
            require(checksum.hexdigest()==receipt['raw'] and receipt['ack']['newRows']==receipt['ack']['rows']==len(expected[n]),'Missing rows in native producer ledger')
    return dict(tot),offset_rows,known_keys

def verify(release,repo,recorded=None):
    global META
    load_imports(release);META=read(HERE/'inventory.json');m=read(HERE/'capture-manifest.json')
    for name,h in META['files'].items():require(sha(HERE/name)==h,'Published supplementary data changed: '+name)
    require(META['captureManifestSha256']==sha(HERE/'capture-manifest.json') and m['jar']==META['jar'] and m['identity']==sha(release/'receipts/repaired/runner-identity.json'),'Capture registration or measured identity differs')
    frozen=read(release/'receipts/repaired/runner-identity.json');require(frozen['engine']['jarSha256']==META['jar'] and frozen['engine']['commit']==m['commit']==META['commit'],'Wrong measured executable')
    require(sha(release/'reproduce/repaired-runner/ExhaustiveNativeReplay.java')==m['originalJava'] and sha(HERE/'TemporalCapture.java')==m['captureJava'],'Changed comparator adapter')
    old=(release/'reproduce/repaired-runner/ExhaustiveNativeReplay.java').read_text()
    require((HERE/'TemporalCapture.java').read_text()==old.replace('public final class ExhaustiveNativeReplay','public final class TemporalCapture').replace('            compareSequences(evidence,row);','            compareSequences(evidence,row);\n            copy(evidence,row,"fastBlocks","certifiedBlocks");'),'Supplementary driver changes a measured computation')
    for f,h in m['captureClasses'].items():require(sha(HERE/f)==h,'Supplementary driver bytecode mismatch')
    jobs=collections.defaultdict(list); outcomes=collections.defaultdict(list); hashed={};expected={}
    t=select(release,repo);shards={row['shard']:row for row in read(release/'repaired/shard-bindings.json')}
    for q in m['shards']: expected[q['name']]=q
    with gzip.open(HERE/'selected-jobs.jsonl.gz','rb') as f:
        combined=hashlib.sha256()
        for line in f:
            combined.update(line);z=json.loads(line);n,i,source,rid,orig,ord_,nb,h,pr,hs,target,tp,ht,d=z;k=source,rid
            require(k in t and n in expected and i==len(jobs[n]),'Incorrect temporal catalog, selection, or ordinal')
            required=t.pop(k)
            require((required['score'],required['blocks'],required['archive'],required['pred'],required['target'],required['targetPred'],required['targetHash'])==(d,nb,h,pr,target,tp,ht),'Job does not match official source, native blocks and archived score')
            bound=m['rankSourceShards'][orig];sh=shards[orig];require((bound['receipt'],bound['raw'],bound['input'])==(sh['receiptSha256'],sh['resultSha256'],sh['inputSha256']) and 0<=ord_<sh['rows'],'Wrong original measured input')
            for path,xy in ((source,hs),(target,ht)):
                if path not in hashed:hashed[path]=sha(repo/'classified-data'/path)
                require(hashed[path]==xy,'Changed source program: '+path)
            jobs[n].append(z)
        require(not t and combined.hexdigest()==m['expectedSha256'],'Temporal inputs are incomplete or changed')
    rows=list(csv.DictReader((release/'previously-matched-program-changes.csv').open()))
    ec=release/'temporal-program-replay';wt={h:w for h,w in gzrows(ec/'witnesses.jsonl.gz')}
    cp={};known_arch={}
    for ix,arm,prof,rep,_,h in gzrows(ec/'observations.jsonl.gz'):
        if (arm,prof,rep)!=('repaired','cold',0):continue
        ref=rows[ix];key=ref['submission'],int(ref['referenceId']);p=wt[h];require(digest(canonical(p).encode())==h,'Wrong clean-process witness');cp[key]=p['program'],ix;known_arch[key]=ref['repairedProgramSha256']
    require(len(cp)==len(rows)==196,'Incomplete clean-process comparison set')
    offsets={}
    if (ec/'archived-offsets.jsonl').is_file():
        for l in (ec/'archived-offsets.jsonl').read_bytes().splitlines():
            r=json.loads(l)
            if r['edition']=='repaired':
                c=rows[r['row']];offsets[c['submission'],int(c['referenceId'])]=r['offset']
    require(set(offsets)==set(cp), 'All 196 measured final archival label translations are required')
    for n,jobs_ in jobs.items():
        checked_jobs=''.join('\t'.join(['paid',z[2],z[8],z[9],z[10],z[11],z[12],str(z[-1]),str(z[1])])+'\n' for z in jobs_).encode()
        require(len(jobs_)==expected[n]['rows'] and digest(checked_jobs)==expected[n]['sha256'],'Resolved native input shard differs')
    with gzip.open(HERE/'pair-observations.jsonl.gz','rt') as f:
        for n in sorted(jobs):
            outcomes[n]=[json.loads(next(f)) for i in jobs[n]]
        require(not f.readline(),'Extra compact observation')
    buckets=collections.defaultdict(list)
    for n,info in META['nativeCaptures'].items():
        buckets[info['bundle']].append((n,info))
    require(set(META['nativeCaptures'])==set(jobs)==set(expected),'Subset of captured raw shards')
    params=[(v,{n:jobs[n] for n,_ in v},{n:outcomes[n] for n,_ in v},bundle,cp,offsets) for bundle,v in buckets.items()]
    stats=collections.Counter();observed={};all_known=set()
    with concurrent.futures.ProcessPoolExecutor(max_workers=min(4,len(params))) as ex:
        for vals,delta,known in ex.map(strict_block_worker,params):
            stats.update(vals);require(not observed.keys() & delta.keys(),'Duplicate labelled case');observed.update(delta);all_known.update(known)
    require(all_known==set(cp) and stats['temporalRows']==26673,'Incomplete independent temporal set')
    spec=[[i,observed[i]] for i in sorted(observed)]
    require(spec==read(HERE/'fresh-replay-offsets.json'),'Recorded fresh process occurrence offsets differ')
    report=dict(status='VERIFIED',supplementaryTemporalRows=stats['temporalRows'],withinReplayStrictProgramMatches=stats['withinReplayStrictlyMatched'],archivedFinalHashEqual=stats['archivedRawEqual'],archivedFinalHashDifferent=stats['archivedRawDifferent'],withLocalBindingSourceOccurrence=stats['pairsWithLocalOccurrence'],locallyNamedOnlyOnSource=stats['sourceLocalPairs'],locallyNamedOnlyOnTarget=stats['targetLocalPairs'],solelyUniformFreshVersusColdEffectRelabelling=len(observed),exactColdEffectProgramsAmongThese=sum(delta==0 for delta in observed.values()),archiveCommitmentsReconstructedWithOnlyLocalOccurrenceTranslation=stats['reconstructedFinalArchivedPrograms'],archivalOffsetFileSha256=sha(ec/'archived-offsets.jsonl'),sameKeysAsOriginallyObservedCrossVersionChanges=all_known==set(cp),coldToFreshOffsetsSha256=sha(HERE/'fresh-replay-offsets.json'),finalCommit=META['commit'],finalJarSha256=META['jar'],fullMeasuredTemporalLedgerSha256=m['finalSummary'],nativeCaptureManifestSha256=META['captureManifestSha256'],exactSourceFiles=len(hashed),rawBlocksRetainedForBothArms=True)
    if recorded is not None:require(report==read(recorded),'Portable report differs')
    return report

if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--repo',required=True,type=Path);p.add_argument('--archive',type=Path,default=HERE.parents[1]);p.add_argument('--produce',action='store_true')
    args=p.parse_args();print(json.dumps(verify(args.archive,args.repo,None if args.produce else HERE/'summary.json'),sort_keys=True,indent=2))
