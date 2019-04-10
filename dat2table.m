function [result_table] = dat2table(dat)

cell_indecies = find([dat.stat.iscell] > 0);
result_table = table();
exp_names = {'Baseline', 'Ach', 'Atropine'};
for exp = 1:size(dat.Fcell, 2)
    F = dat.Fcell{1,exp};
    
    %% Create dF and tables
    F1 = dat.Fcell{1,1};
    F0 = mean(F1, 2);
    dF = (F - F0) ./ F0;

    trace_table = array2table(dF(cell_indecies,:)');
    trace_table.Properties.VariableNames = ...
        arrayfun(@(x) ['Trace_' num2str(x)], (cell_indecies)', 'UniformOutput', false);
    
    smootheddF = smootheddFOverF(F);
    smoothed_trace_table = array2table(smootheddF(cell_indecies,:)');
    smoothed_trace_table.Properties.VariableNames = ...
        arrayfun(@(x) ['STrace_' num2str(x)], (cell_indecies)', 'UniformOutput', false);
    
    %% Detect events and create table
    stds = std((F1 - F0) ./ F0, [], 2);
    [eventsVec, ~] = findEvents(dF(cell_indecies,:)', stds(cell_indecies), 4, 3);
    events_table = array2table(eventsVec);
    events_table.Properties.VariableNames = ...
        arrayfun(@(x) ['Event_' num2str(x)], (cell_indecies)', 'UniformOutput', false);
    
    figName = [dat.ops.mouse_name '_' exp_names{exp}];
    figure('Name', ['dF_', figName]);
    plotSignal(dF, eventsVec, cell_indecies);
    printPng(['figs' filesep 'dF' filesep figName '.png']);
    saveas(gcf, ['figs' filesep 'dF' filesep 'fig' filesep figName '.fig']);
    
    stds = std(smootheddF, [], 2);
    [eventsVec, ~] = findEvents(smootheddF(cell_indecies,:)', stds(cell_indecies), 4, 3);
    sevents_table = array2table(eventsVec);
    sevents_table.Properties.VariableNames = ...
        arrayfun(@(x) ['SEvent_' num2str(x)], (cell_indecies)', 'UniformOutput', false);
    
    figure('Name', ['smoothed_', figName]);
    plotSignal(smootheddF, eventsVec, cell_indecies);
    printPng(['figs' filesep 'smoothed' filesep figName '.png']);
    saveas(gcf, ['figs' filesep 'smoothed' filesep 'fig' filesep figName '.fig']);
    
    %% Create table cointaining joined results
    exp_table = [trace_table smoothed_trace_table events_table sevents_table];
    
    frames = size(F, 2);
    exp_table.frame = (1:frames)';
    exp_table.date = repmat({dat.ops.date}, frames, 1);
    exp_table.animal = repmat({dat.ops.mouse_name}, frames, 1);
    exp_table.exp = repmat(exp_names(exp), frames, 1);

    if isempty(result_table)
        result_table = exp_table;
    else
        result_table = [result_table; exp_table];
    end
end

end

function [] = printPng(filepath)
    r=150;
    set(gcf, 'PaperUnits', 'inches', 'PaperPosition', [0 0 5000 3000]/r);
    print(gcf,'-dpng',sprintf('-r%d',r), filepath);
end
