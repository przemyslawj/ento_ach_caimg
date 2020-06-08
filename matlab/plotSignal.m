function [] = plotSignal(dF, eventsVec, thresholds, freq)

hold on;
yshift = 0;

timestamps = (1 : size(dF, 2)) / freq;

for i = 1 : size(dF, 1)
    
    cell_events = eventsVec(:, i);
    threshold = thresholds(i);
    event_timestamps = find(cell_events) / freq;
    trace = dF(i,:);
    plot(timestamps, trace /2 + yshift);
    
    %text(-30, yshift + 1, ...
    %    num2str(cell_indecies(i)));
    
    plot(event_timestamps, repmat(yshift+1, numel(event_timestamps), 1), 'r*',...
        'MarkerSize',3);
    plot(timestamps, repmat(threshold / 2 + yshift, 1, length(timestamps)), 'r--');
    
    yshift = yshift + 2;
    xlabel('Time (sec)');
    h = gca; 
    h.YAxis.Visible = 'off';
end

hold off;

end
