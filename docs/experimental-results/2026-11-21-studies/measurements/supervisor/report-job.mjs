import {assert,fs,cp,read} from '../common.mjs';
import path from 'node:path';
import {childEnvironment} from '../../publication-capability-repair-20261115-v4/runtime.mjs';
import {meta} from './receipts.mjs';
export function reserve(p){
 fs.mkdirSync(p.output); // A whole private destination; never run a writer against an earlier arm.
 for(const [src,relative] of p.copies){
  assert(!path.isAbsolute(relative)&&!relative.split('/').includes('..'));const dest=path.join(p.output,relative);
  fs.mkdirSync(path.dirname(dest),{recursive:true});assert(!fs.existsSync(dest));
  fs.cpSync(src,dest,{recursive:true,errorOnExist:true,force:false});
 }
}
export function fresh(p,names){for(const name of names){assert(!fs.existsSync(path.join(p.output,name)),'REPORT_TARGET_EXISTS '+name);}}
if(process.argv[1]===import.meta.filename){
 const p=read(process.argv[2]);reserve(p);
 for(const [i,cmd] of p.commands.entries()){
  fresh(p,p.freshBefore[i]);const fd=fs.openSync(path.join(p.output,'command-'+i+'.log'),'wx');let r;
  try{r=cp.spawnSync(cmd[0],cmd.slice(1),{cwd:p.checkout,env:childEnvironment(),stdio:['ignore',fd,fd]});}finally{fs.closeSync(fd);}
  assert.equal(r.status,0,'REPORT_COMMAND_FAILED '+i+' '+r.signal);
 }
}
