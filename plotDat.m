figure;

exp_id = 1;
freq = 3;

cell_indecies = find([dat.stat.iscell] > 0);
F1 = dat.Fcell{1,1};
F1 = F1(cell_indecies, :);

F0 = mean(F1, 2);
F = dat.Fcell{1,exp_id};
F = F(cell_indecies, :);

dF = smootheddFOverF(F);
%dF = (F - F0) ./ F0;

std_thr = 4;
[eventsVec, event_times, zscores, thresholds] = findEvents(dF', std_thr, freq, false);


plotSignal(dF, eventsVec, thresholds, freq);
r=150;
set(gcf, 'PaperUnits', 'inches', 'PaperPosition', [0 0 5000 3000]/r);
print(gcf,'-dpng',sprintf('-r%d',r), 'bar.png');

%labeledCells = [7, 13, 25, 34, 40, 48, 54, 59, 68, 72, 85, 62];
%labeledCells = [24, 29, 31, 47, 55, 65, 146, 84, 63, 89];
labeledCells = [146, 84, 63];
drawCells(dat, cell_indecies, labeledCells)
