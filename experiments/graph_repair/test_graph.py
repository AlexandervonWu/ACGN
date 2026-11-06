import unittest
import json
import os
from pathlib import Path
import subprocess
import tempfile
import torch

from . import codec as c
from .model import Config, GraphRepairTransformer, batch_tensors, loss_sum
from .train import generate


def node(label, *children): return {'label':label,'children':list(children)}


def fixture():
    leaf = node(['GLOBALBINDING','$sig0',False,0])
    return {'context':node(['SCHEMA']), 'source':node(['ROOT'],leaf),
            'target':node(['ROOT'],node(['AND'],leaf,node(['NOT'],leaf)))}


class CodecTests(unittest.TestCase):
    def test_complete_path(self):
        p=c.encode_pair(fixture())
        self.assertEqual(c.identity(c.replay(p['value'],p['strings'],p['nodes'])),c.identity(p['target']))
        self.assertLess(max(p['key']+p['value']),128)

    def test_target_not_in_key(self):
        a=fixture(); b=fixture(); b['target']=node(['unknown-target-only'])
        self.assertEqual(c.encode_pair(a)['key'],c.encode_pair(b)['key'])

    def test_unused_source_names_available(self):
        raw=fixture(); raw['symbolMap']={'this/Unused':'$sig1','unusedField':'$rel2'}
        p=c.encode_pair(raw); source=c.identity(c.decode_prefix(p['key'])[0])
        self.assertIn('unusedField',source); self.assertIn('this/Unused',source)

    def test_source_sharing(self):
        t=c.tree(node(['AND'],node(['A']),node(['A'])))
        nodes,_,_=c.dag(t)
        self.assertEqual(len(nodes),2)
        self.assertEqual(nodes[-1][1],[0,0])

    def test_boolean_is_not_integer(self):
        nodes,_,_=c.dag(c.tree(node(['AND'],node([False]),node([0]))))
        self.assertEqual(len(nodes),3)

    def test_all_target_prefixes_legal(self):
        p=c.encode_pair(fixture()); terms=c.source_terms(p['nodes'])
        for i,t in enumerate(p['value']):
            self.assertIn(t,c.allowed_next(p['value'][:i],p['strings'],terms))

    def test_invalid_copy(self):
        with self.assertRaises(ValueError): c.replay([c.COPY,*c.uint(2),c.EOS],[],[(['A'],[])])

    def test_invalid_graph_reference(self):
        with self.assertRaises(ValueError): c.source_terms([(['A'],[0])])

    def test_no_trailing_program(self):
        p=c.encode_pair(fixture())
        with self.assertRaises(ValueError): c.replay(p['value']+[c.EOS],p['strings'],p['nodes'])

    def test_lossless_labels(self):
        values=['$sig29','$rel99','$128','EXISTS','next',None,True,False,0,16,-17,[],['x',5]]
        for value in values:
            reader=c.Reader(c.label_tokens(value))
            self.assertEqual(c.identity(reader.label()),c.identity(value))

    def test_whole_pair_bound(self):
        with self.assertRaisesRegex(ValueError,'TOKEN_BOUND'): c.encode_pair(fixture(),max_tokens=3)

    def test_temporal_bindings(self):
        a=fixture(); a['target']=node(['ROOT'],node(['TEMPORAL','ONCE']),node(['BINDING','ALL','$0','phase/1']))
        p=c.encode_pair(a)
        self.assertEqual(c.identity(c.replay(p['value'],p['strings'],p['nodes'])),c.identity(c.tree(a['target'])))


