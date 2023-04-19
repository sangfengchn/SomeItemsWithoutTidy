import os
from os.path import join as opj
from glob import glob
import re
import pandas as pd
import logging
logging.basicConfig(level=logging.INFO)

def func_replace(path, oldId, newId):
    with open(path, "r") as f:
        lines = f.readlines()
    newLines = []
    for line in lines:
        newLines.append(line.replace(oldId, newId))
    with open(path, "w") as f:
        f.writelines(newLines)

def func_rename(path, oldId, newId):
    exts = [".txt", ".html", ".json", ".gii", ".toml"]
    for pPath, dPaths, fPaths in os.walk(path):
        for fPath in fPaths:
            tmpSrcPath = opj(pPath, fPath)
            logging.info(tmpSrcPath)
            if os.path.splitext(tmpSrcPath)[-1] in exts:
                func_replace(tmpSrcPath, oldId, newId)
            tmpDstPath = tmpSrcPath.replace(oldId, newId)
            os.renames(tmpSrcPath, tmpDstPath)

df = pd.read_csv("participants.csv", header=0, index_col=1)
df = df.loc[df.Site == "BNUOLD"]
# logging.info(df.head())
src = "func_toSF"
dst = "func_toSF_new"
if not os.path.exists(dst): os.makedirs(dst)

for i in glob(opj(src, "sub-*")):
    subId = os.path.split(i)[-1]
    subOldId = subId.split("-")[-1]
    subOldId = int(subOldId.replace("AGING", ""))
    subOldId = f"BNU{subOldId}"
    
    # There is no participant who is in sk but is not in sf.
    # if subOldId not in df.index.values:
    #     logging.info(subId)

    parId = df.participant_id[subOldId]
    func_rename(i, subId, parId)
    
        
logging.info("Done.")
