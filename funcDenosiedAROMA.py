'''
 # @ Author: Feng Sang
 # @ Create Time: 2022-06-16 13:21:03
 # @ Modified by: Feng Sang
 # @ Modified time: 2022-06-16 13:21:28
 # @ Description: 保存经过ICA-AROMA（因为这个文件本身就去掉了ICA-AROMA的信号）和其他无关变量（load_confounds中的ica_aroma，包括线性漂移、白质-脑脊液信号）。
 '''

import os
import glob
import nibabel as nib
from nilearn import image
from nilearn.interfaces.fmriprep import load_confounds_strategy
import logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s %(message)s')

derRoot = '/brain/babri_in/sangf/Data/D_desc-babri/toLZL/fmriprep'
timeRemoved = 10
lowPass = 0.08
highPass = 0.009
tr = 2

for i in glob.glob(os.path.join(derRoot, "sub-*", "func", "*space-MNI152NLin6Asym_desc-smoothAROMAnonaggr_bold.nii.gz")):

    if (os.path.exists(i.replace(".nii.gz", ".denosied.log")) or
        os.path.exists(i.replace("desc-smoothAROMAnonaggr", "desc-denosied"))):
        continue
    with open(i.replace(".nii.gz", ".denosied.log"), "w") as f: f.writelines("")

    tmpImgPath = os.path.split(i)[-1]
    subId = tmpImgPath.split("_")[0]
    logging.info(i)
    tmpConfound, tmpSampleMask = load_confounds_strategy(
            img_files=i,
            denoise_strategy='ica_aroma')
    tmpData = nib.load(i)
    tmpTotalTime = tmpData.shape[-1]

    if tmpTotalTime == 240:
        tmpData = image.index_img(tmpData, slice(timeRemoved, tmpTotalTime))
        tmpConfound = tmpConfound.tail(tmpTotalTime - timeRemoved)
        tmpDataDenoised = image.clean_img(tmpData, confounds = tmpConfound, detrend = False, standardize = False, low_pass = lowPass, high_pass = highPass, t_r = tr)
    elif tmpTotalTime == 230:
        tmpDataDenoised = image.clean_img(tmpData, confounds = tmpConfound, detrend = False, standardize = False, low_pass = lowPass, high_pass = highPass, t_r = tr)
    else:
        logging.info('ERROR: TIME SERIES IS ' + str(tmpTotalTime))
        continue
    nib.save(tmpDataDenoised, os.path.join(i.replace('smoothAROMAnonaggr', 'denosied')))

logging.info("Done.")