class ModelTests(unittest.TestCase):
    def setUp(self):
        torch.manual_seed(42); torch.set_num_threads(1)
        self.model=GraphRepairTransformer(Config(width=32,layers=2,heads=4,kv_heads=2,
            head_dim=8,ff=64,group_size=8,max_tokens=1024))

    def test_parameter_count(self):
        with torch.device('meta'): model=GraphRepairTransformer(Config(max_tokens=4096))
        self.assertEqual(sum(p.numel() for p in model.parameters()),503576064)

    def test_mask_and_shift(self):
        records=[{'key':[1,2,3],'value':[4,5,6]}, {'key':[1],'value':[7]}]
        tokens,targets=batch_tensors(records)
        self.assertEqual(tokens.tolist(),[[1,2,3,4,5],[1,0,0,0,0]])
        self.assertEqual(targets.tolist(),[[-100,-100,4,5,6],[7,-100,-100,-100,-100]])

    def test_cached_logits(self):
        self.model.eval(); x=torch.randint(1,128,(2,11))
        with torch.no_grad():
            _,cache=self.model.cached(x[:,:7])
            for i in range(7,11):
                logits,cache=self.model.cached(x[:,i:i+1],cache)
                torch.testing.assert_close(logits,self.model(x[:,:i+1])[:,-1],atol=2e-6,rtol=2e-5)

    def test_left_padding(self):
        self.model.eval(); x=torch.randint(1,128,(1,9)); padded=torch.cat((torch.zeros((1,4),dtype=torch.long),x),1)
        with torch.no_grad():
            expected,_=self.model.cached(x)
            actual,_=self.model.cached(padded,valid=padded.ne(0))
        torch.testing.assert_close(expected,actual,atol=2e-6,rtol=2e-5)

    def test_token_weighted_accumulation(self):
        records=[{'key':[1,2],'value':[3,4,5]}, {'key':[1],'value':[6,7]}]
        self.model.train(); self.model.zero_grad()
        (loss_sum(self.model,records)/5).backward()
        expected={k:p.grad.clone() for k,p in self.model.named_parameters()}
        self.model.zero_grad()
        for r in records: (loss_sum(self.model,[r])/5).backward()
        for k,p in self.model.named_parameters():
            torch.testing.assert_close(p.grad,expected[k],atol=2e-6,rtol=2e-5)

    def test_all_parameters_train(self):
        p=c.encode_pair(fixture()); loss_sum(self.model,[p]).backward()
        self.assertTrue(all(p.grad is not None and torch.isfinite(p.grad).all() for p in self.model.parameters()))

    def test_complete_program_overfit_and_reload(self):
        import io
        p=c.encode_pair(fixture()); optimizer=torch.optim.Adam(self.model.parameters(),lr=0.01)
        self.model.train()
        for _ in range(120):
            optimizer.zero_grad()
            loss=loss_sum(self.model,[p])/len(p['value'])
            loss.backward(); optimizer.step()
        buffer=io.BytesIO(); torch.save(self.model.state_dict(),buffer); buffer.seek(0)
        self.model.load_state_dict(torch.load(buffer,weights_only=True))
        # Deliberately omit every target field from the inference input.
        result=generate(self.model,[{'key':p['key']}],'cpu',max_new=256)[0]
        self.assertEqual(result['stop'],'EOS')
        self.assertEqual(c.identity(c.replay(result['tokens'],p['strings'],p['nodes'])),c.identity(p['target']))


@unittest.skipUnless(os.environ.get('ACGN_RL_CLASSES'),'Requires compiled Java exporter')
class LiveExportTests(unittest.TestCase):
    def export(self, body, target):
        with tempfile.TemporaryDirectory() as temp:
            source=Path(temp)/'fixture_inv1.als'; output=Path(temp)/'pair.json'
            source.write_text('sig S { r: set S }\npred inv1 { '+body+' }\npred inv1C { '+target+' }\nrun {} for 3\n')
            result=subprocess.run(['java','-Xmx768m','-cp',os.environ['ACGN_RL_CLASSES']+':lib/*',
                'is.fivefivefive.CanDis.CanonicalPairExport',str(source),str(output)],
                capture_output=True,text=True,timeout=60)
            self.assertEqual(result.returncode,0,result.stderr[-3000:])
            return c.encode_pair(json.loads(output.read_text()))

    def test_oracle_changes_only_value(self):
        a=self.export('all x:S | some x.r','no S')
        b=self.export('all x:S | some x.r','one S')
        self.assertEqual(a['key'],b['key']); self.assertNotEqual(a['value'],b['value'])

    def test_alpha_renaming_preserves_key(self):
        a=self.export('all x:S | some x.r','no S')
        b=self.export('all renamed:S | some renamed.r','no S')
        self.assertEqual(a['key'],b['key'])

    def test_temporal_branch_and_multistep_target(self):
        p=self.export('all x:S | once some x.r implies always some x.r',
                      'some x:S | always no x.r')
        self.assertEqual(c.identity(c.replay(p['value'],p['strings'],p['nodes'])),c.identity(p['target']))


if __name__=='__main__': unittest.main()
