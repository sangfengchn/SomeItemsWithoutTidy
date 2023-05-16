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

der = "results"
for i in glob(opj(der, "*", "*_All_Thres.txt")):
    logging.info(i)
    tmpPath = i
    tmpData = np.loadtxt(tmpPath)
    thrds = np.arange(0.01, 0.41, 0.01)
    tmpResPath = tmpPath.replace("_All_Thres", "_AUC")
    tmpSubRes = []    
    for j in range(tmpData.shape[0]):
        tmpSubData = tmpData[j, :]
        tmpSubData = tmpSubData[~np.isnan(tmpSubData)]
        tmpSubAuc = np.trapz(tmpSubData, dx=0.01)    
        tmpSubRes.append(f"{tmpSubAuc:.16e}\n")
    with open(tmpResPath, "w") as f:
        f.writelines(tmpSubRes)
        
logging.info("Done.")
