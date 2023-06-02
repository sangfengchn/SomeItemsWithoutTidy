clc; clear;
data = readtable("FA_globalmetrics.xlsx");
% 选择需要处理的列，删除其他列方便检查数据
data = data(:, ["JHTSCourseNew", "Lp"]);
data.x = data.JHTSCourseNew; data.y = data.Lp;
data = table2array(data);
data = sortrows(data, 1);
% divide windows
realigned_gradient_sort_age=data(:, 1:2); %6096*16 features, 39 subjects

win_length=100;
win_step=10;
for i= 1:1000
  if win_length+(i-1)*win_step > size(data, 1)
    break
  end
  gradient_window = realigned_gradient_sort_age(1+(i-1)*win_step:win_length+(i-1)*win_step, :);
  % save(['gradient_window', mat2str(i)], 'gradient_window');
  gradient1_window(i) = mean(gradient_window(:, 2), 1);
  mean_age_window(i) = mean(gradient_window(:, 1), 1);
end
figure; plot(mean_age_window, gradient1_window, ...
    'LineStyle', '-', ...
    'Marker','.', ...
    'LineWidth', 1, ...
    'MarkerSize', 14);
