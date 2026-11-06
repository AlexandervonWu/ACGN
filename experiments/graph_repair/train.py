"""Train from scratch and evaluate complete graph patches on question-held-out pairs."""
import argparse
from contextlib import nullcontext
from dataclasses import asdict
from datetime import datetime, timezone
import hashlib
import json
import math
import os
from pathlib import Path
import random
import subprocess
import time

import torch

from experiments.hybrid_edit.corpus import digest, write
from . import codec
from .model import Config, GraphRepairTransformer, loss_sum


def amp(device):
    return torch.autocast('cuda',dtype=torch.bfloat16) if device == 'cuda' else nullcontext()


def load_records(root):
    records=[]; input_splits={}
    for row in json.loads((root/'ledger.json').read_text()):
        if row['status']!='ACCEPTED': continue
        path=root/'records'/f"{row['id']}.json"
        if digest(path)!=row['packetHash']: raise ValueError('DATA_HASH')
        r=json.loads(path.read_text())
        if r.get('codec')!='graph-patch-128-v2': raise ValueError('INPUT_CODEC_VERSION')
        key_hash=hashlib.sha256(codec.identity(r['key']).encode()).hexdigest()
        previous=input_splits.setdefault(key_hash,r['split'])
        if previous!=r['split']: raise ValueError('CROSS_SPLIT_INPUT_LEAKAGE')
        if codec.identity(codec.replay(r['value'],r['strings'],r['nodes'])) != codec.identity(r['target']):
            raise ValueError('TEACHER_REPLAY')
        _,nodes,strings=codec.decode_prefix(r['key'])
        if codec.identity([nodes,strings])!=codec.identity([r['nodes'],r['strings']]):
            raise ValueError('KEY_SIDECAR_MISMATCH')
        records.append(r)
    return records


def event(out, **values):
    line=json.dumps(values,sort_keys=True)
    print(line,flush=True)
    with (out/'events.jsonl').open('a') as f: f.write(line+'\n')


@torch.no_grad()
def validation_loss(model, records, micro, device):
    model.eval(); total=0.0
    ordered=sorted(records,key=lambda r:len(r['key'])+len(r['value']))
    for i in range(0,len(ordered),micro):
        with amp(device): total+=float(loss_sum(model,ordered[i:i+micro],device))
    return total/sum(len(r['value']) for r in records)


@torch.no_grad()
def generate(model, records, device, max_new=1536):
    """The decoder sees key tokens only. Dictionaries are recovered from keys."""
    model.eval()
    width=max(len(r['key']) for r in records)
    tokens=torch.zeros((len(records),width),dtype=torch.long,device=device)
    outputs=[[] for _ in records]; states=['RUNNING']*len(records)
    source=[]
    for i,r in enumerate(records):
        tokens[i,-len(r['key']):]=torch.tensor(r['key'],device=device)
        _,nodes,strings=codec.decode_prefix(r['key'])
        source.append((strings,codec.source_terms(nodes)))
    valid=tokens.ne(codec.PAD)
    # Padding is a compute bound only; it never uses target lengths.
    budget=min(max_new,model.config.max_tokens-width)
    with amp(device):
        logits,cache=model.cached(tokens,valid=valid)
        for step in range(budget):
            choices=torch.full((len(records),1),codec.EOS,dtype=torch.long,device=device)
            for i in range(len(records)):
                if states[i]!='RUNNING': continue
                allowed=codec.allowed_next(outputs[i],*source[i])
                if not allowed:
                    states[i]='INVALID'; continue
                ids=sorted(allowed)
                scores=logits[i,ids].float()
                if not torch.isfinite(scores).all(): raise ValueError('NONFINITE_DECODE')
                token=ids[int(scores.argmax())]; outputs[i].append(token); choices[i,0]=token
                if token==codec.EOS: states[i]='EOS'
            if all(x!='RUNNING' for x in states): break
            if step+1 < budget:
                valid=torch.cat((valid,torch.ones((len(records),1),device=device,dtype=torch.bool)),1)
                logits,cache=model.cached(choices,cache,valid)
    return [{'tokens':p,'stop':s if s!='RUNNING' else 'TOKEN_LIMIT','budget':budget}
            for p,s in zip(outputs,states)]


