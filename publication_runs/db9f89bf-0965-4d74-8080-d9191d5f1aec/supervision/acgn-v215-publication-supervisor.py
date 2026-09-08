#!/usr/bin/env python3
"""v2.15 serial publication supervisor. Default: print plan, do not execute.

Uses the commands/boundaries in scripts/run_publication_experiments.sh and the
existing publication_manifest.py CLI. RUN_ROOT/run is the sealed publication;
RUN_ROOT/control holds live checkpoints and management logs (avoids self-hashes).
No resume, experiment retries, reduced corpus, GC policy, or gate overrides.
"""
import argparse
import csv
import datetime
import hashlib
import importlib.util
import json
import os
from pathlib import Path
import re
import shlex
import shutil
import signal
import subprocess
import sys
import threading
import time
import traceback

sys.dont_write_bytecode = True
REPO = Path('/home/augustus/ACGN')
TOTAL, ELIGIBLE, SKIP, CORRECT, INCORRECT = 66080, 61598, 4482, 19212, 42386
SEED = 55520260811
ARMS = ('raw-egraph', 'raw-egraph-debruijn', 'java-egglog', 'java-egglog-debruijn',
        'slotted-egraph', 'canonical', 'typed-slotted-port-egraph')
FAMILIES = ('alpha', 'aci', 'binder_permutation', 'safe_prenex', 'logical_normalization',
            'temporal_normalization', 'alpha_ac', 'alpha_binder_permutation',
            'binder_permutation_prenex', 'ac_logical', 'mixed')
PROBES = {'comprehension_order_inv2', 'let_shadow_inv1', 'signature_shadow_inv3',
          'temporal_implication_inv4'}
STAGES = ('canonical-batch', 'alloy4fun-augmenter', 'ablation-and-semantic-check', 'capability')
BOUNDARY = ('Finite experiments, not proof. Capability temporal SAT4J checks remain '
            'inconclusive, including solver-reported counterexamples. No semantic '
            'or certificate boundary is relaxed.')
FATAL = re.compile(r'\b(?:OutOfMemoryError|StackOverflowError|VirtualMachineError|InternalError|'
                   r'UnknownError|A fatal error has been detected|Exception in thread |'
                   r'Could not create the Java Virtual Machine|SIGSEGV|SIGBUS|SIGABRT)')


class Blocked(RuntimeError):
    pass


def need(ok, message):
    if not ok:
        raise Blocked(message)


def eq(actual, expected, label):
    need(type(actual) is type(expected) and actual == expected,
         f'{label}: expected {expected!r}, got {actual!r}')


def fields(doc, expected, label):
    for key, value in expected.items():
        eq(doc[key], value, label + '.' + key)


def indexed(rows, key, expected=None):
    result = {}
    for row in rows:
        name = row[key]
        need(name not in result, f'duplicate {key}: {name}')
        result[name] = row
    if expected is not None:
        eq(set(result), set(expected), key + ' coverage')
    return result


def unique_object(pairs):
    result = {}
    for key, value in pairs:
        need(key not in result, f'duplicate JSON key {key}')
        result[key] = value
    return result


def read(path):
    with Path(path).open(encoding='utf-8') as stream:
        return json.load(stream, object_pairs_hook=unique_object)


def rows(path, required):
    with Path(path).open(encoding='utf-8', newline='') as stream:
        reader = csv.DictReader(stream, strict=True)
        header = reader.fieldnames
        need(header and len(header) == len(set(header)) and set(required) <= set(header),
             f'{path}: missing/duplicate CSV columns')
        for row in reader:
            need(None not in row and None not in row.values(), f'{path}: malformed CSV row')
            yield row


def sha(path):
    value = hashlib.sha256()
    with Path(path).open('rb') as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b''):
            value.update(chunk)
    return value.hexdigest()


def digest(value):
    return hashlib.sha256(json.dumps(value, sort_keys=True).encode()).hexdigest()


def save(path, value):
    temporary = path.with_suffix(path.suffix + '.tmp')
    with temporary.open('w', encoding='utf-8') as stream:
        json.dump(value, stream, indent=2, sort_keys=True, allow_nan=False)
        stream.write('\n')
        stream.flush()
        os.fsync(stream.fileno())
    temporary.replace(path)


def now():
    return datetime.datetime.now(datetime.timezone.utc).isoformat()


def label(folder):
    normalized = folder.strip().upper().replace('-', '').replace('_', '')
    return {'OVER': 'OVERCONSTRAINED', 'UNDER': 'UNDERCONSTRAINED'}.get(normalized, normalized)


