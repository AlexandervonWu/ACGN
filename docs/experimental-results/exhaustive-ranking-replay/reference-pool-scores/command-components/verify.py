"""Recount the scoped components and natural-pair headlines using compact, authenticated measurements."""
import argparse
import collections
import csv
import gzip
import hashlib
import json
import subprocess
import sys
from pathlib import Path


def check(ok, detail):
    if not ok:
        raise ValueError(detail)


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def read(path):
    return json.loads(path.read_bytes())


def items(path):
    with gzip.open(path, "rt") as stream:
        for row in stream:
            yield json.loads(row)


class Components:
    def __init__(self, nodes):
        self.parents = {node: node for node in nodes}

    def root(self, node):
        while self.parents[node] != node:
            self.parents[node] = self.parents[self.parents[node]]
            node = self.parents[node]
        return node

    def link(self, first, second):
        self.parents[self.root(first)] = self.root(second)

    def counts(self, nodes):
        groups = collections.Counter(self.root(n) for n in nodes)
        return len(groups), sum(size * (size - 1) // 2 for size in groups.values())


def measure(compact, catalog, expected_pool_counts, structural):
    check(sha(expected_pool_counts)=='cf54427aef0af5135f1a15eb6d3c002afd32091a3536fb3ca5e959061a2c8d20', 'Wrong historical component counts')
    checks = read(compact / 'SHA256.json')
    auth = ('zero','paired','fixed','sat-control','archived-original-command-results')
    for f in ['combined-verdict.json', *(name+'.jsonl.gz' for name in auth)]:
        check(sha(compact/f)==checks[f], 'Unbound compact file '+f)
    terminal = read(compact/'combined-verdict.json')
    check(terminal['status']=='VERIFIED', 'Incomplete source validation')
    check(sha(catalog)=='d2ffb181e2921e8536db9d2836f22f50a2faf9a22edebf83552ce68bb44bf5b1','Unexpected source catalog')
    group = collections.defaultdict(set)
    with catalog.open() as stream:
        refs={int(q['referenceId']):q for q in csv.DictReader(stream, delimiter='\t')}
    for rid,r in refs.items():
        group[r['questionSet'],r['invariantId']].add(rid)
    def edge(row):
        a,b=row['referenceIds']
        check(a!=b, 'Self edge in audit')
        check((refs[a]['questionSet'],refs[a]['invariantId'])==(refs[b]['questionSet'],refs[b]['invariantId']),'Cross-pool edge')
        for rid,role in ((a,'a'),(b,'b')):
            q=refs[rid]
            check(row[role]==[q['source'],q['predicate'],q['sourceSha256']],'Wrong candidate source')
        return tuple(sorted([a,b]))
    solver={}
    for r in items(compact/'archived-original-command-results.jsonl.gz'):
        pair=tuple(sorted(r['pair']))
        check(pair not in solver and r['decision']['native'] in ('SAT','UNSAT'), 'Invalid archived solver control')
        solver[pair]=r['decision']['native']
    zgraph,scope=Components(refs),Components(refs)
    zeros,fixed,controls=set(),set(),set()
    for r in items(compact/'zero.jsonl.gz'):
        pair=edge(r)
        check(r['state']=='MATCHED' and r['observedFast']==r['observedCertified']==0 and pair not in zeros,'Invalid structural edge')
        zeros.add(pair)
        zgraph.link(*pair);scope.link(*pair)
    for r in items(compact/'fixed.jsonl.gz'):
        pair=edge(r)
        check(r['state']=='SCOPE_RETAINED' and r['scope']['scopeStatus']=='FIXED_COMMAND_RULE' and r['scope']['native']==solver[pair]=='UNSAT' and bool(r['scope']['rules']), 'Unvalidated scoped equivalence')
        check(pair not in fixed, 'Duplicate fixed-command decision')
        fixed.add(pair);scope.link(*pair)
    for r in items(compact/'sat-control.jsonl.gz'):
        pair=edge(r)
        check(r['state']=='SCOPE_RETAINED' and solver[pair]=='SAT' and pair not in controls and scope.root(pair[0])!=scope.root(pair[1]),'Counterexample in a scoped component')
        controls.add(pair)
    check(set(solver)==fixed|controls,'Incomplete archived solver outcomes')
    natural=collections.Counter()
    for r in items(compact/'paired.jsonl.gz'):
        check(r['state']=='MATCHED' and r['observedFast']==r['observedCertified']==r['expected'], 'Native or scalar drift')
        label=r['a'][0].split('/')[1]; correct=label=='correct'
        natural['correct' if correct else 'incorrect']+=1
        zero=r['observedFast']==0
        natural['correctZeros' if correct else 'incorrectZeros']+=zero
        natural['slottedZeros']+=r['slotted']
        check(not r['slotted'] or zero,'Slotted positive missing')
        cmds=[c for c in r['commands'] if c['basis']=='FIXED_COMMAND_RULE']
        if cmds:
            check(correct and all(c['equivalent'] and c['native']=='UNSAT' for c in cmds),'Unsound scoped natural pair')
        natural['fixedCommandDecisions']+=len(cmds)
        natural['additionalCorrectPositiveDistancePairs']+=bool(cmds) and not zero
    with expected_pool_counts.open() as stream:
        historical={(r['questionSet'],r['invariantId']):r for r in csv.DictReader(stream)}
    check(set(group)==set(historical), 'Pool identities changed')
    details={}
    for name,nodes in group.items():
        zc,zp=zgraph.counts(nodes); fc,fp=scope.counts(nodes); old=historical[name]
        check((int(old['structuralClasses']),int(old['commandScopedComponents']),int(old['references']))==(zc,fc,len(nodes)), 'Historical component difference in '+str(name))
        details['/'.join(name)]=[len(nodes),zc,zp,fc,fp]
    zc,zp=zgraph.counts(refs); fc,fp=scope.counts(refs)
    report=dict(candidateCommit=terminal['candidateCommit'],candidateJar=terminal['candidateSha256'],compactSha256=sha(compact/'SHA256.json'),catalogSha256=sha(catalog),historicalPoolsSha256=sha(expected_pool_counts),
        directNativeZeros=len(zeros),directFixedLinks=len(fixed),fixedLinksAlsoStructural=len(fixed & zeros),additionalDirectScopedLinks=len(fixed - zeros),disconnectedSatControls=len(controls),pooledReferences=len(refs),pools=len(group),
        structuralForms=zc,structuralComponentPairs=zp,commandComponents=fc,commandComponentPairs=fp,pooledDetails=details,paired=dict(natural))
    if structural:
        full=read(structural)
        check(full['status']=='VERIFIED' and full['finalJarSha256']==report['candidateJar'] and full['referencePools']==len(group) and full['referenceNodes']==len(refs) and full['zeroNativeSha256']==checks['zero.jsonl.gz'], 'Wrong independent complete pool census')
        check(all((v['zeros'],v['structuralForms'],v['componentPairs'])==(len(zeros),zc,zp) for v in full['components'].values()), 'Graph recounts differ')
        check(full['recordedPositiveInputs']+len(zeros)==full['allPairs']==sum(len(g)*(len(g)-1)//2 for g in group.values()), 'Within-pool census incomplete')
        report['positiveScoreRecountSha256']=sha(structural)
        report['fullyClassifiedPairs']=full['allPairs']
    return report


def inventory(release, repo, folder):
    tables = ('zero', 'fixed', 'sat-control', 'paired', 'archived-original-command-results')
    return dict(
        archive={str(p.relative_to(release)):sha(p) for p in (
            release/'reference-pool-scores/summary.json',release/'reference-pool-scores/files.json',
            release/'reference-pool-scores/reference-catalog.tsv',release/'retention/SHA256.json',
            release/'retention/combined-verdict.json',*(release/'retention'/(name+'.jsonl.gz') for name in tables))},
        repository={'docs/experimental-results/historical-retention/correct-pools.csv':
                    sha(repo/'docs/experimental-results/historical-retention/correct-pools.csv')},
        files={name:sha(folder/name) for name in ('verify.py','summary.json','README.md')},
    )


def verify(release, repo, folder):
    pool=release/'reference-pool-scores'
    need=inventory(release,repo,folder)
    check(read(folder/'files.json')==need, 'Changed component verifier, frozen inputs or derived output')
    scores=subprocess.run([sys.executable,'-B',str(pool/'verify.py'),str(pool),'--repo',str(repo)],check=True,capture_output=True)
    check(json.loads(scores.stdout)==read(pool/'summary.json'), 'Portable structural recount does not reproduce its result')
    report=measure(release/'retention',pool/'reference-catalog.tsv',repo/'docs/experimental-results/historical-retention/correct-pools.csv',pool/'summary.json')
    check(report==read(folder/'summary.json'), 'Published scoped component or student/oracle counts differ')
    return report


if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('compact',type=Path,nargs='?');p.add_argument('catalog',type=Path,nargs='?');p.add_argument('historical_pool_counts',type=Path,nargs='?')
    p.add_argument('--complete-pool-summary',type=Path);p.add_argument('--archive',type=Path);p.add_argument('--repo',type=Path)
    a=p.parse_args()
    if a.archive:
        if not a.repo or any((a.compact,a.catalog,a.historical_pool_counts,a.complete_pool_summary)):
            p.error('Use --archive and --repo together for a portable release')
        result=verify(a.archive,a.repo,Path(__file__).resolve().parent)
    else:
        if not all((a.compact,a.catalog,a.historical_pool_counts)) or a.repo:
            p.error('Expected compact retention directory, catalog and historical pool counts')
        result=measure(a.compact,a.catalog,a.historical_pool_counts,a.complete_pool_summary)
    print(json.dumps(result,sort_keys=True,indent=2))
