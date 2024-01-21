clc; clear all;

SPMROOT = '~/Tools/spm12';
addpath(SPMROOT);
proj = '.';
srcPath = fullfile(proj, 'FunImgARCFWS');
srcPrefix = 'swFiltered_4DVolume.nii';
dstPath = fullfile(proj, 'Results', 'sf_Correlation_FunImgARCFWS');
if ~isdir(dstPath)
    mkdir(dstPath);
end
datAtl = spm_read_vols(spm_vol('BN_Atlas_246_3mm.nii'));
numRegions = 246;


subs = dir(fullfile(srcPath, 'sub-*'));
for subIdx = 1:length(subs)
    disp(sprintf('preprocessing %s', subs(subIdx).name));
    subDat = spm_read_vols(spm_vol(fullfile(subs(subIdx).folder, subs(subIdx).name, srcPrefix)));
    numTimes = size(subDat, 4);

    subMeanSingle = zeros([numTimes, numRegions]);
    for tmpIdx = 1:numRegions
        % tmpIdx = 1;
        tmpAtlMask = zeros(size(datAtl));
        tmpAtlMask(datAtl == tmpIdx) = 1;
        tmpAtlIdxSum = sum(tmpAtlMask(:));
        
        tmpAtlDat = subDat .* tmpAtlMask;
        tmpIdxSum = sum(sum(sum(tmpAtlDat, 1), 2), 3);
        tmpIdxSum = tmpIdxSum(:);
        tmpIdxMean = tmpIdxSum ./ tmpAtlIdxSum;
        subMeanSingle(:, tmpIdx) = tmpIdxMean;
    end
    subCorR = corrcoef(subMeanSingle);
    subCorZ = log((1 + subCorR) ./ (1 - subCorR)) ./ 2;
    writematrix(subCorR, fullfile(subs(subIdx).folder, sprintf('CorR_%s.txt', subs(subIdx).name)), "Delimiter", '\t');
    writematrix(subCorZ, fullfile(subs(subIdx).folder, sprintf('CorZ_%s.txt', subs(subIdx).name)), "Delimiter", '\t'); 
end
disp('Done.');
