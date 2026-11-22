import {assert,fs,root as old,out,P,read,save,current,base,tag,terra,owner,update} from '../common.mjs';
import {meta,write,load} from './receipts.mjs';
import {verify,validatePlan} from '../../publication-studies-20261115-v3/stage-runner.mjs';
import path from 'node:path';
current();const d=import.meta.dirname,bulk=out+'/run-v4',stages=[],boundFiles=new Map();
for(const f of ['seal-fixture/result.json','report-fixture/result.json'])assert.equal(read(d+'/'+f).status,'PASS');
for(const p of [d+'/plans',d+'/runs',bulk,bulk+'/natural-ablation',bulk+'/capability',bulk+'/capability/arms',bulk+'/natural-slot-typing'])fs.mkdirSync(p);
const deps=['service.mjs','receipts.mjs','coordinate.mjs','prepare.mjs','report-job.mjs','CheckedClaims.java','seal-controls.mjs','report-controls.mjs','seal-fixture/result.json','report-fixture/result.json'].map(n=>meta(d+'/'+n));
deps.push(meta(old+'/common.mjs'),meta(P+'/stage-runner.mjs'),meta(P+'/helper-integrity.mjs'));
const commonReport=['run-manifest.json','comparison.json','minimum_distances.csv','equivalence_disagreements.csv','canonical_only_vs_slotted.md','summary.md'];
const semantic=['semantic_soundness.json','semantic_counterexamples.csv','semantic_soundness.md'];
const capability=['results.csv','pair_results.csv','unexpected_failures.csv','transitions.csv','results.json','REPORT.md'];
for(const s of read(old+'/batch.json').stages){
 const p=load(s.plan),f=d+'/plans/'+p.stage+'.json';p.predecessors=stages.map(s=>s.plan);p.runDir=d+'/runs/'+p.stage;p.stopFile=d+'/STOP.json';p.output=p.output.replace(out+'/',bulk+'/');
 p.launcherInputs=[...p.launcherInputs,...deps];p.extraInputs=[...p.extraInputs,...deps,s.plan];p.command=[...p.command.slice(0,-1),f];
 if(p.job!=='arm'){
  const work=p.output+'/work',nat=bulk+'/natural-ablation';p.copies=[];p.command=[process.execPath,d+'/report-job.mjs',f];
  const dirs=(prefix,name='work')=>stages.map(s=>load(s.plan)).filter(t=>t.job==='arm'&&t.stage.startsWith(prefix)).map(t=>[t.output,name+'/'+t.engine]);
  const within=(names,prefix='work/')=>names.map(n=>prefix+n);
  const replace=(from,to)=>{p.commands=p.commands.map(args=>args.map(v=>v===from?to:v));};
  if(p.stage==='natural-report-and-soundness'){
   p.copies=dirs('natural-');replace(out+'/natural-ablation',work);
   replace('is.fivefivefive.CanDis.EGraphSemanticSoundnessCheck',d+'/CheckedClaims.java');
   p.freshBefore=[within(commonReport),within(semantic)];p.requiredOutputs=p.freshBefore.flat();
  }else if(p.stage==='capability-report'){
   p.copies=dirs('capability-','work/arms');for(const n of ['metadata.csv','metadata.json','skips.csv','soundness.json','soundness.csv']){
    p.copies.push([P+'/capability/'+n,'work/'+n]);
   }
   replace(out+'/capability/arms',work+'/arms');replace(out+'/capability',work);replace(out+'/natural-ablation',nat);
   p.freshBefore=[within(commonReport,'work/arms/'),within(capability)];p.requiredOutputs=p.freshBefore.flat();
  }else if(p.stage==='slot-typing-report'){
   p.copies=dirs('slot-typing-');replace(out+'/natural-slot-typing',work);p.freshBefore=[within(commonReport)];p.requiredOutputs=p.freshBefore.flat();
  }else{
   assert.equal(p.stage,'synthetic-slot-runtime');replace(old+'/plans/'+p.stage+'.json',f);p.syntheticOutput=p.output+'/grid';
   replace(out+'/synthetic-run',p.syntheticOutput);replace(out+'/synthetic-plots',p.output+'/plots');
   p.freshBefore=[['grid'],['grid/audit.json'],['plots']];p.requiredOutputs=['grid/audit.json'];
  }
 }
 validatePlan(p,load(p.runtimeConfig));for(const z of [p.runtimeConfig,p.datasetInventory,...p.extraInputs,...p.launcherInputs,...p.prerequisiteFiles,...p.files]){
  if(!boundFiles.has(z.file))boundFiles.set(z.file,meta(z.file));assert.deepEqual(boundFiles.get(z.file),z);
 }
 const plan=write(f,p);stages.push({stage:p.stage,plan});
}
assert.equal(stages.length,20);const p=load(stages[0].plan);verify(p,load(p.runtimeConfig));
const inventory=write(d+'/input-inventory.json',{files:[...boundFiles.values()]});
const bound=[meta(process.execPath),...p.launcherInputs,...stages.map(s=>s.plan),inventory];
const request=write(d+'/request.json',{releaseTag:tag,build:base.commit,reviewerId:terra,stages,bound,
 scope:'Only coordinate.mjs, on ACCEPT bound to this request SHA. 20 original study stages; no tag movement. Private report roots; private guard completion channel. Historical capability generator sanity checks are input evidence only.',
 trust:'Sole unprivileged owner, trusted systemd and supervisor in memory, no malicious root or hostile measured runtime. Any lost coordinator requires new reconciliation/review, never reconstruct trusted pins from disk alone.',
 controls:[meta(d+'/seal-fixture/result.json'),meta(d+'/report-fixture/result.json')],priorRefusals:[meta(old+'/phase-a-answer.json'),meta(old+'/terra-answer-v2.json')]});
update(l=>{assert.equal(l.activeWriter,owner);assert(!l.executionRunning&&!l.activeReviewer);l.activeWriter=null;l.activeReviewer=terra;l.v31SupplementalStudies.status='TERRA_LAUNCH_REVIEW';l.v31SupplementalStudies.request=request;});