def certified(doc):
    fields(doc, {'certificateMode': 'required', 'invariantCheckMode': 'strict-every-transition',
                 'canonicalEngine': 'CanonicalAlloyPipeline', 'fastRewriteCanonicalRetained': True,
                 'threadCount': 16, 'maximumHeapBytes': 8589934592, 'rewardsEnabled': True}, 'certified')


def canonical_gate(doc):
    certified(doc)
    eq(doc['fileCount'], TOTAL, 'canonical files')
    fields(doc['summary'], {'total': TOTAL, 'successes': ELIGIBLE, 'skippedIdenticalRawAstPairs': SKIP,
           'failures': 0, 'rewardSuccesses': ELIGIBLE, 'rewardFailures': 0,
           'incorrectCanonicalZero': 0, 'inexactAlphaSearches': 0}, 'canonical')
    records = indexed(doc['results'], 'relativePath')  # AST-identical skips are omitted by the producer.
    eq(len(records), ELIGIBLE, 'canonical rows')
    for path, row in records.items():
        eq(row['success'], True, path)
        need(not row.get('error') and not row.get('rewardError') and not row.get('rewardSkipped'), path)
        need(type(row['candidateReward']) in (int, float) and 0 <= row['candidateReward'] <= 1,
             path + ': missing reward')
        need(type(row['distance']) is int and row['distance'] >= 0 and row['rawAstTreeDistance'] > 0,
             path + ': invalid distance/AST skip')
        need(row['statusFolder'] == 'CORRECT' or row['distance'] > 0, path + ': incorrect certified zero')
    eq(sum(r['statusFolder'] == 'CORRECT' for r in records.values()), CORRECT, 'canonical CORRECT')
    return {p: r['statusFolder'] for p, r in records.items()}


def retry_gate(records, eligible):
    for path, row in indexed(records, 'relativePath').items():
        need(path in eligible, 'retry outside eligible corpus')
        fields(row, {'finalStatus': 'SUCCESS', 'finalError': ''}, path)
        need(bool(row['initialError']), 'missing initial retry evidence')


def augmenter_gate(doc, eligible):
    certified(doc)
    fields(doc, {'sourceFileCount': TOTAL, 'consideredFileCount': ELIGIBLE,
                 'astIdenticalPredicatePairsExcluded': SKIP, 'rewardPoolSize': 100}, 'augmenter')
    fields(doc['summary'], {'groups': 181, 'parsedModels': ELIGIBLE, 'parseFailures': 0,
           'correctModels': CORRECT, 'incorrectModels': INCORRECT, 'oracleReferences': 181,
           'incorrectModelsWithNearestDistances': INCORRECT, 'incorrectNearestCertificateIntegratedZeroes': 0,
           'incorrectNearestFastRewriteZeroes': 0,
           'rewardSuccesses': INCORRECT, 'rewardFailures': 0, 'referencePoolFailures': 0,
           'incorrectRankingFailures': 0, 'incorrectModelsWithoutAstDistinctReference': 0,
           'incorrectModelsWithoutCorrectReference': 0}, 'augmenter')
    for key in ('incorrectRankingFailures', 'incorrectWithoutReference', 'incorrectWithoutAstDistinctReference'):
        eq(doc[key], [], key)
    eq(len(doc['questions']), 181, 'question groups')
    for row in doc['questions']:
        fields(row, {'parseFailureCount': 0, 'rankingFailureCount': 0, 'referenceError': None}, 'question')
    matched = indexed(doc['incorrectNearest'], 'relativePath', [p for p, s in eligible.items() if s != 'CORRECT'])
    for path, row in matched.items():
        need(not row.get('rewardErrorMessage'), path + ': reward error')
        need(type(row['candidateReward']) in (int, float) and 0 <= row['candidateReward'] <= 1,
             path + ': missing reward')
        need(type(row['nearestCanonical']['distance']) is int and row['nearestCanonical']['distance'] > 0,
             path + ': incorrect certified nearest zero')
        need(type(row['nearestLegacyCanonical']['distance']) is int and row['nearestLegacyCanonical']['distance'] > 0,
             path + ': Fast Rewrite nearest zero requires semantic investigation')
    # Numeric rewardError is not an exception. Either engine's incorrect zero blocks this release.


