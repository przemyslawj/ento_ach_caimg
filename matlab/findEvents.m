function [isEventVec, event_times, zscores, thresholds] = ...
    findEvents( dF, numStdsForThresh, freq, manuallyAdjust)
% Returns cell array with event times
% Event times are found using findpeak function. Only peaks higher than
% numStdsForThresh * std(signal) are found.

if nargin < 4
    manuallyAdjust = false;
end

minpeak_dF = 0.05;
maxpeak_dF = 1.0;

ncells = size(dF, 2);
thresholds = zeros(size(1, ncells));
isEventVec = zeros(size(dF), 'logical');
zscores = zeros(size(dF));
event_times = table();

stds = iqr(dF, 2) / 1.349;
%stds = std(dF, [], 2);

for i=1:ncells

    dY = dF(:,i);
    norm_trace = (dY - median(dY)) / stds(i);
    std_thr = max(numStdsForThresh, minpeak_dF / stds(i));
    std_thr = min(std_thr, maxpeak_dF / stds(i));

    cell_event_times = findCellEvents(norm_trace, std_thr, freq);
    if manuallyAdjust
        figName = ['Cell' num2str(i) ' out of ' num2str(ncells)];
        h = figure('Name', figName, 'Position', [100 800 1450 150]);
        reply = 'b';
        while ~strcmpi(reply,'a') % a = accept
            % recalculate and redraw
            clf(h);
            cell_event_times = findCellEvents(norm_trace, std_thr, freq);
            isEventVec(:,i) = zeros(size(dF,1), 1, 'logical');
            isEventVec(cell_event_times(:,1),i) = 1;
            plotSignal(dY', isEventVec(:,i), std_thr * stds(i), freq);
            
            waitforbuttonpress();
            reply=get(h, 'CurrentCharacter');
            if strcmpi(reply,'k') % k = move up
                std_thr = std_thr + 0.025;
            elseif strcmpi(reply, 'j') % j = move down
                std_thr = std_thr - 0.025;
            elseif strcmpi(reply, 'q')
                manuallyAdjust = false;
                reply = 'a';
            end
        end
        close(h)
    end
    thresholds(i) = std_thr * stds(i);
    
    if ~isempty(cell_event_times)
        cell_event_table = array2table(cell_event_times / freq,...
            'VariableNames', {'Peak_sec', 'Start_sec','End_sec'});
        peakTimes = cell_event_times(:,1);
        nevents = size(cell_event_table,1);
        cell_event_table.cell_id = repmat(i, nevents, 1);
        cell_event_table.threshold = repmat(thresholds(i), nevents, 1);
        cell_event_table.peak_zscore = norm_trace(peakTimes);
        isEventVec(peakTimes,i) = 1;
        cell_event_table.peak_df = dY(peakTimes);
        event_times = [event_times; cell_event_table];
    end

    zscores(:,i) = norm_trace;
end

end

function [cell_event_times] = findCellEvents(norm_trace, std_thr, freq)
    minpeakdistance = 2 * freq;
    [~, peakTimes] = findpeaks(norm_trace,...
        'minpeakheight', std_thr,...
        'minpeakdistance', minpeakdistance,...
        'minpeakprominence', 3,...
        'minpeakwidth', 1);

    thresholded = norm_trace > (std_thr / 3);
    cell_event_times = zeros(numel(peakTimes), 3);
    events_to_remove = [];
    prev_peak_i = -1;
    for peak_i = 1:numel(peakTimes)
        left_i = peakTimes(peak_i);
        while thresholded(left_i) > 0 && left_i > 1
            left_i = left_i - 1;
        end
        right_i = peakTimes(peak_i) + 1;
        while thresholded(right_i) > 0 && right_i < size(norm_trace,1)
            right_i = right_i + 1;
        end
        cell_event_times(peak_i,:) = [peakTimes(peak_i), left_i, right_i];

        % Remove smaller event if the previous event overlaps
        if prev_peak_i > 0 && cell_event_times(prev_peak_i, 3) > left_i
            if norm_trace(peakTimes(prev_peak_i)) > ...
                    norm_trace(peakTimes(peak_i))
                to_remove = peak_i;
            else
                to_remove = prev_peak_i;
                prev_peak_i = peak_i;
            end
            events_to_remove = [events_to_remove, to_remove];
        else
            prev_peak_i = peak_i;
        end
    end
    cell_event_times(events_to_remove,:) = [];
    peakTimes(events_to_remove) = [];
end
