clearvars;
root = '/home/admin/Desktop/pre_fmri_new';
dicomRootPath = fullfile(root, '0.dicom');
niftiRootPath = fullfile(root, '1.nifti');
sliceTimingRootPath = fullfile(root, '2.slice_timing');
realignRootPath = fullfile(root, '3.realign');
coregisterRootPath = fullfile(root, '4.coregister');
normalizeRootPath = fullfile(root, '5.normalize');
smoothRootPath = fullfile(root, '6.smooth_6mm');

subs = dir(dicomRootPath);
subs = subs(3:end);
for i = 1:numel(subs)
%     % dicom to nifti
%     subPath = fullfile(dicomRootPath, subs(i).name);
%     modes = dir(subPath);
%     modes = modes(3:end);
%     for j = 1:numel(modes)
%         modePath = fullfile(subPath, modes(j).name);
%         niftiPath = fullfile(niftiRootPath, subs(i).name, modes(j).name);
%         mkdir(niftiPath);
%         spm_jobman('initcfg');
%         matlabbatch{1}.spm.util.import.dicom.data = cellfun(@(k)fullfile(modePath, k), cellstr(spm_select('list',[modePath, '/',],'.IMA')), 'UniformOutput', false);
%         matlabbatch{1}.spm.util.import.dicom.root = 'flat';
%         matlabbatch{1}.spm.util.import.dicom.outdir = {niftiPath};
%         matlabbatch{1}.spm.util.import.dicom.protfilter = '.*';
%         matlabbatch{1}.spm.util.import.dicom.convopts.format = 'nii';
%         matlabbatch{1}.spm.util.import.dicom.convopts.meta = 0;
%         matlabbatch{1}.spm.util.import.dicom.convopts.icedims = 0;
%         spm_jobman('run', matlabbatch);
%         clear matlabbatch;
%     end;
%     
%     
     % slice timing
     subPath = fullfile(niftiRootPath, subs(i).name);
     modes = dir(subPath);
     modes = modes(3:end);
     for j = 1:(numel(modes) - 1)
         modePath = fullfile(subPath, modes(j).name);
         
         niis = dir(modePath);
         niis = niis(3:end);
         data = cell(1, numel(niis));
         for k = 1:numel(niis)
             data{k} = strcat(fullfile(modePath, niis(k).name),',1');
         end;
         data = {data'};
         spm_jobman('initcfg');
         matlabbatch{1}.spm.temporal.st.scans = data';
         matlabbatch{1}.spm.temporal.st.nslices = 33;
         matlabbatch{1}.spm.temporal.st.tr = 2;
         matlabbatch{1}.spm.temporal.st.ta = 1.93939393939394;
         matlabbatch{1}.spm.temporal.st.so = [1 3 5 7 9 11 13 15 17 19 21 23 25 27 29 31 33 2 4 6 8 10 12 14 16 18 20 22 24 26 28 30 32];
         matlabbatch{1}.spm.temporal.st.refslice = 17;
         matlabbatch{1}.spm.temporal.st.prefix = 'a';
         spm_jobman('run', matlabbatch);
         clear matlabbatch;
         
         mkdir(fullfile(sliceTimingRootPath, subs(i).name, modes(j).name));
         movefile(fullfile(modePath, 'af*.nii'), fullfile(sliceTimingRootPath, subs(i).name, modes(j).name));
     end;
     
     % realign
     subPath = fullfile(sliceTimingRootPath, subs(i).name);
     modes = dir(subPath);
     modes = modes(3:end);
     for j = 1:numel(modes)
         modePath = fullfile(subPath, modes(j).name);
         
         niis = dir(modePath);
         niis = niis(3:end);
         data = cell(1, numel(niis));
         for k = 1:numel(niis)
             data{k} = strcat(fullfile(modePath, niis(k).name),',1');
         end;
         data = {data'};
         spm_jobman('initcfg');
         matlabbatch{1}.spm.spatial.realign.estwrite.data = data';
         matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.quality = 0.9;
         matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.sep = 4;
         matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.fwhm = 5;
         matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.rtm = 1;
         matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.interp = 2;
         matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.wrap = [0 0 0];
         matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.weight = '';
         matlabbatch{1}.spm.spatial.realign.estwrite.roptions.which = [2 1];
         matlabbatch{1}.spm.spatial.realign.estwrite.roptions.interp = 4;
         matlabbatch{1}.spm.spatial.realign.estwrite.roptions.wrap = [0 0 0];
         matlabbatch{1}.spm.spatial.realign.estwrite.roptions.mask = 1;
         matlabbatch{1}.spm.spatial.realign.estwrite.roptions.prefix = 'r';
         spm_jobman('run', matlabbatch);
         clear matlabbatch;
         
         mkdir(fullfile(realignRootPath, subs(i).name, modes(j).name));
         movefile(fullfile(modePath, 'raf*.nii'), fullfile(realignRootPath, subs(i).name, modes(j).name));
         movefile(fullfile(modePath, 'mean*.nii'), fullfile(realignRootPath, subs(i).name, modes(j).name));
         movefile(fullfile(modePath, 'rp_*.txt'), fullfile(realignRootPath, subs(i).name, modes(j).name));
     end;
     
     % coregister
     subPath = fullfile(realignRootPath, subs(i).name);
     modes = dir(subPath);
     modes = modes(3:end);
     for j = 1:numel(modes)
         modePath = fullfile(subPath, modes(end).name);
         niis = dir(modePath);
         niis = niis(3:end);
         ref = '';
         for k = 1:numel(niis)
             if regexp(niis(k).name, 'mean*') == 1
                 ref= niis(k).name;
                 break;
             end;
         end;
         ref = fullfile(modePath, ref);
         
         sModes = dir(fullfile(niftiRootPath, subs(i).name));
         sModes = sModes(3:end);
         sPath = fullfile(niftiRootPath, subs(i).name, sModes(numel(sModes)).name);
         sSubs = dir(sPath);
         sSubs = sSubs(3:end);
         source = '';
         for k = 1:numel(sSubs)
             if regexp(sSubs(k).name, 's*') == 1
                 source = sSubs(k).name;
                 break;
             end;
         end;
         source = fullfile(sPath, source);
         
         spm_jobman('initcfg');
         matlabbatch{1}.spm.spatial.coreg.estwrite.ref = {strcat(ref, ',1')};
         matlabbatch{1}.spm.spatial.coreg.estwrite.source = {strcat(source, ',1')};
         matlabbatch{1}.spm.spatial.coreg.estwrite.other = {''};
         matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.cost_fun = 'nmi';
         matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.sep = [4 2];
         matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
         matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.fwhm = [7 7];
         matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.interp = 4;
         matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.wrap = [0 0 0];
         matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.mask = 0;
         matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.prefix = 'r';
         
         spm_jobman('run', matlabbatch);
         clear matlabbatch;
         
         mkdir(fullfile(coregisterRootPath, subs(i).name, modes(j).name));
         movefile(fullfile(sPath, 'r*.nii'), fullfile(coregisterRootPath, subs(i).name, modes(j).name));
     end;
     
     % normalize
     subPath = fullfile(coregisterRootPath, subs(i).name);
     modes = dir(subPath);
     modes = modes(3:end);
     for j = 1:numel(modes)
         modePath = fullfile(subPath, modes(j).name);
         vols = dir(modePath);
         vols = vols(3:end);
         vol = ',1';
         for k = 1:numel(vols)
             if regexp(vols(k).name, 'rs*') == 1
                 vol = strcat(vols(k).name, vol);
                 break;
             end;
         end;
         vol = fullfile(modePath, vol);
         
         realignNiiPath = fullfile(realignRootPath, subs(i).name, modes(j).name);
         realignNiis = dir(realignNiiPath);
         realignNiis = realignNiis(3:end);
         resample = cell(1, numel(realignNiis) - 2);
         realignIndex = 1;
         for k = 1:numel(realignNiis)
             if regexp(realignNiis(k).name, 'raf*') == 1
                 resample{realignIndex} = strcat(fullfile(realignNiiPath, realignNiis(k).name), ',1');
                 realignIndex = realignIndex + 1;
             end;
         end;
         
         
         spm_jobman('initcfg');
         matlabbatch{1}.spm.spatial.normalise.estwrite.subj.vol = {vol};
         matlabbatch{1}.spm.spatial.normalise.estwrite.subj.resample = resample';
         matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.biasreg = 0.0001;
         matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.biasfwhm = 60;
         matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.tpm = {'/usr/local/MATLAB/R2016b/toolbox/spm12/tpm/TPM.nii'};
         matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.affreg = 'mni';
         matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.reg = [0 0.001 0.5 0.05 0.2];
         matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.fwhm = 0;
         matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.samp = 3;
         matlabbatch{1}.spm.spatial.normalise.estwrite.woptions.bb = [-90 -126 -72
             90 90 108];
         matlabbatch{1}.spm.spatial.normalise.estwrite.woptions.vox = [2 2 2];
         matlabbatch{1}.spm.spatial.normalise.estwrite.woptions.interp = 4;
         matlabbatch{1}.spm.spatial.normalise.estwrite.woptions.prefix = 'w';
         spm_jobman('run', matlabbatch);
         clear matlabbatch;
         
         
         mkdir(fullfile(normalizeRootPath, subs(i).name, modes(j).name));
         movefile(fullfile(realignNiiPath, 'w*.nii'), fullfile(normalizeRootPath, subs(i).name, modes(j).name));
         movefile(fullfile(modePath, 'y_rs*.nii'), fullfile(normalizeRootPath, subs(i).name, modes(j).name));
     end;
    
    % smooth
    subPath = fullfile(normalizeRootPath, subs(i).name);
    modes = dir(subPath);
    modes = modes(3:end);
    for j = 1:numel(modes)
        modePath = fullfile(subPath, modes(j).name);
        niis = dir(modePath);
        niis = niis(3:end);
        data = cell(1, numel(niis)-1);
        tmpIndex = 1;
        for k = 1:numel(niis)
            if regexp(niis(k).name, 'w*') == 1
                data{tmpIndex} = strcat(fullfile(modePath, niis(k).name),',1');
                tmpIndex = tmpIndex + 1; 
            end;
        end;
        spm_jobman('initcfg');
        matlabbatch{1}.spm.spatial.smooth.data = data';
        matlabbatch{1}.spm.spatial.smooth.fwhm = [6 6 6];
        matlabbatch{1}.spm.spatial.smooth.dtype = 0;
        matlabbatch{1}.spm.spatial.smooth.im = 0;
        matlabbatch{1}.spm.spatial.smooth.prefix = 's';
        spm_jobman('run', matlabbatch);
        clear matlabbatch;
        
        mkdir(fullfile(smoothRootPath, subs(i).name, modes(j).name));
        movefile(fullfile(modePath, 's*.nii'), fullfile(smoothRootPath, subs(i).name, modes(j).name));
    end;
end;
