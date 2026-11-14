import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import cp from 'node:child_process';
import assert from 'node:assert/strict';
export const meta=file=>({file,sha256:crypto.createHash('sha256').update(fs.readFileSync(file)).digest('hex')});
const read=file=>JSON.parse(fs.readFileSync(file));
const sorted=xs=>[...xs].sort((a,b)=>a.file.localeCompare(b.file));
export function inventory(dir){
 assert.equal(fs.realpathSync(dir),dir,'Runtime root must be absolute/canonical');
 const files=[];
 for(const name of fs.readdirSync(dir)){
  const file=path.join(dir,name),s=fs.lstatSync(file);
  assert.equal(s.isSymbolicLink(),false,'No runtime symlinks');
  if(s.isDirectory())files.push(...inventory(file));else{assert.ok(s.isFile());files.push(meta(file));}
 }
 return sorted(files);
}
export function validateRuntime(config,probeSource,initial=false){
 const r=config.runtime,sources=read(config.candidate.file),builds=read(config.build.file);
 assert.ok(r&&Array.isArray(r.jars)&&r.jars.length>0);
 assert.equal(config.classpath,[r.classes,...r.jars.map(x=>x.file)].join(':'),'Undeclared runtime root or wildcard');
 for(const file of [r.classes,...r.jars.map(x=>x.file),r.java.file]){assert.ok(path.isAbsolute(file)&&!/[\n:*]/.test(file));assert.equal(fs.realpathSync(file),file);}
 assert.deepEqual(inventory(r.classes),sorted(builds),'Runtime directory membership/hash mismatch');
 for(const f of [r.java,...r.jars,r.compilation])assert.deepEqual(meta(f.file),f,'Runtime hash mismatch');
 const probeClass=path.join(r.classes,'is/fivefivefive/CanDis/QueueProbe.class');
 assert.ok(builds.some(x=>x.file===probeClass),'Missing fresh QueueProbe');
 const build=read(r.compilation.file);
 assert.equal(build.schema,'fresh-current-javac-v1');assert.equal(build.exitCode,0);
 assert.deepEqual(build.sourceManifest,config.candidate);assert.deepEqual(build.outputInventory,config.build);
 assert.equal(build.outputDirectory,r.classes);
 assert.deepEqual(meta(build.probeSource.file),build.probeSource,'Compiled probe source changed');
 assert.equal(build.probeSource.sha256,meta(probeSource).sha256,'Unreviewed probe source content');
 assert.ok(config.verifierFiles.some(x=>fs.realpathSync(x.file)===fs.realpathSync(build.probeSource.file)&&x.sha256===build.probeSource.sha256),'Unbound QueueProbe source');
 for(const f of [build.sourceList,build.compiler,build.receipt])assert.deepEqual(meta(f.file),f);
 const javaSources=[...sources.filter(x=>x.file.endsWith('.java')).map(x=>x.file),build.probeSource.file];
 const actual=fs.readFileSync(build.sourceList.file,'utf8').trim().split('\n');
 assert.deepEqual([...new Set(actual.map(x=>fs.realpathSync(x)))].sort(),[...new Set(javaSources.map(x=>fs.realpathSync(x)))].sort(),'Compile source list mismatch');
 const command=[build.compiler.file,'-J-Xmx2g','-cp',r.jars.map(x=>x.file).join(':'),'-d',r.classes,'@'+build.sourceList.file];
 const receipt=read(build.receipt.file);assert.equal(receipt.exitCode,0);assert.deepEqual(receipt.command,command);
 assert.ok(receipt.observations.length===1,'Compile must have one bound guard receipt');
 const terminal=read(receipt.observations[0]+'/terminal.json');
 assert.equal(terminal.exitCode,0);assert.equal(terminal.commandExit,0);assert.equal(terminal.descendantsExited,true);
 if(initial)for(const jar of r.jars){
  const m=cp.spawnSync('unzip',['-p',jar.file,'META-INF/MANIFEST.MF'],{encoding:'utf8'});
  assert.ok([0,11].includes(m.status),'Cannot inspect dependency manifest');
  assert.ok(!/^Class-Path:/mi.test(m.stdout),'Transitive manifest classpath is not closed');
  const q=cp.spawnSync('unzip',['-Z1',jar.file,'is/fivefivefive/CanDis/QueueProbe.class'],{encoding:'utf8'});
  assert.equal(q.status,11,'Dependency may not shadow QueueProbe');
 }
 return [r.java,...r.jars,r.compilation,build.sourceList,build.compiler,build.receipt];
}