def ablation_counts(doc, capability=False):
    n, skip, correct = (5500, 0, 5500) if capability else (ELIGIBLE, SKIP, CORRECT)
    fields(doc, {'threadCount': 16, 'maxHeap': '8g', 'seed': SEED, 'limit': 0}, 'ablation config')
    runs = indexed(doc['runs'], 'engine', ARMS)
    for arm, row in runs.items():
        fields(row, {'files': n + skip, 'eligiblePairs': n, 'distancePairs': n, 'successes': n,
               'failures': 0, 'skippedIdenticalRawAstPairs': skip, 'correctPairs': correct,
               'incorrectPairs': n - correct, 'incorrectEquivalentPairs': 0, 'threadCount': 16}, arm)
        if capability and arm in ARMS[-3:]:
            eq(row['equivalentPairs'], 5500, arm + ' full capture')
    return runs


def ablation_gate(root, expected_paths, publication, capability=False):
    doc = read(root / 'comparison.json')
    runs = ablation_counts(doc, capability)
    context = read(root / 'run-manifest.json')
    fields(context, {'dirtyTree': False, 'gitSha': publication['git']['commit'], 'heap': '8g',
           'workers': 16, 'limit': 0, 'seed': SEED, 'javaSourceSha256': publication['source']['sha256'],
           'datasetFileCount': 5500 if capability else TOTAL,
           'manifestSchemaVersion': 'candis-ablation-manifest-v3',
           'outputSchemaVersion': 'candis-ablation-output-v5'}, 'ablation identity')
    for key in ('runId', 'datasetSha256', 'datasetRoot', 'gitSha', 'javaSourceSha256'):
        eq(doc['runManifest'][key], context[key], 'embedded identity ' + key)
    claims, zero_sets = {}, {}
    eq({p.parent.name for p in root.glob('*/pairs.csv')}, set(ARMS), 'arm outputs')
    for arm, run in runs.items():
        summary = read(root / arm / 'summary.json')
        fields(summary, {'engine': arm, 'threadCount': 16, 'failureExamples': []}, arm)
        fields(summary['overall'], {k: run[k] for k in ('files', 'successes', 'failures',
                                                       'skippedIdenticalRawAstPairs', 'equivalentPairs')}, arm)
        eq(summary['overall']['count'], len(expected_paths), arm + ' summary count')
        if arm == ARMS[-1]:
            fields(summary, {'certificateMode': 'required', 'invariantCheckMode': 'strict-every-transition'}, arm)
        arm_manifest = read(root / arm / 'manifest.json')
        fields(arm_manifest, {k: context[k] for k in ('runId', 'gitSha', 'dirtyTree', 'javaSourceSha256',
                                                    'datasetSha256', 'workers', 'heap', 'seed', 'limit')}, arm)
        seen, zeros = set(), set()
        for row in rows(root / arm / 'pairs.csv', ('relativePath', 'success', 'equivalent', 'distance',
                                                 'status', 'error', 'leftPredicate', 'rightPredicate')):
            path = row['relativePath']
            need(path in expected_paths and path not in seen, arm + ': foreign/duplicate pair')
            seen.add(path)
            fields(row, {'success': 'true', 'error': '', 'status': expected_paths[path]}, path)
            need(re.fullmatch(r'0|[1-9][0-9]*', row['distance']) is not None, path + ': distance schema')
            eq(row['equivalent'], 'true' if int(row['distance']) == 0 else 'false', path + ': equivalence')
            if row['equivalent'] == 'true':
                eq(row['status'], 'CORRECT', path + ': incorrect zero')
                zeros.add(path)
                claims.setdefault(path, set()).add(arm)
        eq(seen, set(expected_paths), arm + ': full coverage')
        eq(len(zeros), run['equivalentPairs'], arm + ': zero count')
        zero_sets[arm] = zeros
    return claims, zero_sets, context['runId']


def semantic_gate(doc, claims, zero_sets):
    fields(doc, {'canonicalOnly': False, 'boundedByModelCommands': True,
                 'threadCount': 16, 'checkedUniquePairs': len(claims)}, 'semantic')
    for path, row in indexed(doc['checks'], 'relativePath', claims).items():
        fields(row, {'outcome': 'NO_COUNTEREXAMPLE', 'error': ''}, path)
        eq(sorted(row['engines']), sorted(claims[path]), path + ': semantic arms')
    for arm, row in indexed(doc['arms'], 'engine', ARMS).items():
        fields(row, {'claims': len(zero_sets[arm]), 'noCounterexample': len(zero_sets[arm]),
                     'counterexamples': 0, 'errors': 0}, arm)
    for name, row in indexed(doc['targetedProbes'], 'name', PROBES).items():
        fields(row, {'error': '', 'alloyCounterexample': True}, name)
        eq(row['mergedByEngine'], {arm: False for arm in ARMS}, name + ': unsound merge')


