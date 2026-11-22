import {fs,assert,cp,cfg,base,read,save,P} from '../common.mjs';
import {reserve,fresh} from './report-job.mjs';
const d=import.meta.dirname+'/report-fixture';fs.mkdirSync(d);
const dir=(parent,n)=>{const r=parent+'/'+n;fs.mkdirSync(r);return r;};
const input=dir(d,'input'),source=import.meta.dirname+'/CheckedClaims.java',prod='is.fivefivefive.CanDis.EGraphSemanticSoundnessCheck';
fs.writeFileSync(input+'/b.als','sig S {}\npred p { no S }\npred q { #S = 0 }\ncheck correct {p iff q} for 3\n',{flag:'wx'});
fs.copyFileSync(base.checkout+'/src/is/fivefivefive/CanDis/ablation/soundness/let_shadow_inv1.als',input+'/a.als');
const engines=read(P+'/natural-batch.json').stages.slice(0,7).map(s=>read(s.plan.file).engine);
function solve(label,main,files){
 const out=dir(d,label);for(const e of engines){const p=dir(out,e);
 fs.writeFileSync(p+'/pairs.csv','path,problem,status,left,right,success,equivalent\n'+files.map(f=>[f,'fixture','correct','p','q',true,true].join(',')).join('\n')+'\n',{flag:'wx'});}
 const fd=fs.openSync(out+'/command.log','wx');let r;
 try{r=cp.spawnSync(cfg.java.file,['-Xmx768m','-cp',cfg.classpath,main,'--input',input,'--results',out,'--threads','1'],{cwd:base.checkout,stdio:['ignore',fd,fd]});}finally{fs.closeSync(fd);}
 return {out,rc:r.status};
}
const original=solve('original',prod,['b.als']),replacement=solve('replacement',source,['b.als']);
for(const t of [original,replacement])assert.equal(t.rc,0,t.out);
const comparable=x=>{const j=read(x.out+'/semantic_soundness.json');return {checks:j.checks.map(({solveNanos,...k})=>k),probes:j.targetedProbes,arms:j.arms};};
assert.deepEqual(comparable(original),comparable(replacement));
for(const [name,files,reason] of [['counterexample',['a.als','b.als'],'COUNTEREXAMPLE'],['missing',['0.als','b.als'],'ERROR']]){
 const t=solve(name,source,files);assert.notEqual(t.rc,0);
 const j=read(t.out+'/incident.json');assert(j.error.includes(reason));assert.equal(j.neverSubmitted,1);assert.equal(j.accepted,0);assert.equal(j.laterPhaseUnattempted,4);
}
const fake={output:d+'/exclusive',copies:[]};reserve(fake);assert.throws(()=>reserve(fake));
fs.writeFileSync(fake.output+'/summary.md','preserved',{flag:'wx'});assert.throws(()=>fresh(fake,['summary.md']));assert.equal(fs.readFileSync(fake.output+'/summary.md','utf8'),'preserved');
save(d+'/result.json',{status:'PASS',positive:'identical tagged solver outcomes, per-arm summaries and four probes',controls:['counterexample stops','missing claim stops','never-submitted counted','fresh root','existing report preserved']});
