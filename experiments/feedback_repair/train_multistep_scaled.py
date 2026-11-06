"""Bounded variable-arity scaling with coverage, fixed exposure and held-out locking."""
import argparse
from collections import Counter
from concurrent.futures import ThreadPoolExecutor
from itertools import combinations_with_replacement
import json
import os
from pathlib import Path
import random
import re
import subprocess
import sys
import tarfile
import time

import torch

from .local_runtime import load, execute
from .multistep_scale import (CONTRACT, CARDS, plans, shape, evidence, rollout,
                              training_examples, ScalePolicy, loss)
from .run_gates import ROOT, sha, write
from .train_gates import worker
from .train_multistep import stats

CONFIGS = ({'width': 48, 'layers': 2}, {'width': 96, 'layers': 3})
SEEDS = (17, 29, 43)


def make_tasks(out):
    rng = random.Random(351)
    groups = list(combinations_with_replacement(range(4), 3)); rng.shuffle(groups)
    sections = [('train', groups[:12], 6), ('validation', groups[12:16], 4), ('test', groups[16:], 4)]
    extra = list(combinations_with_replacement(range(4), 4)); rng.shuffle(extra)
    sections.append(('arity4', extra[:16], 1))
    tasks = []
    for split, goals, count in sections:
        for orbit in goals:
            for op in ('AND', 'OR'):
                goal = list(orbit); rng.shuffle(goal); goal = tuple(goal)
                choices = [p for p in plans(len(goal)) if p != goal]; rng.shuffle(choices)
                for initial in choices[:count]:
                    i = len(tasks); names = [f'S{i}x{j}' for j in range(len(goal))]
                    def body(cards):
                        return (' '+op.lower()+' ').join(CARDS[c][2:].lower()+' '+s for c, s in zip(cards, names))
                    source = out/f'case-{i:03d}.als'
                    source.write_text('sig '+', '.join(names)+' {}\npred candidate { '+body(initial)+
                                      ' }\npred oracle { '+body(goal)+' }\nrun {} for 3\n')
                    tasks.append(dict(id=f'case-{i:03d}', path=str(source), target='candidate', oracle='oracle',
                                      command=0, split=split, sourceHash=sha(source), arity=len(goal),
                                      connective=op, privateGoal=goal, initial=initial,
                                      explore=split == 'train' and i % 2 == 1))
    keys = {}
    for t in tasks:
        key = (t['arity'], tuple(sorted(t['privateGoal'])))
        if keys.setdefault(key, t['split']) != t['split']:
            raise ValueError('SEMANTIC_GROUP_SPLIT_OVERLAP')
    if Counter(t['split'] for t in tasks) != Counter(train=144, validation=32, test=32, arity4=32):
        raise ValueError('TASK_INVENTORY')
    return tasks


