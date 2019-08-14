function [result_table, result_events] = dat2table(dat)

manuallyAdjust = true;
cell_indecies = find([dat.stat.iscell] > 0);
result_table = table();
result_events = table();
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
    freq = get_frame_rate(dat.ops.mouse_name);
    [eventsVec, ~, ~, thresholds] = findEvents(dF(cell_indecies,:)', 4, freq);
    events_table = array2table(eventsVec);
    events_table.Properties.VariableNames = ...
        arrayfun(@(x) ['Event_' num2str(x)], (cell_indecies)', 'UniformOutput', false);
    
    figName = [dat.ops.mouse_name '_' exp_names{exp}];
    h1 = figure('Name', ['dF_', figName]);
    plotSignal(dF(cell_indecies,:), eventsVec, thresholds, freq);
    printPng(['figs' filesep 'dF' filesep figName '.png']);
    saveas(gcf, ['figs' filesep 'dF' filesep 'fig' filesep figName '.fig']);
    
    [eventsVec, event_table, ~, thresholds] = findEvents(smootheddF(cell_indecies,:)', 1, freq, manuallyAdjust);
    sevents_table = array2table(eventsVec);
    sevents_table.Properties.VariableNames = ...
        arrayfun(@(x) ['SEvent_' num2str(x)], (cell_indecies)', 'UniformOutput', false);
    
    h2 = figure('Name', ['smoothed_', figName]);
    plotSignal(smootheddF(cell_indecies,:), eventsVec, thresholds, freq);
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
    
    nevents = size(event_table, 1);
    event_table.date = repmat({dat.ops.date}, nevents,1);
    event_table.animal = repmat({dat.ops.mouse_name}, nevents, 1);
    event_table.exp = repmat(exp_names(exp), nevents, 1);
    
    result_events = [result_events; event_table];
    %close(h1);
    %close(h2);
end

end

function [] = printPng(filepath)
    r=150;
    set(gcf, 'PaperUnits', 'inches', 'PaperPosition', [0 0 5000 3000]/r);
    print(gcf,'-dpng',sprintf('-r%d',r), filepath);
end
