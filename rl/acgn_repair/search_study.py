"""Small verifier-guided search/learning study; no AlphaProof replication claim."""
import argparse
import hashlib
import json
import math
import os
from pathlib import Path
import random
import re
import signal
import subprocess
import time

import torch
from torch import nn

from .experiment import sha, write_json
from .worker import JavaWorker

ROOT = Path(__file__).resolve().parents[2]
PROOF = ROOT / 'docs/repair-search/formal/SearchLearning.lean'


def tasks():
    folder = ROOT / 'docs/rl-corpus-data'
    rows = json.loads((folder / 'tasks.json').read_text())['tasks']
    selected = ([r for r in rows if r['split'] == 'train'][:16]
                + [r for r in rows if r['split'] == 'evaluation'][:8])
    groups = {}
    for row in selected:
        row['path'] = str(folder / row['path'])
        if sha(row['path']) != row['sourceHash']:
            raise ValueError('Source changed')
        if row['group'] in groups and groups[row['group']] != row['split']:
            raise ValueError('Question split overlap')
        groups[row['group']] = row['split']
    return selected


def worker(classes, log):
    command = ['java', '-ea', '-Xmx2g', '-Djava.awt.headless=true', '-Dfile.encoding=UTF-8',
               '-cp', str(classes) + os.pathsep + str(ROOT / 'lib/*'),
               'is.fivefivefive.ACGN.repair.RepairStudyWorker']
    return JavaWorker(ROOT, classes, log, timeout=30, command=command)


def load(w, task, budget=32):
    reply = w.request('load', **{k: task[k] for k in ('path', 'target', 'oracle', 'command', 'split')},
                      horizon=3, budget=budget)
    if reply['status'] != 'COUNTEREXAMPLE':
        raise ValueError('Study task must initially be incorrect')
    return reply


def admit(reply, root, split, kind='repair'):
    validation = reply.get('validation', {})
    request = dict(kind=kind, split=split, sourceHash=reply.get('sourceHash', ''),
                   profileHash=reply.get('profileHash', ''),
                   identityBound=(reply.get('sourceHash') == root['sourceHash']
                                  and reply.get('profileHash') == root['profileHash']),
                   contextSat=reply.get('bank', {}).get('context') == 'SAT',
                   extraUnsat=validation.get('extra') == 'UNSAT',
                   missingUnsat=validation.get('missing') == 'UNSAT',
                   used=reply.get('used', 0), budget=reply.get('budget', 0))
    result = subprocess.run(['lean', '--run', str(PROOF)], input=json.dumps(request)+'\n',
                            capture_output=True, text=True, timeout=30, check=True)
    receipt = json.loads(result.stdout)
    if receipt != {'accepted': True, 'request': request}:
        raise ValueError('Lean admission rejected: ' + result.stdout)
    return {'proofHash': sha(PROOF), **receipt}


def features(state, action=None):
    values = torch.zeros(512)
    parts = [('body', state['body'])]
    if action:
        parts += [('op', action['operation']), ('from', action['expected']),
                  ('to', action['replacement']), ('path', action['path'])]
    for tag, text in parts:
        tokens = re.findall(r'[A-Za-z_][A-Za-z_0-9]*|[^\s]', text)
        for token in tokens:
            digest = hashlib.sha256((tag + ':' + token).encode()).digest()
            values[int.from_bytes(digest[:4], 'big') % 508] += 1 / max(1, len(tokens))
    score = state['score']
    values[508:] = torch.tensor([score['potential']/1000,
        score['positiveErrors']/max(1, score['positiveCount']),
        score['negativeErrors']/max(1, score['negativeCount']), 1.0])
    return values


class PolicyValue(nn.Module):
    def __init__(self):
        super().__init__()
        self.shared = nn.Sequential(nn.Linear(512, 64), nn.Tanh())
        self.policy = nn.Linear(64, 1)
        self.value = nn.Linear(64, 1)

    def forward(self, x):
        hidden = self.shared(x)
        return self.policy(hidden).squeeze(-1), self.value(hidden).squeeze(-1)


