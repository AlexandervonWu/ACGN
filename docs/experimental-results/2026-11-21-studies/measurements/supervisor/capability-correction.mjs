import {fs,current,assert,update,owner,terra} from '../common.mjs';
import {load,write,meta} from './receipts.mjs';
current();const d=import.meta.dirname,source=meta(d+'/request.json'),r=load(source),decision=meta(d+'/terra-answer.json');
assert.equal(load(decision).decision,'BLOCKED');fs.mkdirSync(d+'/plans-v4b');
const stages=[], revised=[meta(import.meta.filename),meta(d+'/coordinate-v4b.mjs')];
for(const s of r.stages){
 const p=load(s.plan),file=d+'/plans-v4b/'+s.stage+'.json';
 p.predecessors=stages.map(i=>i.plan);p.command=p.command.map(x=>x===s.plan.file?file:x);
 if(p.commands)p.commands=p.commands.map(row=>row.map(x=>x===s.plan.file?file:x));
 if(s.stage==='capability-report'){
  const history=['work/soundness.json','work/soundness.csv'];
  assert.equal(p.copies.filter(([,n])=>history.includes(n)).length,2);
  p.copies=p.copies.filter(([,n])=>!history.includes(n));p.freshBefore[1].push(...history);
 }
 p.launcherInputs=[...p.launcherInputs,...revised];
 stages.push({stage:s.stage,plan:write(file,p)});
}
const bound=[...r.bound,...revised,source,decision,...stages.map(s=>s.plan)];
const request=write(d+'/request-v4b.json',{...r,stages,bound,coordinator:meta(d+'/coordinate-v4b.mjs'),correction:'Historical v3 generation soundness files are still immutable cohort provenance, never copied to report workspace. Affirm absence immediately before tagged capability reporter. No new capability-generation sanity result claimed.'});
update(l=>{assert(l.activeWriter===owner&&!l.activeReviewer&&!l.executionRunning);l.activeWriter=null;l.activeReviewer=terra;l.v31SupplementalStudies.request=request;l.v31SupplementalStudies.status='TERRA_REVIEW_CAPABILITY_PROVENANCE';});
