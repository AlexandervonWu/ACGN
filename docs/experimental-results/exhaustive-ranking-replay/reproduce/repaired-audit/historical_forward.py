"""Bind each archived paid forward control's original source, predicate and measured scalar before recounting."""
from controls import inventory,forwards
from verify_inputs import check,sha,tsv,jrows
from verify_compact import PUBLISHED
from pathlib import Path
import json

def verify(archive,w):
    groups=inventory(w/'original-inputs');protected=set().union(*(groups[g] for g in ('paid','both','ratchet-forward','stratified')))
    published={k:w/'original-inputs'/r for k,(r,_) in PUBLISHED.items()};frozen=w/'original-inputs'
    for k,(_,h) in PUBLISHED.items():check(sha(published[k])==h,'Changed score or predicate authority')
    refs={(r['source'],r['operator'],r['sha']):r['id'] for r in jrows(published['references'])}
    students={r['path']:r['left'] for r in jrows(published['pairs'])}
    by={}
    for p,name,h,q,qn,qh,cost in protected:
        check(students[p]==name and sha(frozen/'classified-data'/p)==h and sha(frozen/'classified-data'/q)==qh,'Historical paid selector does not bind original source')
        i=refs[q,qn,qh];d=by.setdefault(p,{})
        check(i not in d,'Repeated original paid control with a different cost');d[i]=int(cost)
    verified=0
    for p,ids,fast,cert in jrows(published['scores']):
        for i,cost in by.get(p,{}).items():
            j=ids.index(i);check(fast[j]==cert[j]==cost and cost>0,'Archived native cost disagrees with original rank score');verified+=1
    check(verified==len(protected),'A historical paid native observation lacks a matching ranked source')
    result=forwards(archive,w);check(result['distinct']==verified,'Protected score and native trace inventories disagree')
    result['originalSourceHashBoundPaidComparisons']=verified
    return result