def search(w, root, model, seed, random_walk=False, split='evaluation'):
    rng = random.Random(seed)
    nodes, samples = {}, []
    solved, receipt = None, None
    winning_nodes = set()
    attempts = 0

    def node(state, depth):
        indices = [i for i,a in enumerate(state['actions']) if a['kind'] != 'STOP'] if depth < 3 else []
        x = torch.stack([features(state, state['actions'][i]) for i in indices]) if indices else torch.empty(0,512)
        with torch.no_grad():
            priors = (model(x)[0].softmax(0).tolist() if model is not None and indices
                      else [1/max(1,len(indices))]*len(indices))
            value = float(model(features(state))[1].sigmoid()) if model is not None else 0.5
        result = dict(state=state, depth=depth, indices=indices, x=x, priors=priors,
                      n=[0]*len(indices), total=[0.0]*len(indices), children={}, value=value)
        nodes[state['node']] = result
        return result

    first = node(root, 0)
    last = root
    for simulation in range(32):
        current, path = first, []
        value = 0.0
        while current['indices']:
            n = current['n']
            if random_walk:
                chosen = rng.randrange(len(n))
            else:
                scores = [(current['total'][i]/n[i] if n[i] else 0)
                          + 1.5*current['priors'][i]*math.sqrt(1+sum(n))/(1+n[i]) for i in range(len(n))]
                best = max(scores)
                chosen = rng.choice([i for i,s in enumerate(scores) if s == best])
            path.append((current, chosen))
            if chosen in current['children']:
                child = current['children'][chosen]
                if child is None:
                    break
                current = child
                continue
            state = w.request('step', node=current['state']['node'], action=current['indices'][chosen])
            attempts += 1
            last = state if state['status'] != 'INVALID' else last
            if state['status'] == 'INVALID':
                current['children'][chosen] = None
                break
            child = node(state, current['depth']+1)
            current['children'][chosen] = child
            if state['status'] == 'SOLVED_WITHIN_PROFILE':
                solved, value = state, 1.0
                receipt = admit(state, root, split, 'training' if split=='train' else 'repair')
                winning_nodes = {id(parent) for parent, _ in path} | {id(child)}
            else:
                value = child['value'] if child['indices'] else 0.0
            break
        for parent, index in path:
            parent['n'][index] += 1
            parent['total'][index] += value
        if solved is not None:
            break
    for current in nodes.values():
        if sum(current['n']):
            samples.append((current['x'], torch.tensor(current['n'])/sum(current['n']),
                            features(current['state']), float(id(current) in winning_nodes)))
    return dict(solved=solved is not None, attempts=attempts, simulations=simulation+1,
                solverCalls=last['bank']['solverCalls'], receipt=receipt,
                candidateBody=solved['body'] if solved else None), samples


