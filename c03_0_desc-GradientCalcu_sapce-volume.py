'''
 # @ Author: Feng Sang
 # @ Create Time: 2022-06-18 15:02:27
 # @ Modified by: Feng Sang, Shaokunzhao
 # @ Modified time: 2022-06-18 15:02:33
 # @ Description: Brain gradient.
 '''
import os
from glob import glob
import numpy as np
import nibabel as nib
from brainspace.gradient import GradientMaps
from brainspace.gradient import DiffusionMaps
import pandas as pd
import matplotlib.pyplot as plt
import logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s %(message)s')

derRoot = '/home/lenovo/Desktop/zhaoshaokun/Brain_Development_and_Aging/Data/aging/Preprocess/fmriprep'
rois_name = pd.read_csv('/home/lenovo/Desktop/zhaoshaokun/Brain_Development_and_Aging/Toolbox/GradiantCalcu/resource/Schaefer2018_1000Parcels_7Networks_order_FSLMNI152_2mm.Centroid_RAS.csv', header=0, index_col=0)

rois_name = rois_name['ROI Name'].values
n_components = 10

for i in glob(os.path.join(derRoot, 'sub-*')):
    subId = os.path.split(i)[-1]
    mat_path = os.path.join(derRoot, subId, 'func', f'{subId}_task-rest_space-MNI152NLin6Asym_desc-zfc_atl-Schaefer2018_1000.txt')
    if not os.path.exists(mat_path):
        print('no fun data in ', str(subId))
        continue

    logging.info(subId)
    func_mat = np.loadtxt(mat_path)

    # gradient fit
    gradient = GradientMaps(n_components=n_components, random_state=0, kernel='cosine', approach='dm')
    gradient.fit(func_mat)

    #plot lambda
    fig, ax = plt.subplots(1, figsize=(5, 4))
    ax.scatter(range(gradient.lambdas_.size), gradient.lambdas_)
    ax.set_xlabel('Component Num')
    ax.set_ylabel('Eigenvalue')
    plt.show()

    # save result
    np.savetxt(os.path.join(derRoot, subId, 'func', f'{subId}_task-rest_space-MNI152NLin6Asym_desc-gradient_raw_atl-Schaefer2018_1000.txt'), gradient.gradients_, delimiter='\t')
    np.savetxt(os.path.join(derRoot, subId, 'func', f'{subId}_task-rest_space-MNI152NLin6Asym_desc-gradient_lambdas_atl-Schaefer2018_1000.txt'), gradient.lambdas_, delimiter='\t')
logging.info('Done.')