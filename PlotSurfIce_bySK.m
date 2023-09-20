clc;clear;
% write ROI signal to MZ3 file
% dependent of https://github.com/neurolabusc/surfice_atlas
root = 'G:\Backup_ZSK\result\NC\Rest\mean_raw';
csvfile = 'Gradient_mean_55_60.csv';
atlas = 'G:\Backup_ZSK\Toolbox\04_Graph\c00_Create_background_forSchaefer1000p\Schaefer2018_1000Parcels_7Networks_order_FSLMNI152_2mm.mz3';

%load data and atlas
data =xlsread(fullfile(root, csvfile));
[faces, vertices, vertexColors, ~] = readMz3(atlas);


% for i = 1:numel(data(1,:))
for i = 1:1
    data_temp = data(:,i);
    colormap(jet(numel(data_temp)));
    range = [min(data_temp), max(data_temp)];

    normalized_data = (data_temp - range(1)) / (range(2) - range(1));
    normalized_data = max(0, min(1, normalized_data));

    color_index = round(normalized_data * (1000 - 1)) + 1;
    colormap_data = colormap;
    mapped_rgb = colormap_data(color_index, :);
    
    output = zeros(numel(vertexColors(:,1)),numel(vertexColors(1,:)));
    x = 1;
    for j = 1:numel(output(:,1))
        if j == numel(output(:,1))
            output(j, :) = mapped_rgb(x, :);
            break
        elseif vertexColors(j,1) == vertexColors(j+1,1) && ...
            vertexColors(j,2) == vertexColors(j+1,2) && ...
            vertexColors(j,3) == vertexColors(j+1,3)
            output(j, :) = mapped_rgb(x, :);        
        else
            output(j, :) = mapped_rgb(x, :);
            x = x + 1;            
        end
    end
    filename = fullfile(root,['Group_All_', csvfile(1:end-4),'-G',num2str(i),'.mz3']);
    writeMz3(filename, faces, vertices, output)
end
disp('DONE');
