clc; clear;

% 添加toolbox
addpath("matlib-master");
% 输入文件
data = readtable("FA_globalmetrics.xlsx");
% 选择需要处理的列，删除其他列方便检查数据
data = data(:, ["JHTSCourseNew", "smallworld"]);
data.x = data.JHTSCourseNew; data.y = data.smallworld;
[Xb, Yb, p, t, h, resid] = conditionalPlot(data.x, data.y, 50, 'standardbinning', true);
% [Xb, Yb, p, t, h, resid] = conditionalPlot(data.x, data.y, 5, 'standardbinning', false);
% [Xb, Yb, p, t, h, resid] = conditionalPlot(data.x, data.y, 10, 'Smooth', 10, 'standardbinning', false);
