#!/usr/bin/env python3
"""Tiny structural tests; --snapshot additionally reads existing full outputs only."""
import collections
import copy
import importlib.util
import sys
import unittest
from pathlib import Path

sys.dont_write_bytecode = True
spec = importlib.util.spec_from_file_location('supervisor', '/tmp/acgn-v215-publication-supervisor.py')
s = importlib.util.module_from_spec(spec)
spec.loader.exec_module(s)


class Gates(unittest.TestCase):
    def test_labels(self):
        self.assertEqual(s.label('under'), 'UNDERCONSTRAINED')
        self.assertEqual(s.label('over'), 'OVERCONSTRAINED')
        self.assertEqual(s.label('under_constrained'), 'UNDERCONSTRAINED')

    def test_missing_and_mistyped_counts_block(self):
        with self.assertRaises(KeyError):
            s.fields({}, {'failures': 0}, 'test')
        with self.assertRaises(s.Blocked):
            s.fields({'failures': False}, {'failures': 0}, 'test')

    def test_recovered_retry_allowed_final_failure_blocks(self):
        row = {'relativePath': 'a', 'initialError': 'RuntimeException: retryable',
               'finalStatus': 'SUCCESS', 'finalError': ''}
        s.retry_gate([row], {'a'})
        row['finalStatus'] = 'FAILURE'
        with self.assertRaises(s.Blocked):
            s.retry_gate([row], {'a'})

    def test_semantic_error_and_missing_arm_block(self):
        doc = {'canonicalOnly': False, 'boundedByModelCommands': True, 'threadCount': 16,
               'checkedUniquePairs': 1, 'checks': [{'relativePath': 'a', 'outcome': 'NO_COUNTEREXAMPLE',
               'error': '', 'engines': list(s.ARMS)}], 'arms': [{'engine': a, 'claims': 1,
               'noCounterexample': 1, 'counterexamples': 0, 'errors': 0} for a in s.ARMS],
               'targetedProbes': [{'name': n, 'alloyCounterexample': True, 'error': '',
                                   'mergedByEngine': {a: False for a in s.ARMS}} for n in s.PROBES]}
        claims, zeros = {'a': set(s.ARMS)}, {a: {'a'} for a in s.ARMS}
        s.semantic_gate(doc, claims, zeros)
        bad = copy.deepcopy(doc)
        bad['checks'][0]['outcome'] = 'ERROR'
        with self.assertRaises(s.Blocked):
            s.semantic_gate(bad, claims, zeros)
        bad = copy.deepcopy(doc)
        bad['arms'].pop()
        with self.assertRaises(s.Blocked):
            s.semantic_gate(bad, claims, zeros)

    def test_temporal_inconclusive_retained(self):
        metadata = [{'relativePath': str(i), 'family': 'temporal_normalization' if i < 6 else 'alpha',
                     'subtype': str(i)} for i in range(29)]
        doc = {'schemaVersion': 'candis-capability-soundness-v1', 'perSubtype': 1, 'boundedScope': 4,
               'interpretation': 'finite-scope SAT sanity check, not proof', 'checks':
               [{**row, 'inconclusive': i < 6, 'solverReportedCounterexample': i == 0,
                 'error': '', 'note': 'finite temporal reduction'} for i, row in enumerate(metadata)]}
        s.capability_soundness(doc, metadata)
        doc['checks'][6]['solverReportedCounterexample'] = True
        with self.assertRaises(s.Blocked):
            s.capability_soundness(doc, metadata)
        doc['checks'][6]['solverReportedCounterexample'] = False
        doc['checks'][0]['error'] = 'OutOfMemoryError'
        with self.assertRaises(s.Blocked):
            s.capability_soundness(doc, metadata)


