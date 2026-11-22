import assert from 'node:assert/strict';
import fs from 'node:fs';
import {createHash} from 'node:crypto';
import {closedInventory} from '../../publication-studies-20261115-v3/helper-integrity.mjs';
export const sha=b=>createHash('sha256').update(b).digest('hex');
export const bytes=x=>Buffer.from(JSON.stringify(x,null,2)+'\n');
export const meta=file=>({file,sha256:sha(fs.readFileSync(file))});
export function load(ref){const b=fs.readFileSync(ref.file);assert.equal(sha(b),ref.sha256,'RECORD_CHANGED '+ref.file);return JSON.parse(b);}
export function write(file,obj){const b=bytes(obj);fs.writeFileSync(file,b,{flag:'wx'});return {file,sha256:sha(b)};}
export function emit(unit,nonce,child,authority){
 assert.equal(process.env.ACGN_GUARD_UNIT,unit);
 fs.writeSync(1,'ACGN_COMPLETED '+JSON.stringify({unit,nonce,child:child.sha256,authority:authority.sha256})+'\n');
}
export function witness(pipe,unit,nonce,authority){
 const rows=pipe.toString('utf8').split('\n').filter(x=>x.startsWith('ACGN_COMPLETED '));assert.equal(rows.length,1,'COMPLETION_COUNT');
 const r=JSON.parse(rows[0].slice(15));assert.equal(r.unit,unit);assert.equal(r.nonce,nonce);
 assert.equal(r.authority,authority.sha256);assert(/^[0-9a-f]{64}$/.test(r.child));return r;
}
export function seal(p){
 const inv=closedInventory(p.output);assert(inv.length);
 if(p.job==='arm'){
  const a=load(inv.find(f=>f.file===p.output+'/audit.json'));assert.equal(a.status,'PASS');
  for(const n of ['pairs.csv','first-attempts.jsonl','manifest.json','execution.json'])assert.equal(inv.find(f=>f.file===p.output+'/'+n).sha256,a.evidence[n]);
 }else if(p.syntheticOutput){
  const a=load(inv.find(f=>f.file===p.syntheticOutput+'/audit.json'));assert.equal(a.status,'PASS');assert.equal(a.trials,1080);
 }else for(const name of p.requiredOutputs)assert(inv.some(f=>f.file===p.output+'/'+name),'MISSING_REPORT '+name);
 return inv;
}
export function checkReceipt(pin,approval){
 const p=load(pin.plan),r=load(pin.receipt);assert.deepEqual(r.plan,pin.plan);assert.deepEqual(r.review,approval);
 assert.equal(pin.receipt.file,p.runDir+'/receipt.json');assert.equal(r.exit,0);assert.equal(r.guardedExit,0);assert.equal(r.validationError,null);assert.equal(r.descendantsExited,true);
 assert.equal(r.terminal.commandExit,0);assert.equal(r.terminal.exitCode,0);assert.equal(r.terminal.descendantsExited,true);
 const service=pin.witness;assert.deepEqual(service,r.witness);assert.equal(service.unit,r.terminal.unit);assert.equal(service.nonce,r.nonce);assert.equal(service.authority,r.authority.sha256);
 const auth=load(r.authority);assert.deepEqual(auth.plan,pin.plan);assert.deepEqual(auth.review,approval);assert.equal(auth.nonce,r.nonce);
 const c=load({file:p.runDir+'/child.json',sha256:service.child});assert.deepEqual(c,r.child);assert.deepEqual(c.authority,r.authority);
 assert.equal(c.effective.UNIT,r.terminal.unit);assert.deepEqual(c.command,p.command);assert.equal(c.cwd,p.checkout);
 assert.equal(c.exit,0);assert.equal(c.status,0);assert.equal(c.signal,null);assert.equal(c.error,null);assert.equal(c.identityVerified,true);assert.equal(c.identityError,null);
 assert.deepEqual(seal(p),c.outputHashes,'OUTPUT_CHANGED '+p.stage);
}
export function checkOrder(p,auth){
 assert.deepEqual(auth.priors.map(x=>x.plan),p.predecessors);
 for(const pin of auth.priors)checkReceipt(pin,auth.review);
}
