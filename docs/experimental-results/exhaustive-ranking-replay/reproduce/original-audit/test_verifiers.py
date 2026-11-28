"""Calibration and fault injection against actual native output, including two distinct witness representations."""
import copy
import csv
import gzip
import hashlib
import itertools
import json
import os
from pathlib import Path
import tempfile
import unittest

from verify_inputs import sha
from verify_results import check_native, check_incident, native_rows, proper_int, Compact
from verify_compact import source_row_index,validate_entry
from native_commitment import canonical,check_programs,SerializedNumber

ROOT=Path(__file__).resolve().parent.parent

def objects_from(p):
    with p.open('rb') as fp:
        for ordinal,raw in enumerate(fp):
            if raw.endswith(b'\n'):
                yield ordinal,json.loads(raw)

def get_case(root,status,mode=None):
    for file in sorted((root/'results').glob('shard-*.jsonl')):
        for i,r in objects_from(file):
            if r.get('status')!=status or mode and r.get('sequenceKind')!=mode:continue
            s=file.stem
            with (root/'cohort/jobs'/f'{s}.tsv').open() as f:line=next(itertools.islice(f,i,None))
            return s,i,line.rstrip('\n').split('\t'),r
    raise unittest.SkipTest('No original '+status+' '+str(mode)+' result yet')
class Checks(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.flat=get_case(ROOT,'MATCHED','FLAT_ACTIONS')
        cls.bad=get_case(ROOT,'MISMATCH')
    def test_static(self):
        _,_,cells,r=self.flat
        self.assertTrue(check_native(r,int(cells[7])))
        for field in ('status','reason','endpointCorrespondenceChecked','sourceCertificatesChecked','fixedChoiceReplaysChecked','nativeSequencesEqual','fastSequenceSha256','certifiedSequenceSha256','fastActionCount','certifiedActionCount','fastDistance','certifiedDistance'):
            v=dict(r);del v[field]
            self.assertFalse(check_native(v,int(cells[7])),field)
        self.assertFalse(check_native(dict(r,fastActionCount=True),int(cells[7])))
        self.assertFalse(check_native(dict(r,firstDifference=0),int(cells[7])))
    def test_temporal(self):
        r=next(r for _,r in objects_from(ROOT/'cohort/qa/unit-temporal.jsonl') if r['sequenceKind']=='TEMPORAL_BLOCK_EFFECTS')
        with (ROOT/'cohort/qa/temporal-cases.tsv').open() as f: cells=next(itertools.islice(f,r['ordinal'],None)).rstrip('\n').split('\t')
        self.assertEqual((r['left'],r['right']),(cells[1],cells[4]))
        self.assertTrue(check_native(r,int(cells[7])))
        for k in ('orderedBlockEffectsEqual','fastBlockCount','certifiedBlockCount'):
            v=dict(r);del v[k];self.assertFalse(check_native(v,int(cells[7])))
        self.assertFalse(check_native(dict(r,sequenceKind='FLAT_ACTIONS'),int(cells[7])))
    def test_true_incident(self):
        s,i,cells,r=self.bad
        self.assertFalse(check_native(r,int(cells[7])))
        check_incident(ROOT,s,i,cells,r)
        with self.assertRaises(ValueError):check_incident(ROOT,s,i,cells,dict(r,incidentSha256='1'*64))
        wrong=cells[:];wrong[6]='0'*64
        with self.assertRaises(ValueError):check_incident(ROOT,s,i,wrong,r)
        with gzip.open(ROOT/'results'/r['incidentPath'],'rt') as f:native=json.load(f,parse_float=SerializedNumber)['nativeComparatorEvidence']
        for key in ('nativeSequencesEqual','fastSequenceSha256','certifiedSequenceSha256','fastActionCount' if r['sequenceKind']=='FLAT_ACTIONS' else 'fastBlockCount'):
            altered=dict(r);altered.pop(key)
            with self.assertRaises(ValueError):check_programs(native,altered)
        altered=dict(native);altered['firstDifference']=len(native.get('fastActions',native.get('fastBlocks',[])))
        with self.assertRaises(ValueError):check_programs(altered,r)
    def test_partial_shard(self):
        receipts=sorted((ROOT/'results').glob('shard-*.receipt.json'))
        self.assertTrue(receipts)
        receipt=json.loads(receipts[0].read_bytes());s=next(s for s in json.loads((ROOT/'cohort/manifest.json').read_bytes())['shards'] if s['id']==receipt['shard'])
        self.assertEqual(sum(1 for _ in native_rows(ROOT,s,receipt)),s['rows'])
        temp=dict(receipt);temp['outputSha256']='0'*64
        with self.assertRaises(ValueError):list(native_rows(ROOT,s,temp))
        with tempfile.TemporaryDirectory() as tmp:
            frag=Path(tmp);(frag/'results').mkdir();(frag/'cohort').symlink_to(ROOT/'cohort');(frag/'runner-identity.json').symlink_to(ROOT/'runner-identity.json')
            orig=(ROOT/'results'/(s['id']+'.jsonl')).read_bytes().splitlines(keepends=True)
            path=frag/'results'/(s['id']+'.jsonl')
            for removed_or_reordered in (orig[1:],orig[1:2]+orig[0:1]+orig[2:]):
                path.write_bytes(b''.join(removed_or_reordered))
                with self.assertRaises(ValueError):list(native_rows(frag,s,receipt))
    def test_compact_seek_and_preservation(self):
        cases=[self.flat,self.bad]
        self.assertNotEqual(cases[0][2][1],cases[1][2][1])
        with tempfile.TemporaryDirectory() as tmp:
            dest=Path(tmp);c=Compact(dest,ROOT/'results')
            for i,(shard,ordinal,cells,result) in enumerate(cases):c.add(cells,result,result['status'],i,shard)
            c.close()
            for i,index in enumerate(source_row_index(dest)):
                shard,ordinal,cells,result=cases[i]
                with gzip.open(dest/index['chunk'],'rb') as stream:
                    stream.seek(int(index['uncompressedOffset']));p,edges=json.loads(stream.readline())
                self.assertEqual(p,cells[1]);self.assertEqual(len(edges),1)
                validate_entry(edges[0],None if i==0 else result)
                if i==1:self.assertEqual(sha(dest/result['incidentPath']),result['incidentSha256'])
    def test_java_quoting(self):
        self.assertEqual(canonical(['</','\u0080','\u2040','\u2028','\n',True,None,45]),r'["<\/","\u0080","\u2040","\u2028","\n",true,null,45]')
if __name__=='__main__':unittest.main(verbosity=2)
