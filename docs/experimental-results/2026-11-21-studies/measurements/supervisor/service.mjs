import {assert,fs,cp,ctl,owner,read,update,out,root as original} from '../common.mjs';
import {verify,validatePlan} from '../../publication-studies-20261115-v3/stage-runner.mjs';
import {childEnvironment} from '../../publication-capability-repair-20261115-v4/runtime.mjs';
import {guardEnvironment,managerEnvironment} from '/media/augustus/8618-0ED0/ACGN/supervision/dependency-repair-20261110-e4CjEz/focused-long-run-launcher-v3/guard-environment.mjs';
import {write,load,meta,emit,seal,witness,checkOrder,checkReceipt} from './receipts.mjs';
import {randomUUID} from 'node:crypto';
export const guard='/media/augustus/8618-0ED0/ACGN/supervision/dependency-repair-20261110-e4CjEz/runner-v3-corpus-window';
const script=import.meta.filename;
function boundary(p,a){
 assert.equal(fs.statSync(out).dev,fs.statSync('/home/augustus/ACGN').dev);assert.equal(fs.statSync(original).dev,fs.statSync(guard).dev);
 const review=load(a.review);assert.equal(review.decision,'ACCEPT');assert.equal(review.reviewerId,'01a1b7ca-e043-7ad0-8162-0de59a5feda6');assert(review.authorizedStages.includes(p.stage));
 for(const ref of [a.plan,meta(script),meta(process.execPath),...p.launcherInputs]){
  assert.deepEqual(meta(ref.file),ref);assert(review.bindings.some(v=>v.file===ref.file&&v.sha256===ref.sha256),'UNBOUND '+ref.file);
 }
 checkOrder(p,a);
}
async function entry(ref){
 const a=load(ref),p=load(a.plan),cfg=load(p.runtimeConfig);
 const e=Object.fromEntries(['PROFILE','TIMEOUT','CAP','HIGH','UNIT'].map(k=>[k,process.env['ACGN_GUARD_'+k]]));
 assert.deepEqual({...e,UNIT:null},{PROFILE:'corpus',TIMEOUT:'7200',CAP:'12',HIGH:'10',UNIT:null});
 assert(/^acgn-focused-[a-f0-9-]+\.service$/.test(e.UNIT));assert.equal(fs.readFileSync(process.env.ACGN_GUARD_EVIDENCE+'/unit','utf8').trim(),e.UNIT);
 boundary(p,a);verify(p,cfg);
 write(p.runDir+'/effective.json',{effective:e,command:p.command,cwd:p.checkout});
 // Neither stdout nor stderr of a benchmark may write the completion channel.
 const r=cp.spawnSync(p.command[0],p.command.slice(1),{cwd:p.checkout,env:childEnvironment(),stdio:['ignore',2,2]});
 let exit=r.status??71,identityError=null,outputHashes=null;
 try{verify(p,cfg);boundary(p,a);if(exit===0)outputHashes=seal(p);}catch(error){identityError=error.stack;exit=70;}
 const child=write(p.runDir+'/child.json',{authority:ref,effective:e,command:p.command,cwd:p.checkout,exit,status:r.status,signal:r.signal,error:r.error?.message??null,identityVerified:identityError===null,identityError,outputHashes});
 if(exit===0)emit(e.UNIT,a.nonce,child,ref);
 process.exitCode=exit;
}
export function stage(plan,review,priors){
 const p=load(plan),cfg=load(p.runtimeConfig),nonce=randomUUID(),a={plan,review,priors,nonce};
 validatePlan(p,cfg);boundary(p,a);assert(!fs.existsSync(p.stopFile));assert(!fs.existsSync(p.output));fs.mkdirSync(p.runDir);
 const authority=write(p.runDir+'/authority.json',a),env={...guardEnvironment(),ACGN_GUARD_PROFILE:'corpus',ACGN_GUARD_TIMEOUT:'7200'};
 const mgr=managerEnvironment(env), dirs=()=>fs.readdirSync(guard).filter(n=>n.startsWith('cgroup-observations-')), before=new Set(dirs());
 update(l=>{assert.equal(l.activeWriter,owner);assert(!l.activeReviewer&&!l.userPaused&&!l.executionRunning);l.executionRunning=true;l.executionOwner=owner;l.v31SupplementalStudies.status=p.stage;});
 const log=fs.openSync(p.runDir+'/command.log','wx');let r;
 try{r=cp.spawnSync('/usr/bin/bash',[guard+'/guard.sh',process.execPath,'--max-old-space-size=512',script,'entry',authority.file,authority.sha256],{env,cwd:p.checkout,stdio:['ignore','pipe',log],maxBuffer:8*1024**2});}finally{fs.closeSync(log);}
 let exit=r.status??71,terminal=null,child=null,stamp=null,validationError=null,descendantsExited=false;const evidence=[];
 const observations=dirs().filter(n=>!before.has(n)).map(n=>guard+'/'+n);
 try{
  assert.equal(observations.length,1);const d=observations[0],t=meta(d+'/terminal.json');terminal=load(t);evidence.push(t);
  assert.equal(terminal.descendantsExited,true);descendantsExited=true;assert.equal(terminal.exitCode,r.status);
  if(exit===0){
   assert.equal(terminal.commandExit,0);stamp=witness(r.stdout,terminal.unit,nonce,authority);
   const cf={file:p.runDir+'/child.json',sha256:stamp.child};child=load(cf);evidence.push(cf,meta(p.runDir+'/effective.json'));
   assert.equal(child.effective.UNIT,terminal.unit);assert.equal(child.exit,0);assert.equal(child.status,0);assert.equal(child.identityVerified,true);
   const samples=fs.readdirSync(d).filter(n=>n.startsWith('sample-'));assert(samples.length);
   for(const name of samples){const f=meta(d+'/'+name),s=load(f);assert.equal(s.status,'PASS');assert.equal(s.expected.unit,terminal.unit);
    for(const [k,v] of Object.entries({'memory.max':12*1024**3,'memory.high':10*1024**3,'memory.swap.max':0,'memory.swap.current':0,'memory.swap.peak':0}))assert.equal(String(s.sample.files[k]).trim(),String(v));evidence.push(f);}
   boundary(p,a);assert.equal(managerEnvironment(env),mgr);
  }
 }catch(e){validationError=e.stack;exit=70;}
 const receipt=write(p.runDir+'/receipt.json',{plan,review,authority,nonce,witness:stamp,exit,guardedExit:r.status,descendantsExited,terminal,child,validationError,evidence,observations,guardStdout:r.stdout?.toString(),log:meta(p.runDir+'/command.log'),publicCertification:'BLOCKED'});
 update(l=>{if(descendantsExited){l.executionRunning=false;l.executionOwner=null;}l.v31SupplementalStudies.lastReceipt=receipt;});
 if(exit!==0){write(p.stopFile,{plan,receipt,exit});throw Error('STOPPED '+p.stage+' '+JSON.stringify(receipt));}
 const pin={plan,receipt,witness:stamp};checkReceipt(pin,review);return pin;
}
if(process.argv[2]==='entry'&&process.argv[1]===script)await entry({file:process.argv[3],sha256:process.argv[4]});
