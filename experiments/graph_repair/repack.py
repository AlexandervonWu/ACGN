"""Re-encode retained read-only Java exports; never rerun or select by repairability."""
import argparse
import collections
import hashlib
import json
from pathlib import Path

from experiments.hybrid_edit.corpus import digest, write
from .codec import encode_pair, identity


def main():
    p=argparse.ArgumentParser(); p.add_argument('--source',type=Path,required=True)
    p.add_argument('--output',type=Path,required=True); args=p.parse_args()
    args.output.mkdir(); (args.output/'records').mkdir()
    old=json.loads((args.source/'ledger.json').read_text()); seen=set(); ledger=[]
    for previous in old:
        row={k:previous[k] for k in ('id','source','sourceHash','group','split')}
        path=args.source/'raw'/f"{row['id']}.json"
        if previous['status']=='FAILED' or not path.exists():
            ledger.append(previous); continue
        raw=json.loads(path.read_text())
        if raw['sourceHash']!=row['sourceHash']: raise ValueError('SOURCE_HASH')
        try:
            packet=encode_pair(raw)
            packet.update({k:row[k] for k in ('id','source','group','split')})
            pair=hashlib.sha256(identity([packet['key'],packet['target']]).encode()).hexdigest()
            packet['pairHash']=pair; key=row['group'],pair
            if key in seen:
                row.update(status='EXCLUDED',reason='DUPLICATE_GRAPH_PAIR')
            else:
                seen.add(key); dest=args.output/'records'/f"{row['id']}.json"; write(dest,packet)
                row.update(status='ACCEPTED',keyTokens=len(packet['key']),targetTokens=len(packet['value']),
                    pairHash=pair,packetHash=digest(dest),rawHash=digest(path))
        except ValueError as error:
            if str(error) not in ('TOKEN_BOUND','NUMBER_BOUND'): raise
            row.update(status='EXCLUDED',reason=str(error))
        ledger.append(row)
    # A repeated faulty input cannot serve as an unseen-input evaluation case.
    priority={'train':0,'validation':1,'evaluation':2}; owners={}
    for row in ledger:
        if row['status']!='ACCEPTED': continue
        packet=json.loads((args.output/'records'/f"{row['id']}.json").read_text())
        key=hashlib.sha256(identity(packet['key']).encode()).hexdigest()
        row['keyHash']=key
        owners[key]=min(owners.get(key,2),priority[row['split']])
    for row in ledger:
        if row['status']=='ACCEPTED' and priority[row['split']]!=owners[row['keyHash']]:
            row.update(status='EXCLUDED',reason='CROSS_SPLIT_INPUT_DUPLICATE')
    write(args.output/'ledger.json',ledger)
    write(args.output/'selection.json',{'sourceSelection':str(args.source/'selection.json'),
        'sourceSelectionHash':digest(args.source/'selection.json'),'sourceLedgerHash':digest(args.source/'ledger.json'),
        'codecHash':digest(Path(__file__).parent/'codec.py'),'rawRoot':str((args.source/'raw').resolve()),
        'repairabilitySelection':False})
    result={'attempts':len(ledger),'statuses':dict(collections.Counter(r['status'] for r in ledger)),
        'splits':dict(collections.Counter(r['split'] for r in ledger if r['status']=='ACCEPTED')),
        'exclusions':dict(collections.Counter(r.get('reason','') for r in ledger if r['status']=='EXCLUDED'))}
    write(args.output/'summary.json',result); print(json.dumps(result))


if __name__=='__main__': main()
