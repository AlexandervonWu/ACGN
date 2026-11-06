"""Larger GNN screening, validation-only locking, and three-seed held-out testing."""
import argparse
from collections import OrderedDict, defaultdict
from concurrent.futures import ThreadPoolExecutor
import gc
import json
import math
from pathlib import Path
import random
import resource
import time
import torch

from .run_gates import ROOT, sha, write
from .gnn_study import validate_hashes, describe_trials
from .gnn_variants import make_policy
from .policy import choose
from .tables import encode
from .train_gates import rollout
from acgn_repair.corpus_protocol import paired_cluster_interval

CONFIGS = (
    {'name':'gin-128x3','variant':'gin','width':128,'layers':3},
    {'name':'gin-256x4','variant':'gin','width':256,'layers':4},
    {'name':'gin-512x4','variant':'gin','width':512,'layers':4},
    {'name':'sage-256x4','variant':'sage','width':256,'layers':4},
    {'name':'mlp-256x4','variant':'mlp','width':256,'layers':4},
)
UPDATES, BATCH = 3000, 16


def training_index(tasks, coverage):
    by_id = {t['id']:t for t in tasks}
    if len(by_id) != len(tasks): raise ValueError('Duplicate task identifier')
    output = []
    for row in coverage:
        if row['id'] not in by_id or by_id[row['id']]['split'] != 'train' or row['split'] != 'train':
            raise ValueError('Held-out or unknown teacher')
        if row['status']=='REPLAY_VALIDATED_TEACHER':
            if row['decisions'] < 1: raise ValueError('Empty teacher')
            output.append((row['id'], row['decisions']))
    if len({key for key,_ in output}) != len(output): raise ValueError('Duplicate teacher')
    if not output: raise ValueError('No train teachers')
    return output


def select_config(arms):
    if not arms: raise ValueError('Empty screening results')
    return min(arms,key=lambda a:(-a['validation']['repairs'],a['parameters'],a['order']))


class TeacherBank:
    """Estimated one-GiB host cache; graphs stay on CPU until a micro-example."""
    def __init__(self, root, index, operators, budget=1024**3):
        self.root, self.allowed, self.operators = root, dict(index), operators
        self.budget, self.used, self.cache = budget, 0, OrderedDict()
        self.encodedExamples = 0

    def get(self, key, index):
        if key not in self.allowed or not 0 <= index < self.allowed[key]:
            raise ValueError('Unknown training example')
        if key in self.cache:
            data,counts,graphs,size=self.cache.pop(key); self.used-=size
        else:
            path=self.root/'teachers'/(key+'.json')
            record=json.loads(path.read_text())
            if record['finalObservation']['status']!=5 or not record['finalObservation']['closed']:
                raise ValueError('Teacher not accepted')
            data=record['decisions']
            if len(data)!=self.allowed[key]: raise ValueError('Teacher length mismatch')
            counts=[]; queries=0; graphs={}
            size=len(json.dumps(record,separators=(',',':')))*10
            for item in data:
                counts.append(queries); queries+=item['action']['control'] in (11,12)
            if queries>2: raise ValueError('Teacher exceeds matched query budget')
        if index not in graphs:
            graph=encode(data[index]['observation'],self.operators)
            size+=sum(x.numel()*x.element_size() for x in (graph.kinds,graph.values,graph.edges,graph.roles))
            size+=len(graph.addresses)*160
            graphs[index]=graph; self.encodedExamples+=1
        while self.cache and self.used+size>self.budget:
            _,(_,_,_,old)=self.cache.popitem(last=False); self.used-=old
        if size<=self.budget:
            self.cache[key]=(data,counts,graphs,size); self.used+=size
        return graphs[index],data[index]['observation'],data[index]['action'],counts[index]


def sample_schedule(index, seed, updates=UPDATES, batch_size=BATCH):
    rng=random.Random(seed); result=[]
    for _ in range(updates):
        batch=[]
        for _ in range(batch_size):
            key,count=rng.choice(index); batch.append((key,rng.randrange(count)))
        result.append(batch)
    return result


def probe(model,bank,examples,device):
    model.eval(); total=correct=heads=joint=0
    with torch.no_grad():
        for key,i in examples:
            graph,obs,label,queries=bank.get(key,i)
            _,loss,matches=choose(model,graph.to(device),obs,queries,label)
            total+=float(loss); correct+=sum(matches); heads+=len(matches); joint+=all(matches)
    return {'decisions':len(examples),'loss':total/len(examples),'headAccuracy':correct/heads,
            'jointAccuracy':joint/len(examples)}