def evaluate(model, records, out, device, decode_batch, label):
    rows=[]; started=time.monotonic()
    ordered=sorted(records,key=lambda r:len(r['key']))
    for start in range(0,len(ordered),decode_batch):
        batch=ordered[start:start+decode_batch]
        predictions=generate(model,batch,device)
        for r,p in zip(batch,predictions):
            row={'id':r['id'],'source':r['source'],'group':r['group'],**p,
                 'programExact':p['tokens']==r['value'],'validReplay':False,'rootShape':False,
                 'targetGraphExact':False,'unchangedGraph':False}
            try:
                predicted=codec.replay(p['tokens'],r['strings'],r['nodes'])
                row['validReplay']=True
                row['rootShape']=predicted[0]==('ROOT',)
                row['targetGraphExact']=codec.identity(predicted)==codec.identity(r['target'])
                document=codec.decode_prefix(r['key'])[0]
                row['unchangedGraph']=codec.identity(predicted)==codec.identity(document[1][1])
            except (ValueError,codec.Need,RecursionError) as e: row['replayError']=type(e).__name__+': '+str(e)
            rows.append(row)
        write(out/f'{label}_predictions.json',rows)
        event(out,stage=label,decoded=len(rows),total=len(records),
              exact=sum(r['targetGraphExact'] for r in rows),seconds=time.monotonic()-started)
    return {'count':len(rows),**{k:sum(r[k] for r in rows) for k in
              ('programExact','validReplay','rootShape','targetGraphExact','unchangedGraph')},
            'seconds':time.monotonic()-started,
            'stopCounts':{s:sum(r['stop']==s for r in rows) for s in ('EOS','INVALID','TOKEN_LIMIT')},
            'behavioralRepair':'NOT_EVALUATED: graph-to-Alloy realization and solver gate required'}


