function [] = plotSignal(dF, eventsVec, cell_indecies)

hold on;
yshift = 0;

freq = 3;
timestamps = (1 : size(dF, 2)) / freq;

for i = 1 : numel(cell_indecies)
    
    cell_events = eventsVec(:, i);
    event_timestamps = find(cell_events) / freq;
    trace = dF(cell_indecies(i),:);
    plot(timestamps, trace /2 + yshift);
    
    %text(-30, yshift + 1, ...
    %    num2str(cell_indecies(i)));
    
    plot(event_timestamps, repmat(yshift+1, numel(event_timestamps), 1), 'r*',...
        'MarkerSize',3);
    
    yshift = yshift + 2;
    xlabel('Time (sec)');
    h = gca; 
    h.YAxis.Visible = 'off';
end

hold off;

end