def evaluate(tasks,dataset,classes,directory,catalog,model,device,mode,seed,workers):
    directory.mkdir()
    if model is not None: model.eval()
    def execute(pair):
        index,task=pair
        if task['status']!='SOURCE_READY':
            return {'id':task['id'],'mode':mode,'solved':False,'wellFormed':False,'decisions':[],
                    'queries':0,'error':'SOURCE_UNAVAILABLE: '+task.get('error',task['status'])}
        return rollout(task,classes,directory,catalog['operators'],model,device,mode,seed+index,task_root=dataset)
    rows=[]
    with ThreadPoolExecutor(max_workers=workers) as pool:
        for start in range(0,len(tasks),workers):
            rows.extend(pool.map(execute,list(enumerate(tasks))[start:start+workers]))
            write(directory/'rollouts.json',rows)
            if len(rows)%16==0 or len(rows)==len(tasks):
                print(f'{directory.name}: {len(rows)}/{len(tasks)}, repaired {sum(r["solved"] for r in rows)}',flush=True)
    return describe_trials(rows),rows


def train(config,seed,index,bank,directory,device,probe_examples):
    directory.mkdir(); torch.manual_seed(seed)
    schedule=sample_schedule(index,seed)
    write(directory/'schedule.json',schedule)
    model=make_policy(config['variant'],config['width'],config['layers']).to(device)
    optimizer=torch.optim.AdamW(model.parameters(),lr=0.0003,weight_decay=0.001)
    if device=='cuda': torch.cuda.reset_peak_memory_stats()
    started=time.monotonic()
    record={'config':config,'seed':seed,'parameters':sum(p.numel() for p in model.parameters()),
            'scheduleHash':sha(directory/'schedule.json'),'updates':0,'finiteNonzeroGradientUpdates':0,
            'clippedUpdates':0,'before':probe(model,bank,probe_examples,device)}
    initial=model.scalar.weight.detach().clone(); logs=[]; running=0.
    for update,batch in enumerate(schedule,1):
        if update<=100: lr=0.0003*update/100
        else: lr=0.00003+0.5*(0.0003-0.00003)*(1+math.cos(math.pi*(update-100)/(UPDATES-100)))
        for group in optimizer.param_groups: group['lr']=lr
        model.train(); optimizer.zero_grad(set_to_none=True)
        loss_value=0.
        for key,i in batch:
            graph,obs,label,queries=bank.get(key,i)
            _,loss,_=choose(model,graph.to(device),obs,queries,label)
            if not torch.isfinite(loss): raise ValueError('NONFINITE_TRAINING_LOSS')
            (loss/BATCH).backward(); loss_value+=float(loss.detach())/BATCH
        norm=float(torch.nn.utils.clip_grad_norm_(model.parameters(),1.,error_if_nonfinite=True))
        record['finiteNonzeroGradientUpdates']+=norm>0; record['clippedUpdates']+=norm>1
        optimizer.step(); record['updates']=update; running+=loss_value
        if update%100==0:
            item={'update':update,'meanLoss100':running/100,'preClipNorm':norm,'lr':lr,
                  'seconds':time.monotonic()-started,'cacheEstimatedBytes':bank.used,
                  'encodedExamples':bank.encodedExamples}
            logs.append(item); running=0.; write(directory/'training.json',logs)
            print(f'{config["name"]} seed {seed}: {update}/{UPDATES}, loss={item["meanLoss100"]:.5f}, '
                  f'gradient={norm:.5f}, elapsed={item["seconds"]:.1f}s',flush=True)
        if update in (1000,3000):
            record.setdefault('probes',[]).append({'update':update,**probe(model,bank,probe_examples,device)})
            write(directory/'training-report.json',record)
    record.update(seconds=time.monotonic()-started,encoderUpdateNorm=float((model.scalar.weight.detach()-initial).norm()),
                  peakCudaAllocatedBytes=torch.cuda.max_memory_allocated() if device=='cuda' else 0,
                  peakCudaReservedBytes=torch.cuda.max_memory_reserved() if device=='cuda' else 0,
                  hostMaxRssKiB=resource.getrusage(resource.RUSAGE_SELF).ru_maxrss)
    torch.save({'config':config,'seed':seed,'state_dict':model.state_dict()},directory/'policy.pt')
    write(directory/'training-report.json',record)
    return model,record


