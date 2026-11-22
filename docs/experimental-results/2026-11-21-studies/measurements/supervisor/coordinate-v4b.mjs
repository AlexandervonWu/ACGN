import {assert,fs,root as old,terra,owner,update,current} from '../common.mjs';
import {write,load,meta,checkReceipt} from './receipts.mjs';
import {stage} from './service.mjs';
const d=import.meta.dirname,req=meta(d+'/request-v4b.json'),q=load(req),answer=meta(process.argv[2]),a=load(answer);
current();assert.equal(a.decision,'ACCEPT');assert.equal(a.reviewerId,terra);assert.equal(a.submissionSha256,req.sha256);
assert.deepEqual(a.authorizedStages,q.stages.map(s=>s.stage));for(const f of q.bound)assert.deepEqual(meta(f.file),f);
const review=write(d+'/approval.json',{...a,request:req,answer,bindings:q.bound}),accepted=[];
update(l=>{assert.equal(l.activeReviewer,terra);assert(!l.activeWriter&&!l.executionRunning&&!l.userPaused);l.activeReviewer=null;l.activeWriter=owner;l.v31SupplementalStudies.review=review;});
try{
 for(const s of q.stages){
  console.log(new Date().toISOString(),'START',s.stage);
  const pin=stage(s.plan,review,[...accepted]);accepted.push(pin);
  write(load(pin.plan).runDir+'/accepted.json',pin); console.log(new Date().toISOString(),'ACCEPTED',s.stage,pin.receipt.sha256);
 }
 for(const pin of accepted)checkReceipt(pin,review);
 const results=write(d+'/complete.json',{status:'MEASURED',accepted,review,tag:q.releaseTag,publicCertification:'BLOCKED'});
 update(l=>{assert(!l.executionRunning);l.activeWriter=null;l.v31SupplementalStudies.status='COMPLETE';l.v31SupplementalStudies.complete=results;});
}catch(e){
 const incident=write(d+'/incident.json',{error:e.stack,accepted,unaccepted:q.stages.slice(accepted.length).map(s=>s.stage),review});
 update(l=>{if(!l.executionRunning)l.activeWriter=null;l.v31SupplementalStudies.status='STOPPED';l.v31SupplementalStudies.incident=incident;});
 throw e;
}
