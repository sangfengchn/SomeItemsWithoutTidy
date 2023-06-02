clc; clear;

% 添加toolbox
addpath("matlib-master");

% 输入文件
data = readtable("FA_globalmetrics.xlsx");
% 选择需要处理的列，删除其他列方便检查数据
data = data(:, ["JHTSCourseNew", "Lp"]);
data.group = ones(size(data, 1), 1);
% 对病程分组
data.group(data.JHTSCourseNew <= 5) = 1;
data.group((data.JHTSCourseNew > 5) & (data.JHTSCourseNew <= 10)) = 2;
data.group((data.JHTSCourseNew > 10) & (data.JHTSCourseNew <= 15)) = 3;
data.group((data.JHTSCourseNew > 15) & (data.JHTSCourseNew <= 20)) = 4;
data.group(data.JHTSCourseNew > 20) = 5;
% 重命名变量
data.x = data.JHTSCourseNew; data.y = data.Lp;

labels = unique(data.group);
% 重采样次数
numResample = 200;

subX = []; subY = [];
for idxResample = 1:numResample
    subData = table();
    for idxLabel = 1:numel(labels)
        label = labels(idxLabel);
        tmpData = data(data.group == label, :);
        % 无放回重采样
        [tmpSamData, tmpSamIdx] = datasample(tmpData, 90, 'Replace', false);
        subData = [subData; tmpSamData];
    end
    [Xb, Yb, p, t, h, resid] = conditionalPlot(subData.x, subData.y, 10, 'Smooth', 10);
    subX = [subX, sq(Xb)];
    subY = [subY, sq(Yb)];
end
Xb = nanmean(subX, 2);
Yb = nanmean(subY, 2);
Xb(isnan(Yb)) = [];
Yb(isnan(Yb)) = [];
figure; plot(Xb, Yb, ...
    'LineStyle', '-', ...
    'Marker','.', ...
    'LineWidth', 1, ...
    'MarkerSize', 14);
