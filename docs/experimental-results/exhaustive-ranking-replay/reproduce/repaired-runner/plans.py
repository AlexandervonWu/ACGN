"""Reorder at most four source rows per reference and attach each original ordinal."""
from collections import defaultdict
from itertools import groupby, islice
from pathlib import Path
import hashlib


def create_plan(source, target):
    rows=source.read_text().splitlines()
    grouped=groupby(enumerate(rows), key=lambda item: tuple(item[1].split('\t')[1:4]))
    students=[list(g) for _,g in grouped]
    emitted=[]
    for i in range(0,len(students),4):
        refs=defaultdict(list)
        for group in students[i:i+4]:
            for ordinal,text in group:
                fields=text.split('\t')
                if len(fields)!=8:raise ValueError('Invalid original ranking input')
                refs[tuple(fields[4:7])].append((ordinal,text))
        for items in refs.values():emitted.extend(items)
    if sorted(emitted)!=list(enumerate(rows)):raise ValueError('Execution plan changed endpoint identity')
    target.write_text(''.join(text+'\t'+str(n)+'\n' for n,text in emitted))
    return hashlib.sha256(target.read_bytes()).hexdigest()
