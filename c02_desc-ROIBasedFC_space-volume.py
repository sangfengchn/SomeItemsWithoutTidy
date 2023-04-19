'''
 # @ Author: Feng Sang
 # @ Create Time: 2022-06-16 22:37:05
 # @ Modified by: Feng Sang, Shaokun Zhao
 # @ Modified time: 2022-06-16 22:50:08
 # @ Description: Generating the voxel-based fc.
 '''
import os
from glob import glob
import numpy as np
import pandas as pd
import nibabel as nib
from nilearn.maskers import NiftiLabelsMasker
import logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s %(message)s')

derRoot = '/home/lenovo/Desktop/zhaoshaokun/Brain_Development_and_Aging/Data/aging/Preprocess/fmriprep'
tmpRoot = '/home/lenovo/Desktop/zhaoshaokun/Brain_Development_and_Aging/Data/aging/Preprocess/tmp'

rois_name = pd.read_csv('/home/lenovo/Desktop/zhaoshaokun/Brain_Development_and_Aging/Toolbox/GradiantCalcu/resource/Schaefer2018_1000Parcels_7Networks_order_FSLMNI152_2mm.Centroid_RAS.csv', header=0, index_col=0)
rois_name = rois_name['ROI Name'].values
low_pass=0.08
high_pass=0.009
t_r=2
# remove_time = 10

masker = NiftiLabelsMasker('/home/lenovo/Desktop/zhaoshaokun/Brain_Development_and_Aging/Toolbox/GradiantCalcu/resource/'
                           'Schaefer2018_1000Parcels_7Networks_order_FSLMNI152_2mm.nii.gz', labels=rois_name,
                           standardize=True, low_pass=low_pass, high_pass=high_pass, t_r=t_r)

for i in glob(os.path.join(derRoot, 'sub-*')):
    subId = os.path.split(i)[-1]
    func_path = os.path.join(derRoot, subId, 'func', f'{subId}_task-rest_space-MNI152NLin6Asym_desc-denosied_bold.nii.gz')
    if not os.path.exists(func_path):
        continue
    
    if (os.path.exists(func_path.replace('denosied_bold.nii.gz', 'fc_atl-Schaefer2018_1000.txt')) |
        os.path.exists(os.path.join(tmpRoot, f'{subId}.running')) |
        os.path.exists(os.path.join(tmpRoot, f'{subId}.finished'))):
        continue
    
    # lock
    with open(os.path.join(tmpRoot, f'{subId}.running'), 'a')as f:
        f.writelines('')
        
    logging.info(subId)
    func_img = nib.load(func_path)
    
    TimeSeries = masker.fit_transform(func_img)
    
    CorCoefVoxel = np.corrcoef(TimeSeries.T)
    CorCoefVoxelZ = np.log((1 + CorCoefVoxel) / (1 - CorCoefVoxel)) / 2

    # define self connection in ZFC equals to 0
    for x in range(1000):
        for y in range(1000):
            if x == y:
                CorCoefVoxelZ[x, y] = 0


    np.savetxt(os.path.join(derRoot, subId, 'func', f'{subId}_task-rest_space-MNI152NLin6Asym_desc-fc_atl-Schaefer2018_1000.txt'), CorCoefVoxel, delimiter='\t')
    np.savetxt(os.path.join(derRoot, subId, 'func', f'{subId}_task-rest_space-MNI152NLin6Asym_desc-zfc_atl-Schaefer2018_1000.txt'), CorCoefVoxelZ, delimiter='\t')

    ## select top 10% value in every row for gradient compute (brainspace can compute this)
    # CorCoefVoxelZ_posionly = CorCoefVoxelZ
    # CorCoefVoxelZ_posionly[CorCoefVoxelZ_posionly < 0] = 0
    # for x in range(1000):
    #     row_tem = CorCoefVoxelZ_posionly[x, :]
    #     thre = np.max(row_tem) - 0.1*(np.max(row_tem) - np.min(row_tem))
    #     for y in range(1000):
    #         row_tem[row_tem < thre] = 0
    #     CorCoefVoxelZ_posionly[x, :] = row_tem
    #
    # np.savetxt(os.path.join(derRoot, subId, 'func', f'{subId}_task-rest_space-MNI152NLin6Asym_desc-zfc_positopten_atl-Schaefer2018_1000.txt'), CorCoefVoxelZ_posionly, delimiter='\t')

    # unlock
    os.renames(os.path.join(tmpRoot, f'{subId}.running'), os.path.join(tmpRoot, f'{subId}.finished'))

logging.info('Done.')