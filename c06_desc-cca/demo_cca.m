clc; clear;

%% load data
data = readtable('alldata_1431_ymx_exclude_nan_residulas.xlsx');
% remove nan in diseases
data = data(~isnan(data.diseases), :);
% healthy
data = data(data.diseases == 5, :);
% diseases
% dadta = data(data.diseases ~= 5, :);

actData = table2array(data(:, 8:15));
fcData = table2array(data(:, 16:71));
graData = table2array(data(:, 72:89));
dawData = table2array(data(:, 90:158));

X1_resi = [actData fcData graData];
X2 = dawData;
X1_resi = (X1_resi - mean(X1_resi)) ./ std(X1_resi); X2 = (X2 - mean(X2)) ./ std(X2);
perm_n = 5000;

%% CCA
[A, B, r, U, V, stats] = canoncorr(X1_resi, X2);
rand("seed", 123);
for i = 1:perm_n
    PeX=randperm(size(X1_resi,1));
%     PeY=randperm(size(Y,1));
    [~, ~, permr, ~, ~, ~] = canoncorr(X1_resi(PeX, :), X2);
    cca_rdist(i) = max(permr);
end
% stats.perm_r_level95=prctile(sort(rdist),95);
for i=1:length(r)
    cca_perm_p(1,i) = sum([cca_rdist, r(i)] > r(i)) / (perm_n + 1);
end

%% SCCA
niter = 1000;
Spar1 = 1; Spar2 = 1;
w1_sign = 0; w2_sign = 1;
[c, c1, c2, w1, w2] = SCCA_SCCA(X1_resi, X2, Spar1, Spar2, niter, w1_sign, w2_sign);
%permutation test
rand("seed", 123);
for i = 1:perm_n
    PeX = randperm(size(X1_resi, 1));
    [permc, ~, ~, ~, ~] = SCCA_SCCA(X1_resi(PeX, :), X2, Spar1, Spar2, niter, w1_sign, w2_sign);
    scca_rdist(i) = permc;
end
scca_perm_p = sum([scca_rdist, c] > c) / (perm_n + 1);

%% mSCCA
Spar1 = 1; Spar2 = 1; Spar3 = 1; Spar4 = 1;
w1_sign = 0; w2_sign = 0; w3_sign = 0; w4_sign = 1;
niter = 10000;
rand("seed", 123);
[c_arr, w_arr, Corr_mat] = mSCCA_reg_wconstraint({X1_resi(:, 1:8), X1_resi(:, 9:64), X1_resi(:, 65:82), X2}, [Spar1 Spar2 Spar3 Spar4], [w1_sign w2_sign w3_sign w4_sign], niter);
% permutation test
rand("seed", 123);
mS_rdist = zeros([4, 4, perm_n + 1]);
for i = 1:perm_n
    PeX = randperm(size(X1_resi,1));
    [~, ~, permCorr_mat] = mSCCA_reg_wconstraint({X1_resi(PeX, 1:8), X1_resi(PeX, 9:64), X1_resi(PeX, 65:82), X2}, [Spar1 Spar2 Spar3 Spar4], [w1_sign w2_sign w3_sign w4_sign], niter);
    mS_rdist(:, :, i) = permCorr_mat;
end
mS_rdist(:, :, i + 1) = Corr_mat;
mscca_perm_p = sum(mS_rdist > Corr_mat, 3) / (perm_n + 1);