def metrics(trials):
    return {s: {**stats([t for t in trials if t['split'] == s]),
                'inconsistentProposals': sum(not a['consistent'] for t in trials if t['split'] == s for a in t['attempts']),
                'proposals': sum(len(t['attempts']) for t in trials if t['split'] == s)}
            for s in ('train', 'validation', 'test', 'arity4')}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('output', type=Path)
    args = parser.parse_args()
    out = args.output.resolve()
    if out.exists() or out == ROOT or ROOT in out.parents:
        parser.error('Fresh external output required')
    out.mkdir(parents=True)
    start = time.monotonic()
    proof = ROOT/'docs/canonical-edit-learning/formal/MultistepScaling.lean'
    taskfile = ROOT/'docs/rl-corpus-data/tasks.json'
    natural = json.loads(taskfile.read_text())['tasks']
    files = [*ROOT.joinpath('src').rglob('*.java'), *ROOT.joinpath('lib').glob('*.jar'),
             *ROOT.joinpath('experiments/feedback_repair').glob('*.py'), *ROOT.joinpath('rl/acgn_repair').glob('*.py'),
             *ROOT.joinpath('docs/canonical-edit-learning/formal').glob('*.lean'),
             ROOT/'docs/canonical-edit-learning/MULTISTEP-SCALING.md', taskfile,
             *(ROOT/'docs/rl-corpus-data'/t['path'] for t in natural)]
    frozen = {str(p.relative_to(ROOT)): sha(p) for p in sorted(set(files))}
    write(out/'input-hashes.json', frozen)
    report = dict(contract=CONTRACT, status='RUNNING', epochs=16, seeds=SEEDS, configs=CONFIGS,
                  queryBudget=4, decisionBudget=256, workers=2, device='cpu', torch=torch.__version__,
                  git=subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip(),
                  dirty=bool(subprocess.check_output(['git', 'status', '--porcelain'], cwd=ROOT)),
                  screening=[], evaluations=[], baselines=[])
    write(out/'report.json', report)
    commands = []

    def run(command, name, env=None):
        with (out/(name+'.log')).open('w') as log:
            r = subprocess.run(list(map(str, command)), cwd=ROOT, stdout=log, stderr=subprocess.STDOUT,
                               env=env, timeout=300)
        commands.append(dict(name=name, command=list(map(str, command)), exitCode=r.returncode))
        write(out/'commands.json', commands); r.check_returncode()

    def batch_map(function, items, label):
        values = []
        with ThreadPoolExecutor(max_workers=2) as pool:
            for i in range(0, len(items), 2):
                values.extend(pool.map(function, items[i:i+2]))
                if len(values) % 16 == 0 or len(values) == len(items):
                    print(f'{label} {len(values)}/{len(items)}', flush=True)
        return values

    def evaluate_tasks(tasks, mode, seed, name, model=None):
        def one(task):
            trial = rollout(task, classes, out/f'{name}-{task["id"]}.log', operators, mode, model, seed)
            write(out/f'{name}-{task["id"]}.json', trial)
            return trial
        return metrics(batch_map(one, tasks, name))

    def fit(config, seed, name):
        torch.manual_seed(seed); rng = random.Random(seed)
        model = ScalePolicy(**config)
        optimizer = torch.optim.AdamW(model.parameters(), lr=0.001, weight_decay=0.001)
        gradients, exposures = [], Counter()
        for epoch in range(16):
            order = list(range(len(training))); rng.shuffle(order)
            for index in order:
                model.train(); optimizer.zero_grad(set_to_none=True)
                value = loss(model, training[index])
                if not torch.isfinite(value):
                    raise ValueError('NONFINITE_LOSS')
                value.backward()
                norm = float(torch.nn.utils.clip_grad_norm_(model.parameters(), 1, error_if_nonfinite=True))
                if norm <= 0:
                    raise ValueError('ZERO_GRADIENT')
                optimizer.step(); exposures[index] += 1
                gradients.append(dict(epoch=epoch+1, episode=index, loss=float(value.detach()), norm=norm))
            if (epoch+1) % 4 == 0:
                print(f'{name}: epoch {epoch+1}/16, updates={len(gradients)}, loss={float(value.detach()):.4f}', flush=True)
        if set(exposures.values()) != {16} or len(exposures) != len(training):
            raise ValueError('UNBALANCED_EXPOSURE')
        write(out/(name+'-gradients.json'), gradients)
        checkpoint = out/(name+'.pt')
        torch.save(dict(contract=CONTRACT, config=config, state_dict=model.state_dict()), checkpoint)
        loaded = ScalePolicy(**config)
        loaded.load_state_dict(torch.load(checkpoint, map_location='cpu', weights_only=True)['state_dict'], strict=True)
        if any(not torch.isfinite(p).all() for p in loaded.parameters()):
            raise ValueError('NONFINITE_CHECKPOINT')
        loaded.eval()
        info = dict(name=name, config=config, seed=seed, parameters=sum(p.numel() for p in model.parameters()),
                    updates=len(gradients), passesPerEpisode=16, checkpointHash=sha(checkpoint))
        write(out/(name+'-fit.json'), info)
        return loaded, info

    try:
        for build in (1, 2):
            directory = out/f'proof-{build}'; directory.mkdir()
            run(['lean', '-o', directory/'MultistepScaling.olean', proof], f'proof-{build}')
            log = (out/f'proof-{build}.log').read_text()
            names = re.findall(r"^'MultistepScaling\.(\w+)'", log, re.M)
            deps = {w.strip() for g in re.findall(r'depends on axioms: \[([^]]*)\]', log) for w in g.split(',') if w.strip()}
            if len(names) != 15 or len(set(names)) != 15 or 'warning:' in log or not deps <= {'propext', 'Quot.sound'}:
                raise ValueError('PROOF_INVENTORY')
        if (out/'proof-1.log').read_text() != (out/'proof-2.log').read_text():
            raise ValueError('PROOF_NONDETERMINISM')
        run([sys.executable, '-m', 'experiments.feedback_repair.local_preflight', out/'base'], 'base-preflight')
        base_inputs = json.loads((out/'base/input-hashes.json').read_text())
        if any(n in frozen and frozen[n] != h for n, h in base_inputs.items()):
            raise ValueError('BASE_INPUT_CHANGED')
        frozen.update(base_inputs); write(out/'input-hashes.json', frozen)
        classes = out/'base/classes'
        for name in ('ContextualRepair', 'MultistepRepair'):
            run(['lean', ROOT/f'docs/canonical-edit-learning/formal/{name}.lean'], name)
        run([sys.executable, '-m', 'unittest', 'experiments.feedback_repair.test_contextual',
             'experiments.feedback_repair.test_multistep', 'experiments.feedback_repair.test_multistep_scale', '-v'],
            'multistep-tests', {**os.environ, 'FEEDBACK_TEST_CLASSES': str(classes), 'OMP_NUM_THREADS': '2'})
        if 'Ran 31 tests' not in (out/'multistep-tests.log').read_text():
            raise ValueError('TEST_INVENTORY')
        with worker(classes, out/'catalog.log') as p:
            catalog = p.request('catalog')
        write(out/'catalog.json', catalog); operators = catalog['operators']
        torch.set_num_threads(2); torch.use_deterministic_algorithms(True)

        def audit(task):
            row = dict(id=task['id'], split=task['split'], status='LOAD_FAILED')
            try:
                if sha(ROOT/'docs/rl-corpus-data'/task['path']) != task['sourceHash']:
                    raise ValueError('SOURCE_IDENTITY')
                with worker(classes, out/f'audit-{task["id"]}.log') as p:
                    obs = load(p, task)
                    row['status'] = 'GRAMMAR_UNSUPPORTED'
                    s = shape(obs, operators)
                    row.update(status='FEEDBACK_UNSUPPORTED', arity=len(s.current), connective=s.op)
                    obs = execute(p, obs, {'control': 11})
                    if obs['status'] == 4:
                        evidence(obs, operators)
                        row['status'] = 'SUPPORTED'
                    else:
                        row['status'] = 'INITIAL_'+str(obs['status'])
            except (ValueError, RuntimeError, KeyError, TimeoutError) as error:
                row['error'] = type(error).__name__+': '+str(error)
            return row
        coverage = batch_map(audit, natural, 'Natural-source coverage')
        write(out/'natural-coverage.json', coverage)
        report['naturalCoverage'] = dict(Counter(r['status'] for r in coverage))
        print('Natural coverage:', report['naturalCoverage'], flush=True)
        tasks = make_tasks(out); write(out/'tasks.json', tasks)
        train_tasks = [t for t in tasks if t['split'] == 'train']

        def collect(task):
            name = task['id']
            trial = rollout(task, classes, out/(name+'-demo.log'), operators, explore=task['explore'])
            write(out/(name+'-demo.json'), trial)
            samples = training_examples(task, trial, classes, out/(name+'-replay.log'), operators)
            return trial, samples
        data = batch_map(collect, train_tasks, 'Public-search collection/replay')
        demos, training = [d[0] for d in data], [d[1] for d in data]
        report['teacher'] = metrics(demos)['train']
        report['admittedEpisodes'] = len(training)
        report['trainingPlanChoices'] = sum(len(e) for e in training)
        report['exploratoryPrefixes'] = sum(e[0][1] == -1 for e in training)
        write(out/'report.json', report)
        validation = [t for t in tasks if t['split'] == 'validation']
        fitted = []
        for i, config in enumerate(CONFIGS):
            model, info = fit(config, 17, f'config{i}-17')
            info['validation'] = evaluate_tasks(validation, 'model', 17, f'config{i}-validation', model)['validation']
            report['screening'].append(info); fitted.append(model)
            write(out/'report.json', report)
        selected = min(range(len(CONFIGS)), key=lambda i: (-report['screening'][i]['validation']['solved'],
                                                          report['screening'][i]['parameters'], i))
        locked = dict(selected=selected, config=CONFIGS[selected],
                      rule='validation repairs, then fewer parameters, then fixed order', testUsed=False)
        write(out/'locked-selection.json', locked); report['selection'] = locked
        tests = [t for t in tasks if t['split'] in ('test', 'arity4')]
        for seed in SEEDS:
            if seed == 17:
                model, info = fitted[selected], report['screening'][selected]
            else:
                model, info = fit(CONFIGS[selected], seed, f'locked-{seed}')
            for mode in ('model', 'reset', 'unfiltered'):
                result = evaluate_tasks(tests, mode, seed, f'{mode}-{seed}', model)
                report['evaluations'].append(dict(mode=mode, seed=seed, fit=info['name'], results=result))
                write(out/'report.json', report)
            for mode in ('filtered_random', 'random'):
                report['baselines'].append(dict(mode=mode, seed=seed,
                    results=evaluate_tasks(tests, mode, seed, f'{mode}-{seed}')))
                write(out/'report.json', report)
        report['baselines'].append(dict(mode='search', seed=17, results=evaluate_tasks(tests, 'search', 17, 'search-17')))
        if any(sha(ROOT/n) != h for n, h in frozen.items()):
            raise ValueError('FROZEN_INPUT_CHANGED')
        if any(sha(t['path']) != t['sourceHash'] for t in tasks):
            raise ValueError('TASK_CHANGED')
        report.update(status='STUDY_COMPLETE', seconds=time.monotonic()-start, newLeanDeclarations=15,
                      additionalRuntimeTests=31, tasks=dict(Counter(t['split'] for t in tasks)),
                      corpusRepairEvaluation='NOT_RUN; coverage audit only')
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
