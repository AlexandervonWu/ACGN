"""Proof-first contextual prototype checks and a tiny, explicitly non-corpus pilot."""
import argparse
import json
import os
from pathlib import Path
import random
import re
import subprocess
import sys
import time

import torch

from .contextual import (ContextualPolicy, PublicUnarySearch, run_episode,
                         replay_for_training, sequence_loss)
from .run_gates import ROOT, sha, write
from .train_gates import worker


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('output', type=Path)
    parser.add_argument('--updates', type=int, default=120)
    parser.add_argument('--device', choices=('cpu', 'cuda'), default='cpu')
    args = parser.parse_args()
    out = args.output.resolve()
    if out.exists() or out == ROOT or ROOT in out.parents or not 1 <= args.updates <= 500:
        parser.error('Fresh external output and 1..500 bounded updates required')
    out.mkdir(parents=True)
    started, commands = time.monotonic(), []
    extra = [ROOT/'docs/canonical-edit-learning/CONTEXTUAL-REPAIR.md',
             ROOT/'docs/canonical-edit-learning/formal/ContextualRepair.lean']
    frozen = {str(p.relative_to(ROOT)): sha(p) for p in extra}
    report = {'contract': 'contextual-feedback-repair-v1', 'status': 'RUNNING',
              'scope': 'Three synthetic training fixtures, not held-out or corpus performance',
              'updates': 0, 'requestedUpdates': args.updates, 'queryBudget': 4,
              'git': subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip(),
              'dirty': bool(subprocess.check_output(['git', 'status', '--porcelain'], cwd=ROOT))}
    write(out/'report.json', report)

    def run(command, name, env=None):
        with (out/(name+'.log')).open('w') as log:
            result = subprocess.run(list(map(str, command)), cwd=ROOT, env=env,
                                    stdout=log, stderr=subprocess.STDOUT, timeout=300)
        commands.append({'name': name, 'exitCode': result.returncode})
        write(out/'commands.json', commands)
        result.check_returncode()

    try:
        proof = extra[1]
        for build in (1, 2):
            directory = out/f'proof-{build}'; directory.mkdir()
            run(['lean', '-o', directory/'ContextualRepair.olean', proof], f'proof-{build}')
            log = (out/f'proof-{build}.log').read_text()
            names = re.findall(r"^'ContextualRepair\.(\w+)'", log, re.M)
            if len(names) != 16 or len(set(names)) != 16 or 'sorryAx' in log or 'warning:' in log:
                raise ValueError('INCOMPLETE_CONTEXT_PROOF_BUILD')
            dependencies = {word.strip() for block in re.findall(r'depends on axioms: \[([^]]*)\]', log)
                            for word in block.split(',') if word.strip()}
            if not dependencies <= {'propext', 'Quot.sound', 'Classical.choice'}:
                raise ValueError('UNDECLARED_PROOF_DEPENDENCY')
        if (out/'proof-1.log').read_text() != (out/'proof-2.log').read_text():
            raise ValueError('PROOF_INVENTORY_CHANGED')
        run([sys.executable, '-m', 'experiments.feedback_repair.local_preflight', out/'base'], 'base-preflight')
        base_inputs = json.loads((out/'base/input-hashes.json').read_text())
        if any(name in base_inputs and base_inputs[name] != digest for name, digest in frozen.items()):
            raise ValueError('PROOF_INPUT_CHANGED_BEFORE_RUNTIME_BUILD')
        frozen.update(base_inputs)
        write(out/'input-hashes.json', frozen)
        classes = out/'base/classes'
        run([sys.executable, '-m', 'unittest', 'experiments.feedback_repair.test_contextual', '-v'],
            'contextual-tests', {**os.environ, 'FEEDBACK_TEST_CLASSES': str(classes), 'OMP_NUM_THREADS': '2'})
        test_log = (out/'contextual-tests.log').read_text()
        if 'Ran 10 tests' not in test_log or not re.search(r'^OK$', test_log, re.M):
            raise ValueError('CONTEXTUAL_TEST_INVENTORY_INCOMPLETE')
        with worker(classes, out/'catalog.log') as process:
            operators = process.request('catalog')['operators']
        tasks, episodes, trials = [], [], []
        for i, goal in enumerate(('one S', 'lone S', '#S = 2')):
            source = out/f'fixture-{i}.als'
            source.write_text('sig S {}\npred candidate { some S }\npred oracle { '+goal+' }\nrun {} for 3\n')
            task = dict(id=f'fixture-{i}', path=str(source), target='candidate', oracle='oracle', command=0, split='train')
            trial = run_episode(task, classes, out/f'demo-{i}.log', proposer=PublicUnarySearch(operators))
            write(out/f'demo-{i}.json', trial)
            episodes.append(replay_for_training(task, trial, classes, out/f'replay-{i}.log'))
            trials.append(trial); tasks.append(task)
        write(out/'tasks.json', tasks)
        torch.set_num_threads(2); torch.manual_seed(17); rng = random.Random(17)
        if args.device == 'cuda': torch.cuda.reset_peak_memory_stats()
        config = dict(width=32, layers=1, variant='gin')
        model = ContextualPolicy(**config).to(args.device)
        optimizer = torch.optim.AdamW(model.parameters(), lr=0.001, weight_decay=0.001)
        gradients = []
        for step in range(args.updates):
            model.train(); optimizer.zero_grad(set_to_none=True)
            index = rng.randrange(len(episodes))
            loss = sequence_loss(model, episodes[index], operators, args.device)
            if not torch.isfinite(loss): raise ValueError('NONFINITE_CONTEXT_LOSS')
            loss.backward()
            norm = float(torch.nn.utils.clip_grad_norm_(model.parameters(), 1.0, error_if_nonfinite=True))
            if norm <= 0: raise ValueError('ZERO_CONTEXT_GRADIENT')
            optimizer.step()
            gradients.append({'update': step+1, 'episode': index, 'loss': float(loss.detach()), 'gradientNorm': norm})
            report['updates'] = step+1
            if (step+1) % 20 == 0:
                write(out/'gradients.json', gradients)
                print(f'Contextual fixture fitting {step+1}/{args.updates}, loss={float(loss.detach()):.4f}', flush=True)
        write(out/'gradients.json', gradients)
        checkpoint = out/'policy.pt'
        torch.save({'contract': report['contract'], 'config': config, 'state_dict': model.state_dict()}, checkpoint)
        loaded = ContextualPolicy(**config).to(args.device)
        loaded.load_state_dict(torch.load(checkpoint, map_location=args.device, weights_only=True)['state_dict'], strict=True)
        if any(not torch.isfinite(p).all() for p in loaded.parameters()): raise ValueError('NONFINITE_CHECKPOINT')
        learned = []
        for i, task in enumerate(tasks):
            trial = run_episode(task, classes, out/f'learned-{i}.log', model=loaded, device=args.device)
            write(out/f'learned-{i}.json', trial); learned.append(trial)
        if any(sha(ROOT/name) != digest for name, digest in frozen.items()):
            raise ValueError('FROZEN_INPUT_CHANGED')
        report.update(status='PROTOTYPE_CHECKED', proofDeclarations=16, contextualTests=10,
                      demoSolved=sum(t['solved'] for t in trials), demoQueries=[t['queriesIssued'] for t in trials],
                      learnedSolved=sum(t['solved'] for t in learned), learnedErrors=sum('error' in t for t in learned),
                      learnedEnds=[t['end'] for t in learned], tasks=3,
                      parameters=sum(p.numel() for p in model.parameters()), checkpointHash=sha(checkpoint),
                      device=args.device, torch=torch.__version__,
                      peakCudaAllocatedBytes=torch.cuda.max_memory_allocated() if args.device=='cuda' else 0,
                      seconds=time.monotonic()-started, heldout='NOT_RUN', corpus='NOT_RUN')
        write(out/'report.json', report)
    except Exception as error:
        report.update(status='FAILED', error=type(error).__name__+': '+str(error))
        write(out/'report.json', report)
        raise
    finally:
        write(out/'output-hashes.json', {str(p.relative_to(out)): sha(p) for p in sorted(out.rglob('*'))
                                        if p.is_file() and p != out/'output-hashes.json'})
    print(json.dumps(report, indent=2))


if __name__ == '__main__':
    main()
