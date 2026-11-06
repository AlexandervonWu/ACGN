"""Post-selection memorization diagnostic, explicitly not held-out repair evidence."""
import argparse
import json
from pathlib import Path
import torch

from experiments.hybrid_edit.corpus import write
from .model import Config, GraphRepairTransformer
from .train import load_records, evaluate


def main():
    p=argparse.ArgumentParser(); p.add_argument('--run',type=Path,required=True)
    p.add_argument('--data',type=Path,required=True); p.add_argument('--count',type=int,default=64)
    args=p.parse_args(); torch.set_num_threads(4)
    device='cuda' if torch.cuda.is_available() else 'cpu'
    if device=='cuda': torch.cuda.set_per_process_memory_fraction(.89)
    checkpoint=torch.load(args.run/'best.pt',map_location='cpu',weights_only=True)
    model=GraphRepairTransformer(Config(**checkpoint['config'])).to(device)
    model.load_state_dict(checkpoint['model']); del checkpoint
    records=sorted((r for r in load_records(args.data) if r['split']=='train'),key=lambda r:r['id'])[:args.count]
    out=args.run/'training-diagnostic'; out.mkdir()
    result=evaluate(model,records,out,device,8,'training_sample')
    result['interpretation']='Training-set diagnostic only; never used for checkpoint selection or held-out success'
    result['selection']='First 64 training record IDs in lexical order, fixed before generation'
    write(out/'results.json',result); print(json.dumps(result))


if __name__=='__main__': main()
