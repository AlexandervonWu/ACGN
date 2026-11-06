"""Small research report for a finished graph-program experiment."""
import argparse
import collections
import json
from pathlib import Path

from experiments.hybrid_edit.corpus import write


def main():
    p=argparse.ArgumentParser(); p.add_argument('--run',type=Path,required=True)
    p.add_argument('--data',type=Path,required=True); p.add_argument('--output',type=Path,required=True)
    args=p.parse_args(); args.output.mkdir(parents=True,exist_ok=True)
    result=json.loads((args.run/'results.json').read_text())
    manifest=json.loads((args.run/'manifest.json').read_text())
    history=json.loads((args.run/'history.json').read_text())
    predictions=json.loads((args.run/'test_predictions.json').read_text())
    data=json.loads((args.data/'summary.json').read_text())
    groups=collections.defaultdict(list)
    for r in predictions: groups[r['group']].append(r)
    group_results={name:{'count':len(rows),'exact':sum(r['targetGraphExact'] for r in rows),
                        'valid':sum(r['validReplay'] for r in rows)} for name,rows in sorted(groups.items())}
    errors=collections.Counter(r.get('replayError','VALID').split(':',1)[0] for r in predictions)
    write(args.output/'results.json',result); write(args.output/'history.json',history)
    write(args.output/'manifest.json',manifest); write(args.output/'data-summary.json',data)
    write(args.output/'by-question.json',group_results)
    diagnostic_path=args.run/'training-diagnostic/results.json'
    diagnostic=json.loads(diagnostic_path.read_text()) if diagnostic_path.exists() else None
    if diagnostic: write(args.output/'training-diagnostic.json',diagnostic)
    write(args.output/'examples.json',[{k:r[k] for k in ('id','source','group','tokens')} for r in predictions if r['targetGraphExact']])
    test=result['test']; val=result['validation']
    lines=['# Graph-To-Complete-Program Training Result','',
        'This is a bounded supervised graph-reconstruction result, not an Alloy solver repair rate.','',
        '## Protocol','',
        f"- Train / validation / test: {manifest['splitCounts']['train']} / {manifest['splitCounts']['validation']} / {manifest['splitCounts']['evaluation']} pairs.",
        f"- Parameters: {manifest['parameters']:,}; vocabulary 128; full training from scratch.",
        f"- Epochs: {manifest['arguments']['epochs']}; effective batch {manifest['arguments']['effective_batch']}; microbatch {manifest['arguments']['microbatch']}.",
        '- Question-disjoint splits; exact input overlaps removed from later splits; no one-step menu.',
        '- Module schema, source-only symbol table and faulty DAG are the key; a complete COPY/BUILD program is the value.',
        '- FP32 master weights, BF16 computation, Adafactor, peak learning rate 0.0001.',
        f"- Checkpoint criterion: {manifest['selection']}; selected epoch {result['selectedEpoch']}.",'',
        '## Measured Results','',
        f"- Held-out exact target graphs: {test['targetGraphExact']}/{test['count']} ({100*test['targetGraphExact']/test['count']:.2f}%).",
        f"- Held-out exact token programs: {test['programExact']}/{test['count']}.",
        f"- Held-out syntactically replayable programs: {test['validReplay']}/{test['count']}.",
        f"- Held-out ROOT-shaped outputs: {test['rootShape']}/{test['count']} (not a type check).",
        f"- Unchanged-graph baseline exact matches: {result['unchangedBaselineExact']}/{test['count']}.",
        f"- Validation exact target graphs: {val['targetGraphExact']}/{val['count']}.",
        (f"- Post-selection training sample exact graphs: {diagnostic['targetGraphExact']}/{diagnostic['count']} (not held-out evidence)."
         if diagnostic else '- Training-set free-generation diagnostic not run.'),
        f"- Test target-token cross entropy: {result['testTokenLoss']:.6f} nats.",
        f"- First / last epoch training token loss: {history[0]['trainingTokenLoss']:.6f} / {history[-1]['trainingTokenLoss']:.6f}.",
        f"- Stop counts: {json.dumps(test['stopCounts'],sort_keys=True)}.",
        f"- Replay categories: {json.dumps(errors,sort_keys=True)}.",
        f"- Training: {result['trainingSeconds']/60:.2f} minutes; training plus evaluation: {result['totalSeconds']/60:.2f} minutes.",
        f"- Peak device memory: {result['peakAllocatedGiB']:.3f} GiB allocated / {result['peakReservedGiB']:.3f} GiB reserved.",'',
        '## Interpretation','',
        'The old menu permitted a successful one-step repair for only 2/192 of its test cases. '
        'This experiment removes that representational ceiling: every admitted teacher program '
        'replays to the full target. The corpus, splits and success criterion differ, so the '
        'new rate is not a head-to-head behavioral improvement claim.',
        '',
        'Exact graph match is stricter than semantic equivalence and may reject another valid '
        'repair. Replay validity is weaker than type correctness. Generated metadata is never '
        'accepted as certificate authority. Source realization, reparsing and the existing '
        'two-direction solver gate remain required before behavioral repair can be reported.',
        '',
        'A single eight-epoch seed does not establish convergence, stable superiority over '
        'random walks, or a model-scaling result. Intended behavior may also be ambiguous '
        'from a faulty graph and declaration schema without a natural-language specification.',
        '',
        '## Evidence','',
        '- Eight model-level Lean theorems precede the implementation; they are not a whole-program refinement proof.',
        '- Codec replay, source-only inputs, alpha renaming, temporal targets, loss masking, gradient accumulation, '
        'cached decoding and synthetic complete-program learning have bounded regression tests.',
        f"- Run: `{args.run.parent.resolve()}`.",
        f"- Checkpoint SHA-256: `{result['checkpointHash']}`.",
        '- Small summaries and per-question results are alongside this report; full predictions, packets and raw exports remain in the run directory.','']
    (args.output/'RESULTS.md').write_text('\n'.join(lines),encoding='utf-8')


if __name__=='__main__': main()