def main():
    p=argparse.ArgumentParser()
    p.add_argument('--data',type=Path)
    p.add_argument('--output',type=Path,required=True)
    p.add_argument('--epochs',type=int,default=8)
    p.add_argument('--effective-batch',type=int,default=128)
    p.add_argument('--microbatch',type=int,default=8)
    p.add_argument('--decode-batch',type=int,default=8)
    p.add_argument('--lr',type=float,default=0.0001)
    p.add_argument('--seed',type=int,default=20261003)
    p.add_argument('--probe',action='store_true')
    p.add_argument('--tiny',action='store_true')
    args=p.parse_args(); args.output.mkdir()
    torch.set_num_threads(4); random.seed(args.seed); torch.manual_seed(args.seed)
    device='cuda' if torch.cuda.is_available() else 'cpu'
    if device!='cuda' and not args.tiny: raise RuntimeError('Full-size training requires CUDA')
    if device=='cuda':
        torch.cuda.set_per_process_memory_fraction(0.89)
        torch.cuda.reset_peak_memory_stats()
    config=Config(max_tokens=4096) if not args.tiny else Config(width=128,layers=2,heads=4,
        kv_heads=2,head_dim=32,ff=256,group_size=32,max_tokens=4096)
    model=GraphRepairTransformer(config).to(device)
    optimizer=torch.optim.Adafactor(model.parameters(),lr=args.lr,foreach=False)
    manifest={'config':asdict(config),'parameters':sum(x.numel() for x in model.parameters()),
        'startedAt':datetime.now(timezone.utc).isoformat(),
        'arguments':{k:str(v) if isinstance(v,Path) else v for k,v in vars(args).items()},
        'selection':'minimum validation target-token cross entropy; earliest wins ties',
        'masterDtype':'float32','computeDtype':'bfloat16' if device=='cuda' else 'float32',
        'optimizer':'torch.optim.Adafactor','torch':str(torch.__version__),'cuda':torch.version.cuda,
        'device':torch.cuda.get_device_name() if device=='cuda' else device,
        'gitHead':subprocess.check_output(['git','rev-parse','HEAD'],text=True).strip(),
        'sourceHashes':{str(f):digest(f) for f in [*Path('experiments/graph_repair').glob('*.py'),
            Path('experiments/hybrid_edit/model.py'),Path('src/is/fivefivefive/CanDis/CanonicalPairExport.java'),
            Path('docs/canonical-edit-learning/formal/GraphRepair.lean')]}}
    write(args.output/'manifest.json',manifest); started=time.monotonic()
    if args.probe:
        # Synthetic maximum-context hardware check, not an experiment result.
        records=[{'key':[1]*3500,'value':[4]*595+[3]} for _ in range(args.microbatch)]
        for i in range(2):
            optimizer.zero_grad(set_to_none=True)
            with amp(device): loss=loss_sum(model,records,device)/(596*len(records))
            loss.backward(); norm=torch.nn.utils.clip_grad_norm_(model.parameters(),1.0,error_if_nonfinite=True)
            optimizer.step(); event(args.output,step=i,loss=float(loss.detach()),gradientNorm=float(norm))
        torch.cuda.synchronize()
        write(args.output/'probe.json',{'seconds':time.monotonic()-started,
            'allocatedGiB':torch.cuda.max_memory_allocated()/2**30,'reservedGiB':torch.cuda.max_memory_reserved()/2**30})
        return
    records=load_records(args.data)
    splits={s:[r for r in records if r['split']==s] for s in ('train','validation','evaluation')}
    if any(not r for r in splits.values()): raise ValueError('EMPTY_SPLIT')
    groups={s:{r['group'] for r in rr} for s,rr in splits.items()}
    if any(groups[a]&groups[b] for a,b in [('train','validation'),('train','evaluation'),('validation','evaluation')]):
        raise ValueError('QUESTION_LEAKAGE')
    manifest.update(splitCounts={s:len(rr) for s,rr in splits.items()},
        groups={s:sorted(g) for s,g in groups.items()},dataLedgerHash=digest(args.data/'ledger.json'))
    write(args.output/'manifest.json',manifest)
    steps_per_epoch=math.ceil(len(splits['train'])/args.effective_batch)
    steps=args.epochs*steps_per_epoch; step=0; history=[]; best=float('inf')
    for epoch in range(1,args.epochs+1):
        epoch_start=time.monotonic(); ordered=list(splits['train']); random.Random(args.seed+epoch).shuffle(ordered)
        total_loss=0.; total_tokens=0; model.train()
        for start in range(0,len(ordered),args.effective_batch):
            batch=sorted(ordered[start:start+args.effective_batch],key=lambda r:len(r['key'])+len(r['value']))
            count=sum(len(r['value']) for r in batch); optimizer.zero_grad(set_to_none=True); batch_loss=0.
            warmup=max(1,steps//10)
            factor=min(1.,(step+1)/warmup)*(0.1+0.9*0.5*(1+math.cos(math.pi*max(0,step-warmup)/max(1,steps-warmup))))
            for group in optimizer.param_groups: group['lr']=args.lr*factor
            for j in range(0,len(batch),args.microbatch):
                with amp(device): loss=loss_sum(model,batch[j:j+args.microbatch],device)
                (loss/count).backward(); batch_loss+=float(loss.detach())
            norm=torch.nn.utils.clip_grad_norm_(model.parameters(),1.,error_if_nonfinite=True)
            optimizer.step(); step+=1; total_loss+=batch_loss; total_tokens+=count
            event(args.output,stage='train',epoch=epoch,step=step,steps=steps,loss=batch_loss/count,
                  learningRate=args.lr*factor,gradientNorm=float(norm),seconds=time.monotonic()-started)
        val=validation_loss(model,splits['validation'],args.microbatch,device)
        row={'epoch':epoch,'trainingTokenLoss':total_loss/total_tokens,'validationTokenLoss':val,
             'epochSeconds':time.monotonic()-epoch_start}
        if val<best:
            best=val
            temporary=args.output/'best.tmp'
            torch.save({'model':model.state_dict(),'config':asdict(config),'epoch':epoch,'validationLoss':val},temporary)
            os.replace(temporary,args.output/'best.pt')
        history.append(row); write(args.output/'history.json',history); event(args.output,stage='epoch',**row)
    training_seconds=time.monotonic()-started
    del optimizer
    checkpoint=torch.load(args.output/'best.pt',map_location='cpu',weights_only=True)
    model.load_state_dict(checkpoint['model']); chosen_epoch=checkpoint['epoch']; del checkpoint
    if device=='cuda': torch.cuda.empty_cache()
    test_loss=validation_loss(model,splits['evaluation'],args.microbatch,device)
    validation=evaluate(model,splits['validation'],args.output,device,args.decode_batch,'validation')
    test=evaluate(model,splits['evaluation'],args.output,device,args.decode_batch,'test')
    no_op=sum(codec.identity(codec.decode_prefix(r['key'])[0][1][1])==codec.identity(r['target']) for r in splits['evaluation'])
    result={'selectedEpoch':chosen_epoch,'trainingSeconds':training_seconds,'totalSeconds':time.monotonic()-started,
        'testTokenLoss':test_loss,'validation':validation,'test':test,'unchangedBaselineExact':no_op,
        'checkpointHash':digest(args.output/'best.pt'),
        'peakAllocatedGiB':torch.cuda.max_memory_allocated()/2**30 if device=='cuda' else None,
        'peakReservedGiB':torch.cuda.max_memory_reserved()/2**30 if device=='cuda' else None}
    write(args.output/'results.json',result); event(args.output,stage='finished',**result)


if __name__=='__main__': main()
