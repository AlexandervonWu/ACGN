"""Local Q3 inference plus checked SFT/CEGIS training data; no oracle prompt leakage."""
import argparse
import json
import os
from pathlib import Path
import subprocess
import time
import urllib.request

from .experiment import sha, write_json
from .search_study import ROOT, admit, load, tasks, worker

HOST = 'http://127.0.0.1:11435'
BASE_MODEL = 'aix-qwen3.8:27b-ud-q3_k_xl'
AIX = Path('/home/augustus/AIx')
BASE = AIX / '.local/hf-training/models--unsloth--Qwen3.8-27B-unsloth-bnb-4bit/snapshots/8aa5f05d26b7205477066e1449e0af13f762a299'
PYTHON = AIX / '.venv-finetune/bin/python'


def api(route, payload=None, timeout=120):
    request = urllib.request.Request(HOST+route,
        data=None if payload is None else json.dumps(payload).encode(),
        headers={'Content-Type':'application/json'})
    with urllib.request.build_opener(urllib.request.ProxyHandler({})).open(request,timeout=timeout) as response:
        return json.load(response)


def messages(root, witnesses, previous=None):
    content = dict(schema=root['schema'], facts=root['facts'], faultyBody=root['body'],
                   labelledInstances=witnesses,
                   task='Repair the parameterless Alloy predicate. Return JSON with only a body string. Use relations, not any oracle/reference predicate.')
    if previous is not None:
        content['previousAttempt'] = previous
    return [dict(role='system',content='You repair Alloy predicates. Positive instances must satisfy the repaired body; negative instances must not. Output only {"body":"..."}.'),
            dict(role='user',content=json.dumps(content,sort_keys=True))]


def propose(model, prompt):
    result=api('/api/chat',dict(model=model,messages=prompt,stream=False,think=False,
        format={'type':'object','properties':{'body':{'type':'string'}},'required':['body'],'additionalProperties':False},
        options=dict(seed=801,temperature=0,num_ctx=4096,num_predict=512),keep_alive='5m'))
    text=result['message']['content']
    try:
        parsed=json.loads(text)
        body=parsed['body']
        if not isinstance(body,str) or set(parsed)!={'body'}:
            raise ValueError('Expected one body string')
    except (ValueError,KeyError,TypeError) as error:
        return None, dict(status='FORMAT_ERROR',error=str(error),response=result)
    return body,result


def prepare(classes, output):
    output.mkdir()
    sft,ce,rows=[],[],[]
    tag=next(t for t in api('/api/tags')['models'] if t['name']==BASE_MODEL)
    write_json(output/'base-model.json',tag)
    for i,task in enumerate(t for t in tasks() if t['split']=='train'):
        started=time.monotonic()
        with worker(classes,output/f'{i}.worker.log') as w:
            root=load(w,task,budget=3)
            gold=root['teacher']
            checked=w.request('propose',body=gold,force=True)
            receipt=admit(checked,root,'train','training')
            initial_prompt=messages(root,root['witnesses'])
            target=dict(role='assistant',content=json.dumps({'body':gold}))
            record=dict(id=task['id'],messages=initial_prompt+[target])
            sft.append(record)
            ce.append(record)
            body,response=propose(BASE_MODEL,initial_prompt)
            if body is None:
                status='FORMAT_ERROR'
            else:
                attempted=w.request('propose',body=body,force=True)
                status=attempted['status']
                if status=='COUNTEREXAMPLE':
                    witnesses=w.request('witnesses')['witnesses']
                    correction_prompt=messages(root,witnesses,body)
                    ce.append(dict(id=task['id']+'-ce',messages=correction_prompt+[target]))
            rows.append(dict(task=task['id'],split=task['split'],receipt=receipt,
                baseStatus=status,baseResponse=response,seconds=time.monotonic()-started))
        write_json(output/'records.json',rows)
        print('Qwen data',i+1,'/16',status,flush=True)
    for name,records in [('sft',sft),('ce',ce)]:
        (output/f'{name}.jsonl').write_text(''.join(json.dumps(r)+'\n' for r in records))
    api('/api/generate',dict(model=BASE_MODEL,keep_alive=0))
    write_json(output/'manifest.json',dict(status='COMPLETE',trainTasks=[t['id'] for t in tasks() if t['split']=='train'],
        sftRows=len(sft),ceRows=len(ce),datasetHashes={n:sha(output/f'{n}.jsonl') for n in ['sft','ce']},
        model=tag,scope='16-task pilot; positive targets checked under scope 3'))


