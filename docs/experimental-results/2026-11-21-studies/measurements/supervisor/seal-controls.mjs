import {assert,fs,cp,owner,update,read} from '../common.mjs';
import {write,load,meta,emit,witness,checkReceipt,checkOrder,seal} from './receipts.mjs';
import {guard} from './service.mjs';
import {guardEnvironment} from '/media/augustus/8618-0ED0/ACGN/supervision/dependency-repair-20261110-e4CjEz/focused-long-run-launcher-v3/guard-environment.mjs';
import {randomUUID} from 'node:crypto';
const d=import.meta.dirname+'/seal-fixture',file=import.meta.filename;
if(process.argv[2]==='inside'){
 const auth=meta(d+'/authority.json'),a=load(auth),p=load(a.plan);fs.mkdirSync(p.output);
 const evidence={};for(const name of ['pairs.csv','first-attempts.jsonl','manifest.json','execution.json'])evidence[name]=write(p.output+'/'+name,{fixture:name}).sha256;
 write(p.output+'/audit.json',{status:'PASS',evidence});
 const child=write(d+'/child.json',{authority:auth,effective:{UNIT:process.env.ACGN_GUARD_UNIT},command:p.command,cwd:p.checkout,exit:0,status:0,signal:null,error:null,identityVerified:true,identityError:null,outputHashes:seal(p)});
 emit(process.env.ACGN_GUARD_UNIT,a.nonce,child,auth);
}else{
 fs.mkdirSync(d);const nonce=randomUUID(),plan=write(d+'/plan.json',{job:'arm',stage:'fixture',output:d+'/out',runDir:d,command:['fixture'],checkout:d}),review=write(d+'/fixture-only.json',{fixture:true});
 const authority=write(d+'/authority.json',{plan,review,nonce,priors:[]}),before=new Set(fs.readdirSync(guard));
 update(l=>{assert.equal(l.activeWriter,owner);assert(!l.executionRunning&&!l.activeReviewer&&!l.userPaused);l.executionRunning=true;l.executionOwner=owner;});
 const r=cp.spawnSync('/usr/bin/bash',[guard+'/guard.sh',process.execPath,file,'inside'],{env:{...guardEnvironment(),ACGN_GUARD_PROFILE:'corpus',ACGN_GUARD_TIMEOUT:'7200'},stdio:['ignore','pipe','pipe']});
 const dirs=fs.readdirSync(guard).filter(n=>!before.has(n)&&n.startsWith('cgroup-observations-'));assert.equal(dirs.length,1);const terminal=read(guard+'/'+dirs[0]+'/terminal.json');
 assert(terminal.descendantsExited);update(l=>{l.executionRunning=false;l.executionOwner=null;});assert.equal(r.status,0,r.stderr.toString());
 const stamp=witness(r.stdout,terminal.unit,nonce,authority),child=load({file:d+'/child.json',sha256:stamp.child});
 const receipt=write(d+'/receipt.json',{plan,review,nonce,authority,witness:stamp,exit:0,guardedExit:0,descendantsExited:true,validationError:null,terminal,child});
 const pin={receipt,plan,witness:stamp};checkReceipt(pin,review);const results=['positive guarded completion'];
 for(const [name,f] of [['replaced child',d+'/child.json'],['replaced receipt',receipt.file],['changed pair output',d+'/out/pairs.csv']]){
  const orig=fs.readFileSync(f);fs.appendFileSync(f,' ');assert.throws(()=>checkReceipt(pin,review));fs.writeFileSync(f,orig);results.push(name);
 }
 assert.throws(()=>checkReceipt(pin,{...review,sha256:'0'.repeat(64)}));results.push('wrong approval');
 assert.throws(()=>checkOrder({predecessors:[plan]},{review,priors:[]}));results.push('missing predecessor');
 assert.throws(()=>witness(r.stdout,terminal.unit,randomUUID(),authority));results.push('wrong service challenge');
 assert.throws(()=>witness(Buffer.concat([r.stdout,r.stdout]),terminal.unit,nonce,authority));results.push('duplicate completion');
 checkReceipt(pin,review);write(d+'/result.json',{status:'PASS',results,terminal:meta(guard+'/'+dirs[0]+'/terminal.json'),pin});console.log(results);
}
