"""Train-only local trajectories with a bounded CPU cache and frozen roll-in set."""
from collections import OrderedDict
import json
from pathlib import Path

from .tables import encode


def training_index(tasks, coverage, directory):
    by_id = {t['id']: t for t in tasks}
    if len(by_id) != len(tasks):
        raise ValueError('DUPLICATE_TASK')
    result, seen = [], set()
    for row in coverage:
        if row['id'] not in by_id or by_id[row['id']]['split'] != 'train' or row.get('split') != 'train':
            raise ValueError('TRAIN_ONLY')
        if row['id'] in seen:
            raise ValueError('DUPLICATE_TEACHER')
        seen.add(row['id'])
        if row['status'] != 'REPLAY_ADMITTED':
            continue
        if row['decisions'] < 1:
            raise ValueError('EMPTY_TEACHER')
        path = (directory/row['trajectory']).resolve()
        if not path.is_relative_to(directory.resolve()):
            raise ValueError('TRAJECTORY_OUTSIDE_BANK')
        result.append({'id': row['id'], 'path': str(path), 'count': row['decisions']})
    if not result:
        raise ValueError('NO_TRAIN_TEACHERS')
    return result


def rollin_tasks(tasks, cap=32):
    groups = OrderedDict()
    for task in tasks:
        if task['split'] == 'train':
            groups.setdefault(task['group'], []).append(task)
    result, index = [], 0
    while len(result) < cap:
        layer = [group[index] for group in groups.values() if index < len(group)]
        if not layer:
            break
        result.extend(layer[:cap-len(result)])
        index += 1
    return result


class LocalBank:
    """Estimated one-GiB cache, preserving exact public observations and archives."""
    def __init__(self, operators, budget=1024**3):
        self.operators, self.budget = operators, budget
        self.cache, self.used = OrderedDict(), 0
        self.allowed = {}

    def admit(self, entries):
        for entry in entries:
            path = entry['path']
            if path in self.allowed and self.allowed[path] != entry['count']:
                raise ValueError('TRAJECTORY_LENGTH_CHANGED')
            self.allowed[path] = entry['count']

    def get(self, entry, index):
        path = entry['path']
        if path not in self.allowed or not 0 <= index < self.allowed[path]:
            raise ValueError('UNKNOWN_TRAINING_EXAMPLE')
        if path in self.cache:
            data, graphs, size = self.cache.pop(path)
            self.used -= size
        else:
            raw = Path(path).read_text()
            record = json.loads(raw)
            data = record['decisions']
            if len(data) != self.allowed[path]:
                raise ValueError('TRAJECTORY_LENGTH_CHANGED')
            if record['kind'] == 'continuation':
                if not record['final']['closed'] or record['final']['status'] != 5:
                    raise ValueError('TEACHER_NOT_ACCEPTED')
            elif record['kind'] != 'recovery' or len(data) != 1 or data[0]['alternatives'] != [{'control': 10}]:
                raise ValueError('RECOVERY_MISMATCH')
            graphs, size = {}, len(raw)*10
        item = data[index]
        if index not in graphs:
            graph = encode(item['observation'], self.operators, {int(k): v for k, v in item['archive'].items()})
            graphs[index] = graph
            size += sum(t.numel()*t.element_size() for t in (graph.kinds, graph.values, graph.edges, graph.roles))
            size += len(graph.addresses)*160
        while self.cache and self.used+size > self.budget:
            _, (_, _, previous) = self.cache.popitem(last=False)
            self.used -= previous
        if size <= self.budget:
            self.cache[path] = (data, graphs, size)
            self.used += size
        return graphs[index], item['observation'], item['alternatives']
