'''
 # @ Author: feng
 # @ Create Time: 2023-05-16 13:10:39
 # @ Modified by: feng
 # @ Modified time: 2023-05-16 13:10:41
 # @ Description: Copy results of fmriprep.
 '''

import os
from os.path import join as opj
import shutil
import pandas as pd
import logging
logging.basicConfig(level=logging.INFO, format="%(asctime)s %(message)s")

der = "./derivatives/freesurfer"
dst = "./toJLL/freesurfer"
if not os.path.exists(dst): os.makedirs(dst)

df = pd.read_csv("./sourcedata/participants.csv", header=0, index_col=3)
newDf = pd.read_csv("./subinfo_jll.csv", header=0, index_col=0)
for i in df.index.values:
    subMriId = df.loc[i, "OLDID"]
    if subMriId in newDf.index.values:
        logging.info(subMriId)
        subSrcPath = opj(der, i)
        subDstPath = opj(dst, i)
        shutil.copytree(subSrcPath, subDstPath)

logging.info("Done")