def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('dataset',type=Path); p.add_argument('output',type=Path)
    p.add_argument('--device',default='cuda'); p.add_argument('--workers',type=int,default=4)
    args=p.parse_args(); dataset,out=args.dataset.resolve(),args.output.resolve()
    if out.exists() or out==ROOT or ROOT in out.parents or not 1<=args.workers<=4:
        p.error('Fresh external output, workers 1..4 required')
    frozen=json.loads((dataset/'input-hashes.json').read_text()); evidence=json.loads((dataset/'output-hashes.json').read_text())
    validate_hashes(ROOT,frozen); validate_hashes(dataset,evidence)
    data_report=json.loads((dataset/'report.json').read_text()); pre=Path(data_report['preflight'])
    validate_hashes(pre,json.loads((pre/'output-hashes.json').read_text()))
    if sha(pre/'output-hashes.json')!=data_report['preflightHash']: raise ValueError('Preflight identity mismatch')
    tasks=json.loads((dataset/'tasks.json').read_text())['tasks']; catalog=json.loads((dataset/'catalog.json').read_text())
    coverage=json.loads((dataset/'teachers/coverage.json').read_text())
    index=training_index(tasks,coverage); bank=TeacherBank(dataset,index,catalog['operators'])
    validation=[t for t in tasks if t['split']=='validation']; testing=[t for t in tasks if t['split']=='evaluation']
    if not validation or not testing: raise ValueError('Held-out splits missing')
    groups=defaultdict(set)
    for t in tasks: groups[t['group']].add(t['split'])
    if any(len(s)!=1 for s in groups.values()): raise ValueError('Question split overlap')
    out.mkdir(); write(out/'input-hashes.json',frozen)
    started=time.monotonic(); torch.set_num_threads(2); torch.backends.cuda.matmul.allow_tf32=False
    probe_examples=sample_schedule(index,991,updates=1,batch_size=128)[0]
    write(out/'train-probe.json',probe_examples)
    report={'schema':'feedback-scaled-learning-v1','status':'SCREENING','dataset':str(dataset),
            'datasetHash':sha(dataset/'output-hashes.json'),'contract':'feedback-intent-path-v1',
            'data':data_report,'torch':torch.__version__,'gpu':torch.cuda.get_device_name() if args.device=='cuda' else None,
            'updates':UPDATES,'batchDecisions':BATCH,'workers':args.workers,'teacherTasks':len(index),
            'teacherDecisions':sum(n for _,n in index),'screening':[],'testing':[],'controls':[]}
    write(out/'report.json',report)
    for order,config in enumerate(CONFIGS):
        directory=out/(config['name']+'-17')
        model,record=train(config,17,index,bank,directory,args.device,probe_examples)
        stats,_=evaluate(validation,dataset,pre/'classes',directory/'validation',catalog,model,args.device,'learned',17,args.workers)
        record.update(validation=stats,order=order,directory=directory.name)
        report['screening'].append(record); write(out/'report.json',report)
        del model; gc.collect()
        if args.device=='cuda': torch.cuda.empty_cache()
    best=select_config(report['screening']); config=best['config']
    lock={'config':config,'selection':'validation repairs, parameter count, fixed order',
          'validation':best['validation'],'parameters':best['parameters'],'datasetHash':report['datasetHash'],
          'seed17CheckpointHash':sha(out/best['directory']/'policy.pt')}
    write(out/'locked-selection.json',lock); lock_hash=sha(out/'locked-selection.json')
    report.update(status='LOCKED_TESTING',selection=lock,selectionHash=lock_hash); write(out/'report.json',report)
    paired=defaultdict(list)
    for seed in (17,29,43):
        directory=out/(config['name']+'-'+str(seed))
        if seed==17:
            model=make_policy(config['variant'],config['width'],config['layers']).to(args.device)
            checkpoint=torch.load(directory/'policy.pt',map_location=args.device,weights_only=True)
            model.load_state_dict(checkpoint['state_dict']); del checkpoint
        else:
            model,record=train(config,seed,index,bank,directory,args.device,probe_examples)
            report.setdefault('replicateTraining',[]).append(record)
        stats,trials=evaluate(testing,dataset,pre/'classes',directory/'evaluation',catalog,model,args.device,'learned',seed,args.workers)
        report['testing'].append({'seed':seed,**stats}); write(out/'report.json',report)
        del model; gc.collect()
        if args.device=='cuda': torch.cuda.empty_cache()
        for mode in ('noop','uniform'):
            stats,controls=evaluate(testing,dataset,pre/'classes',out/(mode+'-'+str(seed)),catalog,None,'cpu',mode,seed,args.workers)
            report['controls'].append({'seed':seed,'mode':mode,**stats})
            if mode=='uniform':
                for task,a,b in zip(testing,trials,controls):
                    if a['id']!=b['id'] or a['id']!=task['id']: raise ValueError('Paired evaluation identity mismatch')
                    paired[task['group']].append(int(a['solved'])-int(b['solved']))
        write(out/'report.json',report)
    if sha(out/'locked-selection.json')!=lock_hash: raise ValueError('Selection changed after test exposure')
    validate_hashes(ROOT,frozen); validate_hashes(dataset,evidence)
    report.update(status='COMPLETE',seconds=time.monotonic()-started,
                  pairedQuestionBootstrap=paired_cluster_interval(paired),
                  laterStages={'LLM':'NOT_RUN','localTransformer':'NOT_RUN'})
    write(out/'report.json',report)
    write(out/'output-hashes.json',{str(f.relative_to(out)):sha(f) for f in sorted(out.rglob('*')) if f.is_file()})
    print(json.dumps(report,indent=2),flush=True)


if __name__=='__main__': main()
