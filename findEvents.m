function [eventVec, normApt] = findEvents( sessionTraces, stds, numStdsForThresh, freq)
% Returns cell array with event times
% Event times are found using findpeak function. Only peaks higher than
% numStdsForThresh * std(signal) are found.
    minpeakdistance = 2 * freq;
    
    ncells = size(sessionTraces, 2);
    eventVec = zeros(size(sessionTraces), 'logical');
    normApt = zeros(size(eventVec));
    for i=1:ncells
        trace = sessionTraces(:,i);

        norm_trace = trace / stds(i);

        [~, peakTimes] = findpeaks(norm_trace,...
            'minpeakheight', numStdsForThresh,...
            'minpeakdistance',minpeakdistance,...
            'minpeakprominence', 4,...
            'minpeakwidth', 1);
        eventIndecies = intersect(find(trace > 0.2), peakTimes);
        eventVec(eventIndecies,i) = 1;
        normApt(:,i) = norm_trace;
    end
    
end
