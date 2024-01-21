'''
 # @ Author: sangfeng
 # @ Create Time: 2024-01-15 19:57:22
 # @ Modified by: sangfeng
 # @ Modified time: 2024-01-15 19:57:24
 # @ Description: Estimate fc matrix based on a atlas file.
 '''

from pathlib import Path
import numpy as np
import nibabel as nib
import logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s %(message)s')

proj = Path('.')
funSrcPath = proj / 'FunImgARCFWS'
dstPath = proj / 'Results' / 'sf_ROICorrelation'
if not dstPath.exists(): dstPath.mkdir()

datAtl = nib.load('BN_Atlas_246_3mm.nii').get_fdata()
numRoi = 246

for i in funSrcPath.glob('sub-*/*.nii'):
    tmpSubId = i.parent.name
    # logging.info(tmpSubId)

    tmpSubDat = nib.load(i).get_fdata()
    tmpSubMeanTimeSeries = np.zeros(shape=(numRoi, tmpSubDat.shape[-1]))

    for aIdx in range(numRoi):
        logging.info(f'{tmpSubId}: region {aIdx + 1}')
        # tmpAtlMask = np.zeros(shape=tmpSubDat.shape)
        # tmpAtlMask[datAtl == aIdx + 1, :] = 1
        # tmpAtlDat = tmpSubDat * tmpAtlMask
        # tmpAtlSum = np.sum(tmpAtlDat, axis=(0, 1, 2))
        # tmpAtlNum = np.sum(tmpAtlMask, axis=(0, 1, 2))
        # tmpSubMeanTimeSeries[aIdx, :] = tmpAtlSum / tmpAtlNum
        tmpAtlMask = np.zeros(shape=datAtl.shape)
        tmpAtlMask[datAtl == aIdx + 1] = 1
        tmpAtlSum = np.sum(tmpAtlMask[:])
        for tIdx in range(tmpSubDat.shape[-1]):
            tmpSubDatTp = tmpSubDat[:, :, :, tIdx]
            tmpTpSingle = tmpSubDatTp * tmpAtlMask
            tmpSubMeanTimeSeries[aIdx, tIdx] = np.sum(tmpTpSingle[:]) / tmpAtlSum
    
    tmpSubMatR = np.corrcoef(tmpSubMeanTimeSeries, rowvar=True)
    tmpSubMatZ = np.log((1 + tmpSubMatR) / (1 - tmpSubMatR)) / 2
    
    np.savetxt(dstPath.joinpath(f'PearsonCorrelation_{tmpSubId}.txt'), tmpSubMatR, delimiter='\t', fmt='%.016e')
    np.savetxt(dstPath.joinpath(f'PearsonCorrelation_FisherZ_{tmpSubId}.txt'), tmpSubMatZ, delimiter='\t', fmt='%.016e')

logging.info('Done.')