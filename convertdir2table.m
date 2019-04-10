caimg_rootdir = '/mnt/DATA/Audrey/ca_img_result/data/';
proc_dat_files = dir([caimg_rootdir '**/*/0_1*/*proc.mat']);

for i = 1:numel(proc_dat_files)
    dat_file = proc_dat_files(i);
    load(fullfile(dat_file.folder, dat_file.name));
    disp(['Processing mouse: ', dat.ops.mouse_name]);
    
    %% Draw ROI
    cell_indecies = find([dat.stat.iscell] > 0);
    figure('Name', ['ROI_', dat.ops.mouse_name]);
    drawCells(dat, cell_indecies);
    saveas(gcf, ['figs' filesep 'roi' filesep dat.ops.mouse_name '.png']);
    
    %%  Create csv file
    mouse_data_path = [caimg_rootdir filesep 'dat_' dat.ops.mouse_name '.csv'];
    T = dat2table(dat);
    writetable(T, mouse_data_path);
    
    close all;
end