def export_adapter(run, tag):
    manifest=json.loads((run/'manifest.json').read_text())
    if manifest['status']!='probe_complete' or manifest['adapter_reload_max_abs_error']!=0:
        raise ValueError('Unfinished pilot adapter')
    if any(t['name']==tag for t in api('/api/tags')['models']):
        raise ValueError('Refusing to overwrite an existing model tag')
    adapter=run/'adapter'
    if {p.name:sha(p) for p in adapter.iterdir() if p.is_file()}!=manifest['adapter_files']:
        raise ValueError('Adapter hash mismatch')
    config=json.loads((BASE/'config.json').read_text())
    config.pop('quantization_config')
    config_folder=run/'export-config'
    config_folder.mkdir()
    write_json(config_folder/'config.json',config)
    converter=AIX/'.local/llama-training-tools/convert_lora_to_gguf.py'
    gguf=run/'adapter.gguf'
    with (run/'conversion.log').open('w') as log:
        subprocess.run([str(PYTHON),str(converter),'--base',str(config_folder),'--outfile',str(gguf),
                        '--outtype','f16',str(adapter)],stdout=log,stderr=subprocess.STDOUT,check=True,cwd=AIX)
    modelfile=run/'Modelfile'
    modelfile.write_text(f'FROM {BASE_MODEL}\nADAPTER {gguf}\n')
    with (run/'import.log').open('w') as log:
        subprocess.run(['/snap/ollama/current/bin/ollama','create',tag,'-f',str(modelfile)],
                       env=dict(os.environ,OLLAMA_HOST=HOST),stdout=log,stderr=subprocess.STDOUT,check=True)
    imported=next(t for t in api('/api/tags')['models'] if t['name']==tag)
    write_json(run/'export.json',dict(tag=tag,model=imported,adapterHash=sha(gguf),converterHash=sha(converter),
        inferenceBase=BASE_MODEL,trainingBase=str(BASE),defaultModelChanged=False))


def evaluate(classes, output, model):
    output.mkdir()
    rows=[]
    tag=next(t for t in api('/api/tags')['models'] if t['name']==model)
    write_json(output/'model.json',tag)
    for i,task in enumerate(t for t in tasks() if t['split']=='evaluation'):
        started=time.monotonic()
        attempts=[]
        solved=False
        with worker(classes,output/f'{i}.worker.log') as w:
            root=load(w,task,budget=4)
            if 'teacher' in root:
                raise ValueError('Evaluation received a teacher')
            previous=None
            for attempt in range(4):
                witnesses=w.request('witnesses')['witnesses']
                prompt=messages(root,witnesses,previous)
                body,response=propose(model,prompt)
                entry=dict(response=response,prompt=prompt)
                if body is None:
                    entry['status']='FORMAT_ERROR'
                else:
                    checked=w.request('propose',body=body,force=True)
                    entry.update(status=checked['status'],validation=checked)
                    previous=body
                    if checked['status']=='SOLVED_WITHIN_PROFILE':
                        entry['receipt']=admit(checked,root,'evaluation')
                        solved=True
                attempts.append(entry)
                if solved:
                    break
        rows.append(dict(task=task['id'],method=model,solved=solved,attempts=attempts,
                         seconds=time.monotonic()-started))
        write_json(output/'runs.json',rows)
        print(model,i+1,'/8',solved,flush=True)
    api('/api/generate',dict(model=model,keep_alive=0))


if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--mode',choices=['prepare','evaluate','export'],required=True)
    parser.add_argument('--classes',type=Path)
    parser.add_argument('--output',type=Path,required=True)
    parser.add_argument('--model',default=BASE_MODEL)
    args=parser.parse_args()
    if args.mode=='prepare': prepare(args.classes,args.output)
    elif args.mode=='evaluate': evaluate(args.classes,args.output,args.model)
    else: export_adapter(args.output,args.model)
