% convert_dir2table.py adapted to read suite2p python implementation output
%caimg_rootdir = '/mnt/DATA/Audrey/ca_img_result/data/';
caimg_rootdir = '/mnt/DATA/Audrey/ca_img_sim/20200618/';
%proc_dat_files = dir([caimg_rootdir '**/*/0*/*proc.mat']);
proc_dat_files = dir([caimg_rootdir '**/interleaved/suite2p/plane0/Fall.mat']);

for i = 1:numel(proc_dat_files)
    load([proc_dat_files(i).folder '/' proc_dat_files(i).name]);
    dat_file = proc_dat_files(i);
    load(fullfile(dat_file.folder, dat_file.name));
    file_parts = strsplit(dat_file.folder, '/');
    dat = struct();

    exp_last_frames = cumsum(ops.frames_per_file)';
    exp_first_frames = [1; exp_last_frames(1:end-1) + 1];
    nexps = size(ops.filelist,1);
    exp_names = cell(1, nexps);
    Fcell = cell(1, nexps);
    FcellNeu = cell(1, nexps);
    for file_i = 1:nexps
        exp_name = 'Baseline';
        [~ , fname, ext] = fileparts(ops.filelist(file_i,:));
        if contains(fname, 'ACh', 'IgnoreCase', true)
           exp_name = 'ACh';
        elseif contains(fname, 'Firing', 'IgnoreCase', true)
            exp_name = 'Firing';
        end
        exp_names{file_i} = exp_name;
        Fcell{1,file_i} = F(:, exp_first_frames(file_i) : exp_last_frames(file_i));
        FcellNeu{1,file_i} = Fneu(:, exp_first_frames(file_i) : exp_last_frames(file_i));
    end

    dat.Fcell = Fcell;
    dat.FcellNeu = FcellNeu;
    dat.ops = ops;
    dat.ops.mouse_name = file_parts{end-3};
    dat.stat = cell2mat(stat);
    dat.iscell = iscell(:,1);
    disp(['Processing dir: ', dat.ops.mouse_name]);

    %% Draw ROI
    cell_indecies = find([dat.iscell] > 0);
    dat.ops.mimg1 = ops.meanImg;
    h = figure('Name', ['ROI_', dat.ops.mouse_name],...
               'Position', [100, 100, 400, 400]);
    drawCells(dat, cell_indecies, [1, 10, 16,19, 23, 6,8]);
    axis off;
    saveas(gcf, ['figs' filesep 'roi' filesep dat.ops.mouse_name '.png']);
    close(h);

    %%  Create csv file
    [T, E] = dat2table(dat, exp_names);
    df_data_path = [caimg_rootdir filesep 'dat_' dat.ops.mouse_name '.csv'];
    writetable(T, df_data_path);
    event_data_path = [caimg_rootdir filesep 'events_' dat.ops.mouse_name '.csv'];
    writetable(E, event_data_path);

    close all;
end

