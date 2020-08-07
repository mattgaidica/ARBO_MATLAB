sleepFracData = getDailySquirrelData();
doSave = false;
colors = [cool(6);flip(cool(6))];
% colors = mycmap('/Users/matt/Box Sync/Biologging/Software/daynight_cmap.png',12);
monthNames = {'JAN','FEB','MAR','APR','MAY','JUN','JUL','AUG','SEP','OCT','NOV','DEC'};
close all;
h1 = ff(400,400);
edges = linspace(0,2*pi,size(sleepFracData,2)+1);
for iMonth = 1:12
    counts = sleepFracData(iMonth,:);
    if any(isnan(counts))
        continue;
    end
    h = polarhistogram('BinEdges',edges,'BinCounts',counts,...
        'FaceColor','none','LineWidth',1.5,'FaceAlpha',0.5);
        h.DisplayStyle = 'stairs';
        h.EdgeColor = colors(iMonth,:);
    hold on;
end

c = colorbar('eastoutside');
c.Ticks = linspace(0,1,13)+(1/13/2);
c.TickLabels = flip(monthNames);
colormap(colors);

pax = gca;
pax.ThetaZeroLocation = 'top';
pax.ThetaDir = 'clockwise';
pax.FontSize = 20;
pax.Layer = 'top';
rlim([0 1]);
rticks([]);
pax.Color = [1 1 1];
% rticklabels({'','',''});
fontSize = 16;

pax.ThetaTick = linspace(0,360,25);
pax.ThetaTickLabels = compose('%i',[0:23]);

text(pi,1,{'100%','\downarrow'},'FontSize',fontSize,'Color',repmat(0.5,[1,3]),...
    'verticalAlignment','bottom','HorizontalAlignment','center');
text(pi/8,1.25,['0',char(8211),'24 Hours'],'FontSize',fontSize,'Color',repmat(0.5,[1,3]),...
    'horizontalAlignment','left');

title('Hourly Sleep');

if doSave
    saveas(h1,'/Users/matt/Desktop/squirrel-day.png');
end