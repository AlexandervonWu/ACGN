"""Recompute the manuscript's natural-corpus statistics from frozen producer outputs.

python3 verify-publication.py CANONICAL_BATCH_DIR AUGMENTER_DIR  (requires jq)
"""
import csv
import hashlib
import json
import re
import subprocess
import sys
import xml.etree.ElementTree as ET
from collections import Counter
from pathlib import Path

root = Path(__file__).resolve().parent
paired, augmenter = map(Path, sys.argv[1:])
def read(p):
    return json.loads(p.read_bytes())
def sha(p):
    with p.open('rb') as f:
        return hashlib.file_digest(f, 'sha256').hexdigest()
def rows(p, expr):
    with subprocess.Popen(['jq', '-cn', '--stream', expr, str(p)], stdout=subprocess.PIPE) as proc:
        for line in proc.stdout:
            yield json.loads(line)
        if proc.wait():
            raise ValueError('invalid JSON stream')
def require(value, label):
    if not value:
        raise ValueError(label)

bound = {x['file']:x['sha256'] for x in read(root/'evidence-index.json')['bulkOutputs']}
files = [paired/'diagnostic-operations-distances.json',augmenter/'index.json',
         augmenter/'canonical_reward_points.csv',augmenter/'correct_ast_diff_canonical_equiv.json',
         augmenter/'raw_edit_repair_coverage_ast_canonical.svg',augmenter/'relative_repair_coverage_comparison.svg']
for p in files:
    require(sha(p)==bound[p.name if p.parent==augmenter else 'canonical-batch/'+p.name],str(p))
for p in files[-2:]:
    original = p.read_bytes()
    for old, new in [(b'Incorrect predicates repaired within radius', b'Incorrect predicates with a reference within radius'),
                     (b'Repair coverage by edit distance', b'Nearest-reference distance coverage'),
                     (b'Relative repair coverage by metric', b'Nearest-reference coverage by relative distance')]:
        original = original.replace(old,new)
    require(original==(root/p.name).read_bytes(),'figure source differs beyond approved labels')
fields = ['rawAstSize','canonicalFormSize','canonicalRepresentativeTreeSize','predicateBodyLevenshteinDistance',
          'rawAstTreeDistance','distance','canonicalRepresentativeTreeDistance']
totals = Counter()
n = 0
for values in rows(files[0],'fromstream(2|truncate_stream(inputs|select(.[0][0]=="results")))|['+','.join('.'+x for x in fields)+']'):
    require(len(values)==len(fields) and all(type(x) is int for x in values),'missing integer field')
    totals.update(dict(zip(fields,values)))
    n += 1
require(n==61598,'paired cohort')
means = {k:round(v/n,6) for k,v in totals.items()}
require(list(means.values())==[19.668561,17.965600,33.272687,39.261064,17.086902,13.960405,32.125215],f'paired means: {means}')
def identity(ref):
    return tuple(ref[k] for k in ('name','kind','source'))
def group(row):
    return row['questionSet'],row['invariantId']
parents = {}
for q in rows(files[1],'limit(181;fromstream(2|truncate_stream(inputs|select(.[0][0]=="questions"))))'):
    require(group(q) not in parents,'duplicate group')
    parents[group(q)]={identity(x):identity(x) for x in q['references']}
    require(len(parents[group(q)])==q['astDistinctTruthCount'],'reference identity')
def find(p,x):
    while x!=p[x]:
        p[x]=p[p[x]]
        x=p[x]
    return x
zeros = read(files[3])['pairs']
for z in zeros:
    require(z['rawAstDistance']>0 and z['certificateIntegratedDistance']==z['fastRewriteCanonicalDistance']==0,'foreign zero')
    p=parents[group(z)]
    p[find(p,identity(z['left']))]=find(p,identity(z['right']))
with (root/'question-pools.csv').open() as f:
    expected={(r['question_class'],r['inv_id']):(int(r['#UniqueAST']),int(r['#UniqueCanonical'])) for r in csv.DictReader(f)}
actual={k:(len(p),len({find(p,x) for x in p})) for k,p in parents.items()}
require(actual==expected and len(actual)==181,'question table')
series=['rawAst','canonical','levenshtein']
dist={k:Counter() for k in series}
relative={k:Counter() for k in series}
seen=set()
with files[2].open() as f:
    for row in csv.DictReader(f):
        require(row['relativePath'] not in seen,'duplicate reward')
        seen.add(row['relativePath'])
        for k in series:
            value,size=int(row[k+'Distance']),int(row[k+'Size'])
            dist[k][value]+=1
            for pct in (5,10,20,50):
                relative[k][pct]+=100*value<=pct*size
require(len(seen)==42386,'nearest cohort')
nearest={k:round(sum(n*v for n,v in ds.items())/len(seen),6) for k,ds in dist.items()}
require(nearest=={'rawAst':12.267140,'canonical':11.505356,'levenshtein':28.054924} and dist['canonical'][0]==0,'nearest means')
coverage={k:[sum(v for val,v in ds.items() if val<=i) for i in range(51)] for k,ds in dist.items()}
figure=ET.parse(files[-2])
curves=figure.findall('.//{http://www.w3.org/2000/svg}path')
require(len(curves)==2,'figure series')
for k,curve in zip(series,curves):
    points=[tuple(map(float,xy)) for xy in re.findall(r'[ML]\s+([\d.]+)\s+([\d.]+)',curve.get('d'))]
    require(len(points)==51,'plot points')
    for i,(x,y) in enumerate(points):
        require(abs(x-(88+17*i))<1e-6 and abs(y-(534-464*coverage[k][i]/len(seen)))<1e-6,'coverage point')
require([coverage['canonical'][x] for x in (1,2,5,10)]==[1740,4410,13142,25298],'absolute coverage')
require(list(relative['canonical'].values())==[237,1174,5069,16066],'relative coverage')
print(json.dumps(dict(paired=n,pairedMeans=means,ranked=len(seen),nearestMeans=nearest,
    absoluteCoverage={k:[v[i] for i in (1,2,5,10)] for k,v in coverage.items()},relativeCoverage=relative,
    poolGroups=len(actual),components=sum(v[1] for v in actual.values()),uniqueAST=sum(v[0] for v in actual.values()),
    correctPoolZeros=len(zeros),verifiedSvgCoordinates=102,questionTableSha256=sha(root/'question-pools.csv')),indent=2))