def capability_soundness(doc, metadata):
    fields(doc, {'schemaVersion': 'candis-capability-soundness-v1', 'perSubtype': 1, 'boundedScope': 4,
                 'interpretation': 'finite-scope SAT sanity check, not proof'}, 'soundness')
    samples = {}
    for row in metadata:
        samples.setdefault((row['family'], row['subtype']), row['relativePath'])
    eq(len(samples), 29, 'family/subtype samples')
    checks = indexed(doc['checks'], 'relativePath', samples.values())
    temporal_count = 0
    for path, row in checks.items():
        eq(samples[(row['family'], row['subtype'])], path, 'sample selection')
        temporal = row['family'] == 'temporal_normalization'
        eq(row['inconclusive'], temporal, path + ': inconclusive boundary')
        need(type(row['solverReportedCounterexample']) is bool and type(row['error']) is str,
             path + ': soundness schema')
        need(FATAL.search(row['error']) is None, path + ': fatal JVM error')
        if temporal:
            need(bool(row['note']), path + ': missing temporal caveat')
            temporal_count += 1  # Retain even SAT reports/translation limitations, never promote to proof.
        else:
            fields(row, {'solverReportedCounterexample': False, 'error': ''}, path)
    eq(temporal_count, 6, 'temporal inconclusives')


def capability_cells(doc, zero_sets, metadata):
    fields(doc, {'schemaVersion': 'candis-capability-results-v1', 'rngSeed': SEED,
                 'pairCount': 5500, 'arms': list(ARMS)}, 'capabilities')
    families = indexed(doc['families'], 'family', FAMILIES)
    for family, row in families.items():
        paths = {r['relativePath'] for r in metadata if r['family'] == family}
        eq(len(paths), 500, family + ': generated pairs')
        eq(set(row['arms']), set(ARMS), family + ': seven cells')
        for arm, cell in row['arms'].items():
            zero = len(paths & zero_sets[arm])
            fields(cell, {'generated': 500, 'evaluated': 500, 'errors': 0, 'unexpectedFailures': 0,
                          'zero': zero, 'falseNegatives': 500 - zero}, family + '/' + arm)
            if arm in ARMS[-3:]:
                eq(zero, 500, family + '/' + arm + ': full capture')


