'''
 # @ Author: feng
 # @ Create Time: 2023-05-16 16:00:12
 # @ Modified by: feng
 # @ Modified time: 2023-05-16 16:00:13
 # @ Description: 获取指标的AUC值。
 '''

import os
from os.path import join as opj
from glob import glob
import numpy as np
import logging
logging.basicConfig(level=logging.INFO, format="%(asctime)s %(message)s")

der = "results/NodalShortestPath"
nodalPaths = [f"{der}/NLp_Thres{i+1:03d}.txt" for i in range(36)]
nodalData = []
for i in nodalPaths:
    nodalData.append(np.loadtxt(i))
nodalData = np.array(nodalData)

# each sub
tmpRes = []
for i in range(nodalData.shape[1]):
    # each region
    tmpSub = []
    for j in range(nodalData.shape[2]):
        tmpSubData = nodalData[:, i, j]
        tmpSubData = tmpSubData[~np.isnan(tmpSubData)]
        tmpSubData = tmpSubData[~np.isinf(tmpSubData)]
        tmpSubAuc = np.trapz(tmpSubData, dx=0.01)    
        tmpSub.append(tmpSubAuc)
    tmpRes.append(tmpSub)
tmpRes = np.array(tmpRes)
# logging.info(tmpRes.shape)
np.savetxt(opj(der, "NLp_AUC.txt"), tmpRes, fmt="%.16e", delimiter="\t")
logging.info("Done.")