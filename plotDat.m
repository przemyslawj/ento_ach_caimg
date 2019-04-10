figure;

exp_id = 1;

cell_indecies = find([dat.stat.iscell] > 0);
%cell_indecies = cell_indecies(40:60);

F0 = mean(dat.Fcell{1,1}, 2);
F = dat.Fcell{1,exp_id};
dF=smootheddFOverF(F);
%dF = (F - F0) ./ F0;

stds = std(dF, [], 2);
[eventsVec, ~] = findEvents(dF(cell_indecies, :)', stds(cell_indecies), 5, 3);


plotSignal(dF, eventsVec, cell_indecies);
r=150;
set(gcf, 'PaperUnits', 'inches', 'PaperPosition', [0 0 5000 3000]/r);
print(gcf,'-dpng',sprintf('-r%d',r), 'bar.png');

figure;
drawCells(dat, cell_indecies)
