'''
 # @ Author: feng
 # @ Create Time: 2023-05-23 20:28:52
 # @ Modified by: feng
 # @ Modified time: 2023-05-23 20:28:58
 # @ Description:
 '''

import pandas as pd
import nibabel as nib
import numpy as np

atlasData = nib.load("AAL_brain_matchedCluster.nii.gz").get_fdata()
atlasInfo = pd.read_csv("AAL_brain.csv", header=0, index_col=0)

clsImg = nib.load("cluster11_Insula_R.nii")
clsData = clsImg.get_fdata()
clsDataMask = np.copy(clsData)
clsDataMask[clsDataMask != 0] = 1

resTab = pd.DataFrame()
for i in atlasInfo.index.values:
    # mask of roi
    tmpRoiData = np.zeros(shape=atlasData.shape)
    tmpRoiData[atlasData == i] = 1
    
    tmpOverlaped = clsDataMask * tmpRoiData
    tmpNumVoxel = np.nansum(tmpOverlaped[:])
    tmpRate = tmpNumVoxel / np.nansum(tmpRoiData[:])
    
    # save results
    resTab = pd.concat([resTab, pd.DataFrame({"ROIINDEX": [i], "ROINAME": [atlasInfo.loc[i, "Name"]], "OVERLAP_NUMVOXEL": [tmpNumVoxel], "OVERLAP_RATE": [tmpRate]})])

# sort by number of voxel in overlap
resTab = resTab.sort_values(by=["OVERLAP_NUMVOXEL"], ascending=False)
resTab = resTab[resTab.OVERLAP_NUMVOXEL != 0]
resTab.to_csv("ReportsWithAAL_cluster11_Insula_R.csv", index=False)