% Script extracting xy coordinates of the cells found by Suite2P. The output
% is saved in a coord.csv.

caimg_rootdir = '/mnt/DATA/Audrey/ca_img_result/data_to_process/';
proc_dat_files = dir([caimg_rootdir '**/*/0_1*/*proc.mat']);

result_table = table();
for i = 1:numel(proc_dat_files)
    dat_file = proc_dat_files(i);
    load(fullfile(dat_file.folder, dat_file.name));
    disp(['Processing mouse: ', dat.ops.mouse_name]);

    cells = dat.stat;
    cell_indecies = find([dat.stat.iscell] > 0);
    coords = vertcat(cells(cell_indecies).med);
    coords_table = array2table([cell_indecies' int32(coords)]);
    coords_table.Properties.VariableNames = {...
        'cell', 'x', 'y'};
    coords_table.animal = repmat({dat.ops.mouse_name}, size(coords, 1), 1);
    result_table = [result_table; coords_table];
end

result_path = [caimg_rootdir filesep 'coords.csv'];
writetable(result_table, result_path);
