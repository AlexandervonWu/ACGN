"""Calibrate the strict cross-run witness check on altered genuine source and native observations."""
import copy
import gzip
import json
from occurrences import archived_label_reconstruction, digest, offset_between, project, require
from verify import HERE

def reject(left,right):
    try:
        offset_between(left,right)
    except ValueError:return
    raise RuntimeError("Comparator admitted an altered source or native program")

def main():
    def example(schedule):
        data=gzip.decompress((HERE/"example"/("original-"+schedule+".json.gz")).read_bytes())
        return project(data,24,4)
    old=example("cold");warm=example("warm")
    require(offset_between(old,warm)==450 and offset_between(warm,old)==-450,"Genuine warm control failed")
    block=3
    want=warm["program"][block][1][11]
    require(want["target"]["localBinding"]["sourceOccurrence"]==836,"Unexpected genuine fixture")
    for name,value in (("sourceOccurrence",840),("bindingPath","root/foreign"),("lexicalCoordinate","0:1"),("kind","SOME")):
        wrong=copy.deepcopy(warm);wrong["program"][block][1][11]["target"]["localBinding"][name]=value;reject(old,wrong)
    wrong=copy.deepcopy(warm);wrong["costs"]["fast"]["distance"]+=1;reject(old,wrong)
    wrong=copy.deepcopy(warm);wrong["program"][block][1][11]["kind"]="mislabelled";reject(old,wrong)
    wrong=copy.deepcopy(warm);wrong["program"][block][1][11]["cost"]+=1;reject(old,wrong)
    wrong=copy.deepcopy(warm);ops=wrong["program"][block][1];ops[11],ops[12]=ops[12],ops[11];reject(old,wrong)
    wrong=copy.deepcopy(warm);wrong["targetOwners"][0]["correspondence"]["owners"][0]["parentOccurrence"]=1;reject(old,wrong)
    wrong=copy.deepcopy(warm);wrong["targetOwners"][0]["correspondence"]["owners"][0]["orderedDeclarations"][0]["slots"][0]["occurrence"]+=1;reject(old,wrong)
    for offset,expected in ((345398,"3f50640330ee2e1ebc49eac4e238ced5a22f8548e50df4ab32e0d38dec3b037f"),
                            (580680,"7a7c0f1f574d9ec73617f06c4066d3456162a2bb7cfe639453a5cec842090f71")):
        require(digest(archived_label_reconstruction(old["program"],offset))==expected,"Archived exact positive control failed")
        require(digest(archived_label_reconstruction(old["program"],offset+1))!=expected,"Wrong archived label was accepted")
    print(json.dumps(dict(status="VERIFIED",correctWarmDirections=2,alteredReplayOrAuthorityRejected=10,archivePreimages=2,wrongArchiveOffsetsRejected=2)))
if __name__=="__main__":main()
