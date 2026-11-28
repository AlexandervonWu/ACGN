"""Verify the external auditor registration and the final raw/portable closure receipts."""
import argparse
import json
from pathlib import Path
import time
from verify_inputs import check,sha,jsonfile,atomic

REGISTERED_AUDITOR='e9cc9add2b3f242c7ac84ad4803dbf5c525cc528c856500cd402a37fda2a3554'
def attest(w, require_outcome):
    c=w/'cohort'; reg=c/'auditor-identity.json';check(sha(reg)==REGISTERED_AUDITOR,'Independent auditor registration was modified')
    ident=jsonfile(reg)
    for k in ('files','calibration'):
        for path,expected in ident[k].items():
            check(sha(c/path)==expected,'Registered independent evidence or verifier changed: '+path)
    check(sha(w/'runner-identity.json')==ident['runnerIdentitySha256'] and sha(w/'closure-contract.json')==ident['closureContractSha256'] and sha(c/'manifest.json')==ident['inputManifestSha256'],'Wrong registered scope/producer')
    if not require_outcome:return {'registration':'VERIFIED','auditorSha256':REGISTERED_AUDITOR}
    v=jsonfile(c/'closure-verdict.json');s=jsonfile(c/'final-verification/summary.json');p=jsonfile(c/'final-compact-recount.log')
    check(s['checkerSha256']==ident['files']['verify_results.py'] and s['inputCheckerSha256']==ident['files']['verify_inputs.py'] and s['orderedProgramCheckerSha256']==ident['files']['native_commitment.py'],'Final native recount was computed by different verifiers')
    check(v['auditorIdentity']==REGISTERED_AUDITOR and v['summary']==sha(c/'final-verification/summary.json')==p['summarySha256'],'Final verdict does not bind registered summary/portable recount')
    check(v['receipt']==sha(w/'producer-complete.json') and v['portableRecount']==sha(c/'final-compact-recount.log') and v['rawRecount']==sha(c/'final-raw-recount.log'),'Closure evidence has changed')
    check((v['status'],v['rows'],v['checkedOrderedNativeWitnesses'],v['nonconforming'])==(s['status'],s['rows'],s['checkedOrderedNativeWitnesses'],s['nonconforming'])==(p['status'],p['rows'],p['checked'],p['nonconforming']),'Conflicting completion evidence')
    answer={'verifierRegistration':'VERIFIED','complete':s['complete'],'nativeClaimStatus':s['status'],'auditorSha256':REGISTERED_AUDITOR,'producerIdentitySha256':ident['runnerIdentitySha256'],'rows':s['rows'],'nonconforming':s['nonconforming'],'closureVerdictSha256':sha(c/'closure-verdict.json')}
    atomic(c/'closure-attestation.json',answer)
    return answer
if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--workspace',type=Path,default=Path(__file__).resolve().parent.parent);parser.add_argument('--registration-only',action='store_true');parser.add_argument('--wait',action='store_true')
    args=parser.parse_args()
    if args.wait:
        while not (args.workspace/'cohort/closure-verdict.json').is_file(): time.sleep(35)
    print(json.dumps(attest(args.workspace,not args.registration_only),sort_keys=True))
