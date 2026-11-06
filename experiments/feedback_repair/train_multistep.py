"""Proof-first, fixed-budget, matched contextual plan-learning study."""
import argparse
import json
import os
from pathlib import Path
import platform
import random
import re
import subprocess
import sys
import tarfile
import time

import torch

from .multistep import (CONTRACT, CARDS, PLANS, MODES, MultistepPolicy, rollout,
                        training_examples, prepare_examples, episode_loss)
from .run_gates import ROOT, sha, write
from .train_gates import worker

SEEDS = (17, 29, 43)
GROUPS = {
    'train': ((0, 1), (1, 0), (0, 2), (2, 0), (1, 3), (3, 1), (2, 3), (3, 2)),
    'validation': ((0, 0), (1, 1), (2, 2), (3, 3)),
    'test': ((0, 3), (3, 0), (1, 2), (2, 1)),
}
INITIALS = {'train': ((3, 3), (1, 1), (2, 2)),
            'validation': ((0, 3), (3, 0)), 'test': ((3, 3), (1, 1))}


def make_tasks(out):
    if len({p for goals in GROUPS.values() for p in goals}) != 16:
        raise ValueError('COMPOSITION_SPLIT_OVERLAP')
    tasks = []
    for split, goals in GROUPS.items():
        for goal in goals:
            for initial in INITIALS[split]:
                if goal == initial:
                    raise ValueError('TRIVIAL_FIXTURE')
                i = len(tasks)
                a, b = (f'Left{i}', f'Right{i}')
                def body(pair):
                    return f'{CARDS[pair[0]][2:].lower()} {a} and {CARDS[pair[1]][2:].lower()} {b}'
                source = out/f'case-{i:03d}.als'
                source.write_text(f'sig {a}, {b} {{}}\npred candidate {{ {body(initial)} }}\n'
                                  f'pred oracle {{ {body(goal)} }}\nrun {{}} for 3\n')
                tasks.append(dict(id=f'case-{i:03d}', path=str(source), target='candidate', oracle='oracle',
                                  command=0, split=split, privateGoal=goal, initial=initial,
                                  sourceHash=sha(source)))
    return tasks


