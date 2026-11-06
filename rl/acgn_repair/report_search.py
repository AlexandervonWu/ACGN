"""Generate the comparison from completed pilot outputs, retaining unequal-budget caveats."""
import argparse
import collections
import json
from pathlib import Path

from .experiment import sha, write_json
from .search_study import ROOT, PROOF, tasks


def language_diagnostics(rows):
    attempts = [attempt for row in rows for attempt in row['attempts']]
    responses = [attempt['response'].get('response', attempt['response']) for attempt in attempts]
    return dict(attempts=len(attempts),
                statuses=dict(collections.Counter(attempt['status'] for attempt in attempts)),
                incompleteResponses=sum(response.get('done') is not True for response in responses),
                outputTokenLimits=sum(response.get('done_reason') == 'length' for response in responses))


def report(folder):
    expected={t['id'] for t in tasks() if t['split']=='evaluation'}
    groups=collections.defaultdict(list)
    policy=json.loads((folder/'policy/runs.json').read_text())
    training=[r for r in policy if r['method']=='training-search']
    for row in policy:
        if row['method']!='training-search': groups[row['method']].append(row)
    for name in ('tar','base','sft','ce'):
        groups[name]=json.loads((folder/name/'runs.json').read_text())
    summaries=[]
    for name,rows in groups.items():
        repetitions=3 if name in ('uniform-puct','learned-puct','random-tree-walk') else 1
        counts=collections.Counter(r['task'] for r in rows)
        if set(counts)!=expected or set(counts.values())!={repetitions}:
            raise ValueError('Missing or duplicated tasks for '+name)
        for row in rows:
            if row['solved']:
                receipts=[row.get('receipt')] if 'attempts' not in row or isinstance(row['attempts'],int) else [a.get('receipt') for a in row['attempts']]
                if not any(r and r['accepted'] and r['proofHash']==sha(PROOF) for r in receipts):
                    raise ValueError('Solved result lacks a current proof admission')
        summaries.append(dict(method=name,solved=sum(r['solved'] for r in rows),trials=len(rows),
            uniqueTasks=len(expected),seconds=sum(r['seconds'] for r in rows),
            infrastructureErrors=(sum(r.get('reported') is None or 'error' in r.get('reported',{})
                                     or r.get('exitCode') not in (0,1,2) for r in rows) if name=='tar' else None),
            unrevalidatedClaims=(sum(bool((r.get('reported') or {}).get('solved')) and not r['solved'] for r in rows) if name=='tar' else None),
            timeouts=(sum(r.get('status')=='EXTERNAL_TIMEOUT' or bool((r.get('reported') or {}).get('timed_out')) for r in rows) if name=='tar' else None),
            perSeed={str(seed):sum(r['solved'] for r in rows if r.get('seed')==seed)
                     for seed in sorted({r['seed'] for r in rows if 'seed' in r})}))
        if name in ('base', 'sft', 'ce'):
            summaries[-1]['generation'] = language_diagnostics(rows)
    adapters={name:json.loads((folder/f'{name}-adapter/manifest.json').read_text()) for name in ('sft','ce')}
    if any(m['status']!='probe_complete' or m['adapter_reload_max_abs_error']!=0 for m in adapters.values()):
        raise ValueError('Unfinished adapter training')
    value=dict(status='COMPLETE_BOUNDED_PILOT',methods=summaries,
               trainingSearch=dict(tasks=len(training),solved=sum(r['solved'] for r in training),
                                   updates=sum(r['updates'] for r in training),seconds=sum(r['seconds'] for r in training)),
               adapters={name:{k:m[k] for k in ('steps','seconds','selected_rows','trainable_parameters','adapter_reload_max_abs_error')}
                         for name,m in adapters.items()},
               proofHash=sha(PROOF),wholeApplicationRefinement='BLOCKED',
               scope='8 held-out predicates, scope 3; unequal mutation/proposal spaces and budgets; not stable superiority')
    write_json(folder/'comparison.json',value)
    lines=['# Verifier-Guided Repair Pilot','',value['scope'],'','## Results','']
    for row in summaries:
        lines.append(f"- {row['method']}: {row['solved']}/{row['trials']} checked repairs; {row['uniqueTasks']} distinct tasks; {row['seconds']:.2f} total evaluation seconds; per-seed {row['perSeed']}.")
        if row['method']=='tar':
            lines.append(f"  TAR timeouts {row['timeouts']}; infrastructure errors {row['infrastructureErrors']}; unrevalidated claims {row['unrevalidatedClaims']}.")
        if 'generation' in row:
            lines.append(f"  Generation diagnostics: {row['generation']}. Incomplete responses and token limits overlap with status counts; they are not additional trials.")
    lines += ['', '## Training', '', f"Search learning: {value['trainingSearch']}."]
    for name,m in value['adapters'].items(): lines.append(f'- {name}: {m}.')
    lines.append('Adapter seconds measure the training loop only, excluding checkpoint loading and export. SFT has 16 updates; CE has 30, so counterexample content is confounded with training amount.')
    lines += ['', '## Interpretation', '',
        'The search arms use the same typed menu and 32 simulations at depth 3. TAR uses its broader mutation inventory and a 60-second search deadline. Qwen gets up to four 512-token body proposals with counterexample feedback. These are practical pilot results, not a compute- or action-space-matched superiority claim.',
        '', 'Qwen LoRA training uses the local NF4 checkpoint; inference applies exported adapters to the unadapted local Q3 base. Neither the existing AIx default model nor the original dataset is changed.',
        '', 'Success is checked only within the shared bounded Alloy profile. Lean proves the abstract acceptance/pruning rules and checks admission receipts. Full implementation refinement and universal semantic validity remain unproved.',
        '', 'The earlier graph-policy study was interrupted and remains a separate negative result; its partial test totals are not mixed into these denominators.']
    (folder/'summary.md').write_text('\n'.join(lines)+'\n')
    files=[p for p in folder.rglob('*') if p.is_file() and p.name!='output-hashes.json']
    write_json(folder/'output-hashes.json',{str(p.relative_to(folder)):sha(p) for p in sorted(files)})


if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('folder',type=Path)
    report(p.parse_args().folder)
