caimg_rootdir = '/mnt/DATA/Audrey/ca_img_result/data/';
proc_dat_files = dir([caimg_rootdir '**/*/0*/*proc.mat']);
exp_names = {'Baseline', 'Ach', 'Atropine'};

for i = 1:numel(proc_dat_files)
    dat_file = proc_dat_files(i);
    load(fullfile(dat_file.folder, dat_file.name));
    disp(['Processing mouse: ', dat.ops.mouse_name]);
    
    %% Draw ROI
    cell_indecies = find([dat.stat.iscell] > 0);
    h = figure('Name', ['ROI_', dat.ops.mouse_name]);
    drawCells(dat, cell_indecies);
    saveas(gcf, ['figs' filesep 'roi' filesep dat.ops.mouse_name '.png']);
    close(h);
    
    %%  Create csv file
    dat.iscell = dat.stat.iscell;
    [T, E] = dat2table(dat, exp_names);
    df_data_path = [caimg_rootdir filesep 'dat_' dat.ops.mouse_name '.csv'];
    writetable(T, df_data_path);
    event_data_path = [caimg_rootdir filesep 'events_' dat.ops.mouse_name '.csv'];
    writetable(E, event_data_path);
    
    close all;
end