def stats(trials):
    return {'tasks': len(trials), 'solved': sum(t['solved'] for t in trials),
            'errors': sum('error' in t for t in trials),
            'multistepSolved': sum(t['solved'] and len(t['attempts']) >= 2 for t in trials),
            'meanQueries': sum(t['queriesIssued'] for t in trials) / max(1, len(trials)),
            'queryLimit': sum(t['end'] == 'QUERY_LIMIT' for t in trials)}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('output', type=Path)
    parser.add_argument('--updates', type=int, default=400)
    args = parser.parse_args()
    out = args.output.resolve()
    if out.exists() or out == ROOT or ROOT in out.parents or not 1 <= args.updates <= 400:
        parser.error('Fresh external output and 1..400 updates required')
    out.mkdir(parents=True)
    start = time.monotonic()
    proof = ROOT/'docs/canonical-edit-learning/formal/MultistepRepair.lean'
    files = [*ROOT.joinpath('src').rglob('*.java'), *ROOT.joinpath('lib').glob('*.jar'),
             *ROOT.joinpath('experiments/feedback_repair').glob('*.py'),
             *ROOT.joinpath('rl/acgn_repair').glob('*.py'),
             *ROOT.joinpath('docs/canonical-edit-learning/formal').glob('*.lean'),
             ROOT/'docs/canonical-edit-learning/MULTISTEP-REPAIR.md']
    frozen = {str(p.relative_to(ROOT)): sha(p) for p in sorted(set(files))}
    write(out/'input-hashes.json', frozen)
    report = dict(contract=CONTRACT, status='RUNNING', seeds=SEEDS, updates=args.updates,
                  scope='40 synthetic tasks; target-composition-disjoint, not corpus performance',
                  queryBudget=4, decisionBudget=256, config={'width': 48, 'layers': 2},
                  torch=torch.__version__, host=platform.platform(), device='cpu',
                  git=subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip(),
                  dirty=bool(subprocess.check_output(['git', 'status', '--porcelain'], cwd=ROOT)),
                  models=[], baselines=[])
    write(out/'report.json', report)
    commands = []

    def run(command, name, env=None):
        with (out/(name+'.log')).open('w') as log:
            result = subprocess.run(list(map(str, command)), cwd=ROOT, env=env,
                                    stdout=log, stderr=subprocess.STDOUT, timeout=300)
        commands.append(dict(command=list(map(str, command)), log=name+'.log', exitCode=result.returncode))
        write(out/'commands.json', commands)
        result.check_returncode()

    def evaluate_tasks(tasks, mode, seed, model=None):
        trials = []
        for n, task in enumerate(tasks):
            name = f'{mode}-{seed}-{task["id"]}'
            trial = rollout(task, classes, out/(name+'.log'), operators, mode, model, seed)
            write(out/(name+'.json'), trial)
            trials.append(trial)
            if (n+1) % 8 == 0:
                print(f'{mode} seed={seed}: evaluated {n+1}/{len(tasks)}, repaired {sum(t["solved"] for t in trials)}', flush=True)
        return {split: stats([t for t in trials if t['split'] == split]) for split in GROUPS}

    try:
        for build in (1, 2):
            directory = out/f'proof-{build}'; directory.mkdir()
            run(['lean', '-o', directory/'MultistepRepair.olean', proof], f'proof-{build}')
            log = (out/f'proof-{build}.log').read_text()
            names = re.findall(r"^'MultistepRepair\.(\w+)'", log, re.M)
            deps = {w.strip() for group in re.findall(r'depends on axioms: \[([^]]*)\]', log)
                    for w in group.split(',') if w.strip()}
            if len(set(names)) != 15 or len(names) != 15 or 'warning:' in log or not deps <= {'propext', 'Quot.sound'}:
                raise ValueError('PROOF_INVENTORY_OR_DEPENDENCY')
        if (out/'proof-1.log').read_text() != (out/'proof-2.log').read_text():
            raise ValueError('PROOF_NONDETERMINISM')
        run([sys.executable, '-m', 'experiments.feedback_repair.local_preflight', out/'base'], 'base-preflight')
        base_inputs = json.loads((out/'base/input-hashes.json').read_text())
        if any(name in frozen and frozen[name] != digest for name, digest in base_inputs.items()):
            raise ValueError('BASE_INPUT_CHANGED')
        frozen.update(base_inputs)
        write(out/'input-hashes.json', frozen)
        classes = out/'base/classes'
        run(['lean', ROOT/'docs/canonical-edit-learning/formal/ContextualRepair.lean'], 'contextual-proof')
        run([sys.executable, '-m', 'unittest', 'experiments.feedback_repair.test_contextual',
             'experiments.feedback_repair.test_multistep', '-v'], 'contextual-multistep-tests',
            {**os.environ, 'FEEDBACK_TEST_CLASSES': str(classes), 'OMP_NUM_THREADS': '2'})
        log = (out/'contextual-multistep-tests.log').read_text()
        if 'Ran 21 tests' not in log or not re.search(r'^OK$', log, re.M):
            raise ValueError('TEST_INVENTORY')
        with worker(classes, out/'catalog.log') as process:
            catalog = process.request('catalog')
        write(out/'catalog.json', catalog)
        operators = catalog['operators']
        tasks = make_tasks(out)
        write(out/'tasks.json', tasks)
        examples, demos = [], []
        for i, task in enumerate(t for t in tasks if t['split'] == 'train'):
            name = task['id']
            trial = rollout(task, classes, out/(name+'-demo.log'), operators)
            write(out/(name+'-demo.json'), trial)
            examples.append(training_examples(task, trial, classes, out/(name+'-replay.log'), operators))
            demos.append(trial)
            print(f'Public search/replay {i+1}/24: {trial["end"]}, {len(trial["attempts"])} attempts', flush=True)
        report['teacher'] = stats(demos)
        report['teacherPlanChoices'] = sum(len(e) for e in examples)
        report['trainingEpisodesWithFailedAttempt'] = sum(len(e) >= 2 for e in examples)
        prepared = {mode: [prepare_examples(e, operators, mode) for e in examples] for mode in MODES}
        torch.set_num_threads(2)
        torch.use_deterministic_algorithms(True)
        for seed in SEEDS:
            for mode in MODES:
                torch.manual_seed(seed)
                rng = random.Random(seed)
                model = MultistepPolicy(mode, **report['config'])
                optimizer = torch.optim.AdamW(model.parameters(), lr=0.001, weight_decay=0.001)
                gradients = []
                for update in range(args.updates):
                    model.train(); optimizer.zero_grad(set_to_none=True)
                    index = rng.randrange(len(examples))
                    loss = episode_loss(model, prepared[mode][index])
                    if not torch.isfinite(loss):
                        raise ValueError('NONFINITE_LOSS')
                    loss.backward()
                    norm = float(torch.nn.utils.clip_grad_norm_(model.parameters(), 1, error_if_nonfinite=True))
                    if norm <= 0:
                        raise ValueError('ZERO_GRADIENT')
                    optimizer.step()
                    gradients.append(dict(update=update+1, episode=index, loss=float(loss.detach()), norm=norm))
                    if (update+1) % 100 == 0:
                        print(f'{mode} seed={seed}: update {update+1}/{args.updates}, loss={float(loss.detach()):.4f}', flush=True)
                name = f'{mode}-{seed}'
                write(out/(name+'-gradients.json'), gradients)
                checkpoint = out/(name+'.pt')
                torch.save(dict(contract=CONTRACT, mode=mode, config=report['config'], state_dict=model.state_dict()), checkpoint)
                loaded = MultistepPolicy(mode, **report['config'])
                loaded.load_state_dict(torch.load(checkpoint, map_location='cpu', weights_only=True)['state_dict'], strict=True)
                if any(not torch.isfinite(p).all() for p in loaded.parameters()):
                    raise ValueError('NONFINITE_CHECKPOINT')
                accuracy = []
                with torch.no_grad():
                    loaded.eval()
                    for episode in prepared[mode]:
                        memory = None
                        for x, target, _ in episode:
                            logits, _, memory = loaded(x, memory)
                            accuracy.append(int(logits.argmax()) == target)
                row = dict(mode=mode, seed=seed, parameters=sum(p.numel() for p in model.parameters()),
                           checkpointHash=sha(checkpoint), teacherChoiceAccuracy=sum(accuracy)/len(accuracy),
                           results=evaluate_tasks(tasks, mode, seed, loaded))
                report['models'].append(row)
                write(out/'report.json', report)
        heldout = [t for t in tasks if t['split'] != 'train']
        report['baselines'].append(dict(mode='search', seed=17, results=evaluate_tasks(heldout, 'search', 17)))
        for seed in SEEDS:
            report['baselines'].append(dict(mode='random', seed=seed, results=evaluate_tasks(heldout, 'random', seed)))
        if any(sha(ROOT/name) != digest for name, digest in frozen.items()):
            raise ValueError('FROZEN_INPUT_CHANGED')
        if any(sha(t['path']) != t['sourceHash'] for t in tasks):
            raise ValueError('TASK_CHANGED')
        report.update(status='STUDY_COMPLETE', seconds=time.monotonic()-start, newLeanDeclarations=15,
                      additionalRuntimeTests=21, trainTasks=24, validationTasks=8, testTasks=8,
                      corpus='NOT_RUN', generalizationClaim='Synthetic heldout compositions only')
        write(out/'report.json', report)
        with tarfile.open(out/'frozen-sources.tar.gz', 'w:gz') as archive:
            for name in sorted(frozen):
                if not name.endswith('.jar'):
                    archive.add(ROOT/name, arcname=name)
    except Exception as error:
        report.update(status='FAILED', error=type(error).__name__+': '+str(error), seconds=time.monotonic()-start)
        write(out/'report.json', report)
        raise
    finally:
        write(out/'output-hashes.json', {str(p.relative_to(out)): sha(p) for p in sorted(out.rglob('*'))
                                        if p.is_file() and p != out/'output-hashes.json'})
    print(json.dumps(report, indent=2))


if __name__ == '__main__':
    main()