class Runner:
    def __init__(self, root, commit):
        self.root, self.commit = root, commit
        self.run, self.control = root / 'run', root / 'control'
        self.manifest = self.run / 'run-manifest.json'
        self.results, self.passed, self.process = [], [], None
        self.stage, self.status, self.reason = 'preflight', 'RUNNING', ''
        self.stop, self.checkpoint_error = threading.Event(), None
        self.env = {'PATH': os.environ.get('PATH', os.defpath), 'HOME': os.environ.get('HOME', '/tmp'),
                    'LANG': 'C.UTF-8', 'LC_ALL': 'C.UTF-8', 'PYTHONDONTWRITEBYTECODE': '1',
                    'TMPDIR': str(self.control / 'tmp'),
                    'ACGN_EXPERIMENT_JAR': str(self.run / 'build/acgn-experiments.jar'),
                    'JAVA_TOOL_OPTIONS': '-Xmx8g -XX:+ExitOnOutOfMemoryError -XX:ErrorFile='
                    + str(self.control / 'logs/hs_err_pid%p.log') + ' -Djava.io.tmpdir=' + str(self.control / 'tmp')}

    def checkpoint(self):
        value = {'status': self.status, 'stage': self.stage, 'passedStages': list(self.passed),
                 'time': now(), 'sourceCommit': self.commit, 'reason': self.reason,
                 'pid': self.process.pid if self.process else None, 'boundary': BOUNDARY}
        logs = sorted(self.root.rglob('*.log'), key=lambda p: p.stat().st_mtime)[-2:]
        value['progressLogs'] = []
        for path in logs:
            with path.open('rb') as stream:
                stream.seek(max(0, path.stat().st_size - 2048))
                value['progressLogs'].append({'path': str(path), 'bytes': path.stat().st_size,
                                             'tail': stream.read().decode('utf-8', errors='replace')})
        save(self.control / 'status.json', value)
        with (self.control / 'checkpoints.jsonl').open('a') as stream:
            stream.write(json.dumps(value) + '\n')

    def heartbeat(self):
        while not self.stop.wait(60):
            try:
                self.checkpoint()
            except BaseException as exc:
                self.checkpoint_error = str(exc)
                return

    def fatal_check(self):
        for path in self.root.rglob('*.log'):
            need(not path.name.startswith('hs_err_pid'), f'JVM crash artifact: {path}')
            with path.open(errors='replace') as stream:
                for line in stream:
                    need(not FATAL.search(line), f'fatal/unhandled JVM failure: {path}: {line[:300]}')
        need(self.checkpoint_error is None, f'checkpoint failure: {self.checkpoint_error}')

    def kill_group(self, process):
        for sig, delay in ((signal.SIGTERM, 5), (signal.SIGKILL, 0)):
            try:
                os.killpg(process.pid, sig)
            except ProcessLookupError:
                break
            if delay:
                time.sleep(delay)
        process.wait()

    def command(self, name, argv):
        need(self.process is None, 'serial execution required')
        log = self.control / 'logs' / f'{len(self.results):03d}-{name}.log'
        record = {'name': name, 'argv': argv, 'startedAt': now(), 'log': str(log),
                  'commandSha256': digest({'argv': argv, 'cwd': str(REPO), 'env': self.env})}
        process = None
        try:
            with log.open('xb') as stream:
                process = subprocess.Popen(argv, cwd=REPO, env=self.env, stdin=subprocess.DEVNULL,
                    stdout=stream, stderr=subprocess.STDOUT, start_new_session=True)
                self.process = process
                while True:
                    try:
                        process.wait(timeout=60)
                        break
                    except subprocess.TimeoutExpired:
                        self.fatal_check()
                eq(process.returncode, 0, name + ': exit')
            self.fatal_check()
        except BaseException:
            # A second Ctrl-C must not interrupt process-group cleanup.
            for sig in (signal.SIGINT, signal.SIGTERM, signal.SIGHUP):
                signal.signal(sig, signal.SIG_IGN)
            if process:
                self.kill_group(process)
            raise
        finally:
            self.process = None
            record.update({'returnCode': process.returncode if process else None,
                           'endedAt': now(), 'logSha256': sha(log) if log.exists() else None})
            record['commandResultSha256'] = digest(record)
            self.results.append(record)
            save(self.control / 'command-results.json', self.results)
        return log

    def pm(self, operation, *args):
        return self.command('manifest-' + operation, [sys.executable,
            str(REPO / 'scripts/publication_manifest.py'), operation, '--manifest', str(self.manifest), *map(str, args)])

    def bind(self, report, sources):
        self.pm('bind-report', '--report', report, *[arg for p in sources for arg in ('--source', str(p))])

    def finish(self, name, output, commands, reports, gate):
        self.pm('verify')
        self.pm('record-stage', '--name', name, '--root', output,
                '--command', '; '.join(shlex.join(c) for c in commands))
        for report, sources in reports:
            self.bind(report, sources)
        gate_path = self.run / 'gates' / (name + '.json')
        save(gate_path, {'stage': name, 'status': 'PASS', 'counters': gate,
                        'identitySha256': read(self.manifest)['identitySha256'], 'boundary': BOUNDARY})
        self.bind(gate_path, [p for _, sources in reports for p in sources])
        self.pm('verify')
        self.passed.append(name)


def plan(runner):
    r, data = runner.run, REPO / 'classified-data'
    jar = r / 'build/acgn-experiments.jar'
    java = ['java', '-Xmx8g', '-XX:+ExitOnOutOfMemoryError', '-cp', str(jar) + ':' + str(REPO / 'lib/*')]
    prefix = 'is.fivefivefive.CanDis.'
    return [
        java + [prefix + 'CanonicalBatchTest', str(data), str(r / 'distance_results'), '--threads', '16', '--reward-pool', '100'],
        java + [prefix + 'Alloy4FunAugmenter', str(data), str(r / 'alloy4fun-augmented'), '--threads', '16', '--reward-pool', '100'],
        ['bash', str(REPO / 'scripts/run_egraph_ablation.sh'), '--input', str(data), '--output', str(r / 'egraph_ablation'),
         '--threads', '16', '--max-heap', '8g', '--seed', str(SEED)],
        java + [prefix + 'EGraphSemanticSoundnessCheck', '--input', str(data), '--results', str(r / 'egraph_ablation'), '--threads', '16'],
        ['bash', str(REPO / 'scripts/run_capability_benchmark.sh'), '--dataset', str(data), '--output', str(r / 'capability_benchmark'),
         '--natural', str(r / 'egraph_ablation'), '--target', '500', '--threads', '16', '--max-heap', '8g', '--seed', str(SEED)],
    ]


