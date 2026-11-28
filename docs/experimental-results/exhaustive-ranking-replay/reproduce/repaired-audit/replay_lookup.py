"""Reconstruct both original native programs and independently check the compact receipt for a single pair."""
import argparse
import json
from pathlib import Path
import subprocess
import tempfile

from lookup_native import lookup
from native_commitment import SerializedNumber,check_programs
from verify_compact import JAR, demand, sha


def reproduce(frozen, jar, selection, output):
    demand(sha(jar)==selection['measuredJarSha256'],'Unregistered native replay binary')
    receipt=frozen/'docs/experimental-results/historical-retention/run-receipt.json'
    demand(sha(receipt)=='f4c4cafb055bb942b2aeaed7db5b7f6758be8cb8f690b0670d311228e6854a47','Changed original dependency provenance')
    deps=json.loads(receipt.read_bytes())['dependencies']
    for dep in deps:
        demand(sha(frozen/dep['path'])==dep['sha256'],'Changed original dependency '+dep['path'])
    with tempfile.TemporaryDirectory(prefix='acgn-native-one-') as name:
        compiled=Path(name)
        cp=str(jar)+':'+str(frozen/'lib/*')
        subprocess.run(['javac','--release','17','-encoding','UTF-8','-cp',cp,'-d',str(compiled),str(Path(__file__).with_name('EmitNativePrograms.java'))],check=True)
        sides=[selection[which][field] for which in ('submission','reference') for field in ('path','predicate','sha256')]
        command=['java','-Xmx1152m','-XX:ActiveProcessorCount=1','-XX:+UseSerialGC','-cp',str(compiled)+':'+cp,'is.fivefivefive.CanDis.EmitNativePrograms',str(frozen/'classified-data'),*sides]
        raw=subprocess.run(command,capture_output=True,check=True).stdout
    original=json.loads(raw,parse_float=SerializedNumber); row=dict(selection['native'])
    demand((original['status'], original['reason'])==(row['status'],row['reason']), 'Original native verdict changed on re-execution')
    if row['status']=='MATCHED':
        shared=row['sharedOrderedSequenceSha256']; temporal=row['sequenceKind']=='TEMPORAL_BLOCK_EFFECTS'
        row['fastSequenceSha256']=row['certifiedSequenceSha256']=shared
        for arm in ('fast','certified'):
            row[arm+('BlockCount' if temporal else 'ActionCount')]=row['count']
        if temporal:row['orderedBlockEffectsEqual']=True
    for key in ('endpointCorrespondenceChecked','sourceCertificatesChecked','fixedChoiceReplaysChecked','orderedBlockEffectsEqual','firstDifference'):
        if key in row:demand(original.get(key) is row[key] if type(row[key]) is bool else original.get(key)==row[key],'Re-execution changed '+key)
    for arm in ('fast','certified'):
        if arm+'Distance' in row:
            demand(original['diagnostic'][arm]['distance']==row[arm+'Distance'],'Re-execution changed '+arm+' native cost')
    check_programs(original,row)
    if output is not None:
        with output.open('xb') as f:f.write(raw)
    return {'reproduction':'VERIFIED','observedNativeStatus':original['status'],'originalReason':original['reason'],
            'fastSequenceSha256':row.get('fastSequenceSha256'),'certifiedSequenceSha256':row.get('certifiedSequenceSha256')}
if __name__=='__main__':
    a=argparse.ArgumentParser(description=__doc__);a.add_argument('archive',type=Path);a.add_argument('frozen',type=Path)
    a.add_argument('submission');a.add_argument('reference');a.add_argument('--jar',required=True,type=Path);a.add_argument('--full-receipt',type=Path)
    args=a.parse_args();selected=lookup(args.archive,args.frozen,args.submission,args.reference)
    print(json.dumps(reproduce(args.frozen,args.jar or args.frozen/'measured.jar',selected,args.full_receipt),indent=2,sort_keys=True))
