clc; clear;
data = readtable("FA_globalmetrics.xlsx");
% 选择需要处理的列，删除其他列方便检查数据
data = data(:, ["JHTSCourseNew", "Lp"]);
data.x = data.JHTSCourseNew; data.y = data.Lp;
data = table2array(data);
data = sortrows(data, 1);
% divide windows
realigned_gradient_sort_age=data(:, 1:2); %6096*16 features, 39 subjects

win_length=5;
win_step=1;
for i= 1:1000
  if min(realigned_gradient_sort_age(:, 1))+win_length+(i-1)*win_step > max(realigned_gradient_sort_age(:, 1))
    break
  end
  gradient_window_flag = ((realigned_gradient_sort_age(:, 1) >= min(realigned_gradient_sort_age(:, 1))+(i-1)*win_step) & (realigned_gradient_sort_age(:, 1) < min(realigned_gradient_sort_age(:, 1))+win_length+(i-1)*win_step));
  gradient_window = realigned_gradient_sort_age(gradient_window_flag, :);
  % save(['gradient_window', mat2str(i)], 'gradient_window');
  gradient1_window(i) = mean(gradient_window(:, 2), 1);
  mean_age_window(i) = mean(gradient_window(:, 1), 1);
end
figure; plot(mean_age_window, gradient1_window, ...
    'LineStyle', '-', ...
    'Marker','.', ...
    'LineWidth', 1, ...
    'MarkerSize', 14);