def execute(r):
    data, commands = REPO / 'classified-data', plan(r)
    spec = importlib.util.spec_from_file_location('publication_manifest', REPO / 'scripts/publication_manifest.py')
    pm = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(pm)  # Read-only helper import; bytecode writes disabled.
    def clean():
        eq(r.command('git-head', ['git', 'rev-parse', 'HEAD']).read_text().strip(), r.commit, 'exact source commit')
        eq(r.command('git-clean', ['git', 'status', '--porcelain', '--untracked-files=all']).read_text().strip(), '', 'clean worktree')
    clean()
    for tool in ('java', 'javac'):
        text = r.command(tool + '-version', [tool, '-version']).read_text()
        need(re.search(r'version "17\.' if tool == 'java' else r'(?m)^javac 17\.', text), 'Java 17 required')
    before = {'source': pm.fingerprint(REPO / 'src', '.java'), 'dataset': pm.fingerprint(data, '.als'),
              'dependencies': pm.dependencies(REPO)}
    eq(before['dataset']['fileCount'], TOTAL, 'full corpus')
    corpus = {p.relative_to(data).as_posix(): label(p.parent.name) for p in data.rglob('*.als')}
    need(set(corpus.values()) <= {'CORRECT', 'BOTH', 'UNDERCONSTRAINED', 'OVERCONSTRAINED'}, 'unknown dataset labels')
    sources = [str(p) for p in sorted((REPO / 'src').rglob('*.java')) if p.is_file()]
    build = [['javac', '--release', '17', '-encoding', 'UTF-8', '-cp', str(REPO / 'lib/*'), '-d', str(r.run / 'build/classes'), *sources],
             ['jar', '--create', '--file', r.env['ACGN_EXPERIMENT_JAR'], '-C', str(r.run / 'build/classes'), '.']]
    planned = {'sourceCommit': r.commit, 'cwd': str(REPO), 'environment': r.env, 'build': build,
               'stageOrder': list(STAGES), 'commands': commands, 'supervisorSha256': sha(__file__),
               'operationalSourceSha256': {n: sha(REPO / 'scripts' / n) for n in
                ('publication_manifest.py', 'run_publication_experiments.sh', 'run_egraph_ablation.sh', 'run_capability_benchmark.sh')},
               'boundary': BOUNDARY, 'expected': {'files': TOTAL, 'eligible': ELIGIBLE, 'skipped': SKIP,
                  'capabilityPairs': 5500, 'cells': 77, 'allPairsCapturedBy': list(ARMS[-3:])}}
    save(r.run / 'planned-commands.json', planned)
    r.stage = 'build'
    for name, command in zip(('javac', 'jar'), build):
        r.command(name, command)
    clean()
    eq(before, {'source': pm.fingerprint(REPO / 'src', '.java'), 'dataset': pm.fingerprint(data, '.als'),
                'dependencies': pm.dependencies(REPO)}, 'build inputs unchanged')
    shutil.rmtree(r.run / 'build/classes')
    r.pm('create', '--repo', REPO, '--dataset', data, '--jar', r.env['ACGN_EXPERIMENT_JAR'],
         '--commands', r.run / 'planned-commands.json', '--workers', 16, '--heap', '8g', '--seed', SEED,
         '--capability-target', 500, '--limit', 0, '--reward-pool', 100)
    publication = read(r.manifest)
    eq(publication['git']['commit'], r.commit, 'manifest commit')
    eq(publication['source'], before['source'], 'manifest built source')
    distance, augmented, ablation, capability = [r.run / p for p in
        ('distance_results', 'alloy4fun-augmented', 'egraph_ablation', 'capability_benchmark')]

    r.stage = STAGES[0]
    r.pm('verify')
    r.command('canonical', commands[0])
    eligible = canonical_gate(read(distance / 'distances.json'))
    need(set(eligible) <= set(corpus), 'canonical foreign paths')
    eq(eligible, {p: corpus[p] for p in eligible}, 'canonical dataset labels')
    skipped = set(corpus) - set(eligible)
    eq(len(skipped), SKIP, 'canonical skips')
    r.finish(STAGES[0], distance, commands[:1], [(distance / 'summary.md', [distance / 'distances.json'])],
             {'total': TOTAL, 'eligible': ELIGIBLE, 'skipped': SKIP, 'failures': 0, 'rewardFailures': 0})

    r.stage = STAGES[1]
    r.pm('verify')
    r.command('augmenter', commands[1])
    skip_rows = indexed(rows(augmented / 'ast_identical_predicate_pairs.csv', ('relativePath', 'statusFolder', 'reason')),
                        'relativePath', skipped)
    for row in skip_rows.values():
        fields(row, {'statusFolder': corpus[row['relativePath']],
                     'reason': 'student-oracle-raw-ast-identical'}, 'retained skip')
    retry_gate(rows(augmented / 'parse_retries.csv', ('relativePath', 'initialError', 'finalStatus', 'finalError')), eligible)
    augmenter_gate(read(augmented / 'index.json'), eligible)  # 1.3 GB baseline: load once, release after gate.
    r.finish(STAGES[1], augmented, commands[1:2], [(augmented / 'summary.md', [augmented / 'index.json',
             augmented / 'parse_retries.csv', augmented / 'ast_identical_predicate_pairs.csv'])],
             {'parsed': ELIGIBLE, 'skipped': SKIP, 'ranked': INCORRECT, 'parseFailures': 0, 'rankingFailures': 0})

    r.stage = STAGES[2]
    r.pm('verify')
    r.command('ablation', commands[2])
    r.pm('verify')
    claims, natural_zero, run_id = ablation_gate(ablation, eligible, publication)
    r.command('semantic', commands[3])  # Must finish and pass before capabilities.
    r.pm('verify')
    semantic = read(ablation / 'semantic_soundness.json')
    fields(semantic, {'claimSourceRunId': run_id, 'claimSourceGitSha': r.commit,
                     'inputRoot': str(data), 'resultsRoot': str(ablation)}, 'semantic binding')
    semantic_gate(semantic, claims, natural_zero)
    eq(list(rows(ablation / 'semantic_counterexamples.csv', ('relativePath', 'engines', 'error'))), [], 'counterexamples')
    r.pm('bind-semantic', '--results', ablation, '--checker-source', REPO / 'src/is/fivefivefive/CanDis/EGraphSemanticSoundnessCheck.java')
    r.finish(STAGES[2], ablation, commands[2:4], [(ablation / 'summary.md', [ablation / 'comparison.json', ablation / 'run-manifest.json']),
             (ablation / 'semantic_soundness.md', [ablation / 'semantic_soundness.json', ablation / 'semantic_counterexamples.csv'])],
             {'arms': 7, 'eligiblePerArm': ELIGIBLE, 'checkedUniquePairs': len(claims), 'errors': 0, 'counterexamples': 0})

    r.stage = STAGES[3]
    r.pm('verify')
    r.command('capabilities', commands[4])
    metadata = read(capability / 'metadata.json')
    fields(metadata, {'schemaVersion': 'candis-capability-benchmark-v1', 'generatedPairs': 5500,
                      'targetPerFamily': 500, 'rngSeed': SEED, 'skips': []}, 'capability generation')
    pairs = indexed(metadata['pairs'], 'relativePath')
    eq(len(pairs), 5500, 'capability metadata count')
    eq({p.relative_to(capability / 'models').as_posix() for p in (capability / 'models').rglob('*.als')}, set(pairs), 'generated models')
    csv_meta = list(rows(capability / 'metadata.csv', ('relativePath', 'family', 'subtype')))
    for path, row in indexed(csv_meta, 'relativePath', pairs).items():
        fields(row, {key: pairs[path][key] for key in ('family', 'subtype')}, path)
    soundness = read(capability / 'soundness.json')
    capability_soundness(soundness, csv_meta)
    _, zero_sets, _ = ablation_gate(capability / 'arms', {p: 'CORRECT' for p in pairs}, publication, True)
    results = read(capability / 'results.json')
    capability_cells(results, zero_sets, csv_meta)
    eq(results['boundedSoundness'], soundness, 'retained capability soundness')
    eq(list(rows(capability / 'unexpected_failures.csv', ('relativePath', 'success', 'error'))), [], 'unexpected capability failures')
    for arm, row in results['naturalCorpus'].items():
        fields(row, {'successful': ELIGIBLE, 'correct': CORRECT, 'incorrect': INCORRECT,
                     'incorrectZero': 0, 'correctZero': len(natural_zero[arm])}, 'natural context')
    r.finish(STAGES[3], capability, commands[4:], [(capability / 'REPORT.md', [capability / 'results.json', capability / 'metadata.json',
             capability / 'metadata.csv', capability / 'arms/run-manifest.json']),
             (capability / 'SOUNDNESS.md', [capability / 'soundness.json', capability / 'soundness.csv'])],
             {'pairs': 5500, 'arms': 7, 'cells': 77, 'pairArmEvaluations': 38500, 'inconclusiveTemporal': 6, 'conclusiveFailures': 0})

    eq(r.passed, list(STAGES), 'four serial gates')
    r.pm('verify')
    summary = r.run / 'summary.md'
    summary.write_text('# v2.15 Fresh Publication Experiments\n\n' + f'Source: `{r.commit}`\n\n'
        + '66080 files; 61598 eligible; 4482 retained AST-identical skips with original labels.\n'
        + '16 workers; 8g; reward pool 100; seed 55520260811; target 500.\n'
        + 'Four serial gates passed; seven arms; 5500 capability pairs; 77 cells.\n\n' + BOUNDARY + '\n')
    r.bind(summary, [r.run / 'gates' / (s + '.json') for s in STAGES])
    receipt = r.run / 'command-results.json'
    save(receipt, r.results)
    r.bind(receipt, [Path(result['log']) for result in r.results])
    manifest = read(r.manifest)
    manifest['plannedCommands'], manifest['commandResults'] = planned, read(receipt)
    save(r.manifest, manifest)
    r.stage = 'finalize'
    r.pm('verify')
    r.pm('finalize')
    r.pm('verify', '--require-complete')
    r.status = 'COMPLETE'


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--source-commit', required=True)
    parser.add_argument('--run-root', required=True, type=Path)
    parser.add_argument('--execute', action='store_true', help='Explicitly build and run; otherwise print plan only')
    args = parser.parse_args()
    need(re.fullmatch(r'[0-9a-f]{40}', args.source_commit), 'exact lowercase 40-hex source commit required')
    root = args.run_root.expanduser().resolve()
    need(not root.is_relative_to(REPO) and not REPO.is_relative_to(root), 'root must be outside repository')
    need(not re.search(r'\s|[\x00-\x1f]', str(root)), 'root must have no whitespace/control characters')
    r = Runner(root, args.source_commit)
    if not args.execute:
        print(json.dumps({'stageOrder': STAGES, 'commands': plan(r), 'environment': r.env}, indent=2))
        return 0
    need(not root.exists(), 'run root must not exist; blocked roots must be preserved')
    root.mkdir(parents=True, exist_ok=False)
    for path in (r.run / 'build/classes', r.run / 'gates', r.control / 'logs', r.control / 'tmp'):
        path.mkdir(parents=True)
    def interrupted(signum, frame):
        raise KeyboardInterrupt(signal.Signals(signum).name)
    for sig in (signal.SIGINT, signal.SIGTERM, signal.SIGHUP):
        signal.signal(sig, interrupted)
    thread = threading.Thread(target=r.heartbeat, daemon=True)
    r.checkpoint()
    thread.start()
    code = 0
    try:
        execute(r)
    except BaseException as exc:
        for sig in (signal.SIGINT, signal.SIGTERM, signal.SIGHUP):
            signal.signal(sig, signal.SIG_IGN)
        if r.process:
            r.kill_group(r.process)
        r.status, r.reason = 'BLOCKED', f'{type(exc).__name__}: {exc}'
        save(r.control / 'BLOCKED.json', {'status': 'BLOCKED', 'stage': r.stage, 'reason': r.reason,
             'traceback': traceback.format_exc(), 'time': now(), 'passedStages': r.passed})
        if r.manifest.exists():
            manifest = read(r.manifest)
            manifest['status'], manifest['blockedReason'] = 'blocked', r.reason
            save(r.manifest, manifest)
        code = 130 if isinstance(exc, KeyboardInterrupt) else 1
    finally:
        r.stop.set()
        thread.join()
        r.checkpoint()
        save(r.control / 'completion.json', {'status': r.status, 'reason': r.reason,
             'manifestSha256': sha(r.manifest) if r.manifest.exists() else None,
             'commandResultsSha256': sha(r.control / 'command-results.json')
             if (r.control / 'command-results.json').exists() else None})
    print(f'{r.status}: {r.control / "status.json"}')
    return code


if __name__ == '__main__':
    try:
        sys.exit(main())
    except Blocked as exc:
        print(f'BLOCKED before launch: {exc}', file=sys.stderr)
        sys.exit(1)
