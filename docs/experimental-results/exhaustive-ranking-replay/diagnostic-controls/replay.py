"""Rebuild both JARs from Git and replay the two diagnostic harnesses on the test-only binary."""
import argparse
import gzip
import json
import subprocess
import zipfile
from pathlib import Path

from verify import BASE, BASE_JAR, TEST, TEST_JAR, FILES, ROOT, need, sha


def run(repo, dest):
    dest.mkdir(parents=True,exist_ok=False)
    measurements={}
    for label,revision,wanted in (("measured",BASE,BASE_JAR),("control",TEST,TEST_JAR)):
        work=dest/label;work.mkdir()
        include=["src","lib"]
        if label=="control":
            include += ["classified-data","docs/distance-parity-20261107/retained-domain-maps.als"]
        with subprocess.Popen(["git","-C",repo,"archive",revision,*include],stdout=subprocess.PIPE) as git:
            subprocess.run(["tar","-xf","-","-C",work],stdin=git.stdout,check=True);git.stdout.close()
            need(git.wait()==0,"Git source reconstruction failed")
        classes=work/"classes";classes.mkdir()
        subprocess.run(["javac","-J-Xmx650m","-J-XX:ActiveProcessorCount=2","--release","17","-encoding","UTF-8","-cp",str(work/"lib/*"),"-d",classes,*sorted((work/"src").rglob("*.java"))],check=True)
        jar=work/"engine.jar"
        subprocess.run(["jar","--create","--file",jar,"--date=2000-01-01T00:00:00Z","-C",classes,"."],check=True)
        need(sha(jar.read_bytes())==wanted,"Measured compiler/ZIP bytes differ from the registered JAR")
        with zipfile.ZipFile(jar) as z:
            actual="".join(sha(z.read(s))+"  "+s+"\n" for s in sorted(z.namelist()) if s.endswith(".class")).encode()
        need(actual==gzip.decompress((ROOT/"build"/(label+"-classes.sha256.gz")).read_bytes()),"Rebuilt class inventory differs")
        measurements[label]=str(jar)
    result={}
    control=dest/"control"
    for name,count in zip(FILES,[208,113]):
        args=["java","-ea","-XX:ActiveProcessorCount=1","-XX:+UseSerialGC","-Xmx512m","-Dacgn.test.repoRoot="+str(control),"-cp",
              measurements["control"]+":"+str(control/"lib/*"),"is.fivefivefive.CanDis.core."+name]
        if name=="RetainedPaidCompletionTest":args.append(str(dest/"retained.json"))
        out=dest/(name+".log")
        with out.open("wb") as f:p=subprocess.run(args,cwd=dest,stdout=f,stderr=subprocess.STDOUT)
        need(p.returncode==0 and (name+": "+str(count)+" checks passed").encode() in out.read_bytes(),"Harness failed: "+name)
        result[name]={"exit":p.returncode,"checks":count,"logSha256":sha(out.read_bytes())}
    data=dict(status="VERIFIED",measuredJarSha256=BASE_JAR,controlJarSha256=TEST_JAR,harnesses=result)
    (dest/"reproduction.json").write_text(json.dumps(data,indent=2,sort_keys=True)+"\n")
    print(json.dumps(data,sort_keys=True))


if __name__=="__main__":
    p=argparse.ArgumentParser(description=__doc__);p.add_argument("--repo",type=Path,required=True);p.add_argument("--output",type=Path,required=True)
    a=p.parse_args();run(a.repo.resolve(),a.output.resolve())