def policy_study(classes, output):
    output.mkdir()
    selected = tasks()
    write_json(output/'tasks.json', selected)
    torch.manual_seed(701)
    model = PolicyValue()
    optimizer = torch.optim.Adam(model.parameters(), lr=0.001)
    initial = {n:p.detach().clone() for n,p in model.named_parameters()}
    rows = []
    for i,task in enumerate(t for t in selected if t['split']=='train'):
        started = time.monotonic()
        with worker(classes, output/f'train-{i}.log') as w:
            root = load(w, task)
            result, samples = search(w, root, model, 701+i, split='train')
        losses = []
        for _ in range(3):
            for x, probabilities, state, success in samples:
                logits, _ = model(x)
                value = model(state)[1]
                loss = -(probabilities*logits.log_softmax(0)).sum() + nn.functional.binary_cross_entropy_with_logits(value, torch.tensor(success))
                if not torch.isfinite(loss):
                    raise ValueError('Nonfinite loss')
                optimizer.zero_grad()
                loss.backward()
                nn.utils.clip_grad_norm_(model.parameters(), 1.0)
                optimizer.step()
                losses.append(float(loss.detach()))
        rows.append(dict(method='training-search', task=task['id'], **result,
                         updates=len(losses), loss=losses[-1] if losses else None, seconds=time.monotonic()-started))
        write_json(output/'runs.json', rows)
        print('Training search', i+1, '/16', result['solved'], flush=True)
    if not any(not torch.equal(initial[n], p) for n,p in model.named_parameters()):
        raise ValueError('No learned parameter changed')
    torch.save(model.state_dict(), output/'policy.pt')
    frozen = {n:p.detach().clone() for n,p in model.named_parameters()}
    for method in ('uniform-puct', 'learned-puct', 'random-tree-walk'):
        for seed in (711,712,713):
            for i,task in enumerate(t for t in selected if t['split']=='evaluation'):
                started = time.monotonic()
                with worker(classes, output/f'{method}-{seed}-{i}.log') as w:
                    root = load(w, task)
                    result, _ = search(w, root, model if method=='learned-puct' else None,
                                       seed+i, random_walk=method=='random-tree-walk')
                rows.append(dict(method=method, seed=seed, task=task['id'], **result, seconds=time.monotonic()-started))
                write_json(output/'runs.json', rows)
                print(method, seed, i+1, '/8', result['solved'], flush=True)
    if any(not torch.equal(frozen[n],p) for n,p in model.named_parameters()):
        raise ValueError('Evaluation updated model')
    return rows


def tar_study(classes, output):
    output.mkdir()
    jar = Path('/home/augustus/lp_baselines/TAR/beafix_benchmarks/arepair/atr.jar')
    rows = []
    for i,task in enumerate(t for t in tasks() if t['split']=='evaluation'):
        source = Path(task['path']).read_text() + f"\npred __repair {{ {task['target']} }}\ncheck __repair {{ {task['target']} iff {task['oracle']} }} for 3\n"
        path = output/f'{task["id"]}.als'
        path.write_text(source)
        started = time.monotonic()
        command = ['java','-Xmx2g','-cp',str(jar),'edu.mit.csail.sdg.alloy4whole.RepairCLI',
                   '--file',str(path),'--depth','3','--timeout','60','--stats']
        process = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE, start_new_session=True)
        try:
            stdout, stderr = process.communicate(timeout=90)
            status = 'FINISHED'
        except subprocess.TimeoutExpired:
            os.killpg(process.pid, signal.SIGKILL)
            stdout, stderr = process.communicate()
            status = 'EXTERNAL_TIMEOUT'
        (output/f'{i}.stdout').write_bytes(stdout)
        (output/f'{i}.stderr').write_bytes(stderr)
        result = None
        for line in stdout.decode(errors='replace').splitlines():
            try:
                value = json.loads(line)
                if isinstance(value,dict) and 'solved' in value:
                    result = value
            except ValueError:
                pass
        verified = False
        receipt = None
        if result and result.get('solved'):
            body = result['solution'].get(task['target'])
            if body is not None:
                with worker(classes, output/f'{i}.validator.log') as w:
                    root = load(w, task, budget=1)
                    checked = w.request('propose', body=body, force=True)
                    if checked['status']=='SOLVED_WITHIN_PROFILE':
                        receipt, verified = admit(checked,root,'evaluation'), True
        rows.append(dict(task=task['id'],method='TAR',status=status,exitCode=process.returncode,
                         reported=result,solved=verified,receipt=receipt,seconds=time.monotonic()-started))
        write_json(output/'runs.json',rows)
        print('TAR', i+1, '/8', verified, flush=True)
    write_json(output/'provenance.json',dict(jar=str(jar),jarHash=sha(jar),
        gitSha=subprocess.check_output(['git','-C','/home/augustus/lp_baselines/TAR','rev-parse','HEAD'],text=True).strip(),
        sourceToJarCorrespondence='Upstream bundled binary; not rebuilt or claimed source-identical'))
    return rows


if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--classes',type=Path,required=True)
    parser.add_argument('--output',type=Path,required=True)
    parser.add_argument('--method',choices=['policy','tar'],required=True)
    args=parser.parse_args()
    (policy_study if args.method=='policy' else tar_study)(args.classes,args.output)
