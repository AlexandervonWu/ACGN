"""After producer completion, perform the full raw recount, package it, and independently verify the compact evidence."""
import argparse
import json
from pathlib import Path
import subprocess
import sys
import time

from verify_inputs import atomic,jsonfile,sha,check

def complete(w,poll):
    cohort=w/'cohort';output=cohort/'final-verification';result_file=cohort/'closure-verdict.json'
    while not (w/'producer-complete.json').is_file():
        time.sleep(poll)
    producer=jsonfile(w/'producer-complete.json')
    check(producer['completedShards']==1059 and (producer.get('attemptedRows') or producer.get('rows'))==1894168,'Incomplete native supervisor receipt')
    if not output.exists():
        with (cohort/'final-raw-recount.log').open('w') as log:
            outcome=subprocess.run([sys.executable,str(cohort/'verify_results.py'),'--workspace',str(w),'--output',str(output)],stdout=log,stderr=subprocess.STDOUT)
        check(outcome.returncode in (0,2) and (output/'summary.json').exists(),'Raw recount failed; inspect final-raw-recount.log')
    summary=jsonfile(output/'summary.json')
    cmd=[sys.executable,str(cohort/'verify_compact.py'),str(output),str(w/'frozen'),str(cohort/'manifest.json'),str(w/'runner-identity.json')]
    completed=subprocess.run(cmd,capture_output=True,text=True)
    (cohort/'final-compact-recount.log').write_text(completed.stdout+completed.stderr)
    check(completed.returncode==(0 if summary['status']=='VERIFIED' else 2),'Portable compact recount disagrees; inspect final-compact-recount.log')
    portable=json.loads(completed.stdout)
    check(portable['summarySha256']==sha(output/'summary.json') and portable['status']==summary['status'],'Raw and compact closure verdict disagree')
    verdict={'status':summary['status'],'complete':True,'rows':summary['rows'],'checkedOrderedNativeWitnesses':summary['checkedOrderedNativeWitnesses'],'nonconforming':summary['nonconforming'],
             'rawRecount':sha(cohort/'final-raw-recount.log'),'portableRecount':sha(cohort/'final-compact-recount.log'),
             'receipt':sha(w/'producer-complete.json'),'summary':portable['summarySha256'],'auditorIdentity':sha(cohort/'auditor-identity.json')}
    atomic(result_file,verdict);print(json.dumps(verdict,sort_keys=True),flush=True)
if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--workspace',type=Path,default=Path(__file__).resolve().parent.parent);p.add_argument('--poll',type=int,default=30)
    args=p.parse_args();complete(args.workspace,args.poll)