def snapshot():
    repo = s.REPO
    corpus = {p.relative_to(repo / 'classified-data').as_posix(): s.label(p.parent.name)
              for p in (repo / 'classified-data').rglob('*.als')}
    eligible = s.canonical_gate(s.read(repo / 'distance_results/distances.json'))
    s.eq(eligible, {p: corpus[p] for p in eligible}, 'snapshot canonical labels')
    skipped = set(corpus) - set(eligible)
    s.eq(len(skipped), s.SKIP, 'snapshot skips')
    print('PASS canonical:', len(eligible), 'eligible; omitted labels:',
          dict(collections.Counter(corpus[p] for p in skipped)), flush=True)
    aug = repo / 'alloy4fun-augmented'
    skip_rows = s.indexed(s.rows(aug / 'ast_identical_predicate_pairs.csv',
                          ('relativePath', 'statusFolder', 'reason')), 'relativePath', skipped)
    for path, row in skip_rows.items():
        s.fields(row, {'statusFolder': corpus[path], 'reason': 'student-oracle-raw-ast-identical'}, path)
    s.retry_gate(s.rows(aug / 'parse_retries.csv', ('relativePath', 'initialError', 'finalStatus', 'finalError')), eligible)
    doc = s.read(aug / 'index.json')
    s.augmenter_gate(doc, eligible)
    bad = copy.copy(doc)
    bad['summary'] = {**doc['summary'], 'incorrectNearestFastRewriteZeroes': 1}
    try:
        s.augmenter_gate(bad, eligible)
    except s.Blocked:
        pass
    else:
        raise AssertionError('Fast Rewrite zero did not block')
    del bad, doc
    print('PASS augmenter: full index; final retries; Fast Rewrite zero mutation blocks', flush=True)
    context = s.read(repo / 'egraph_ablation/run-manifest.json')
    publication = {'git': {'commit': context['gitSha']}, 'source': {'sha256': context['javaSourceSha256']}}
    claims, natural, _ = s.ablation_gate(repo / 'egraph_ablation', eligible, publication)
    s.semantic_gate(s.read(repo / 'egraph_ablation/semantic_soundness.json'), claims, natural)
    s.eq(list(s.rows(repo / 'egraph_ablation/semantic_counterexamples.csv', ('relativePath', 'engines', 'error'))), [], 'semantic CSV')
    print('PASS seven-arm full ablation and semantic:', len(claims), 'claims', flush=True)
    cap = repo / 'capability_benchmark'
    metadata = s.read(cap / 'metadata.json')
    s.fields(metadata, {'schemaVersion': 'candis-capability-benchmark-v1', 'generatedPairs': 5500,
                       'targetPerFamily': 500, 'rngSeed': s.SEED, 'skips': []}, 'metadata')
    pairs = s.indexed(metadata['pairs'], 'relativePath')
    s.eq(len(pairs), 5500, 'metadata rows')
    s.eq({p.relative_to(cap / 'models').as_posix() for p in (cap / 'models').rglob('*.als')}, set(pairs), 'models')
    csv_meta = list(s.rows(cap / 'metadata.csv', ('relativePath', 'family', 'subtype')))
    s.indexed(csv_meta, 'relativePath', pairs)
    soundness = s.read(cap / 'soundness.json')
    s.capability_soundness(soundness, csv_meta)
    _, zeros, _ = s.ablation_gate(cap / 'arms', {p: 'CORRECT' for p in pairs}, publication, True)
    results = s.read(cap / 'results.json')
    s.capability_cells(results, zeros, csv_meta)
    s.eq(results['boundedSoundness'], soundness, 'retained soundness')
    s.eq(list(s.rows(cap / 'unexpected_failures.csv', ('relativePath', 'success', 'error'))), [], 'unexpected failures')
    for arm, row in results['naturalCorpus'].items():
        s.fields(row, {'successful': s.ELIGIBLE, 'correct': s.CORRECT, 'incorrect': s.INCORRECT,
                      'incorrectZero': 0, 'correctZero': len(natural[arm])}, 'natural context')
    print('PASS capabilities: 5500 pairs, 77 cells; baseline-arm misses allowed; 6 temporal inconclusives retained', flush=True)
    print('READ-ONLY SNAPSHOT VALIDATION COMPLETE. No Java/build/experiment subprocess launched.', flush=True)


if __name__ == '__main__':
    if '--snapshot' in sys.argv:
        snapshot()
    else:
        unittest.main()
