doSave = true;
% [sunYear,sunYearAvg,sunMonth,sunHeader,monthNames] = getSunData(1:12);
monthNames = {'JAN','FEB','MAR','APR','MAY','JUN','JUL','AUG','SEP','OCT','NOV','DEC'};
colors = mycmap('/Users/matt/Box Sync/Biologging/Software/daynight_cmap.png',24*60); % 1440s

close all;
rows = 4;
cols = 3;
h1 = ff(600,900);
for iMonth = 1:12
    subplot(rows, cols, iMonth);
    
    edges = linspace(-pi,pi,13);
    counts = ones(1,12);
    h = polarhistogram('BinEdges',edges,'BinCounts',counts,...
        'FaceColor','k','LineWidth',0.25,'FaceAlpha',0.7);
    h.EdgeColor = 'none';
    hold on;
    
    sunrise = sunMonth{1,iMonth}(1,2);
    sunset = sunMonth{1,iMonth}(1,3);
    counts = zeros(1,size(colors,1));
    counts(sunrise:sunset) = 1;
    edges = linspace(0,2*pi,numel(counts)+1);
    h = polarhistogram('BinEdges',edges,'BinCounts',counts,...
        'FaceAlpha',1,'FaceColor',sunColor,'EdgeColor','none');
    
    edges = linspace(0,2*pi,size(sleepFracData,2)+1);
    counts = sleepFracData(iMonth,:);
    if any(isnan(counts))
        counts = zeros(size(counts));
    end
    h = polarhistogram('BinEdges',edges,'BinCounts',counts,...
        'FaceColor','none','LineWidth',1.5,'FaceAlpha',0.5);
    h.DisplayStyle = 'stairs';
    h.EdgeColor = 'w';
    
    pax = gca;
    pax.ThetaZeroLocation = 'top';
    pax.ThetaDir = 'clockwise';
    pax.FontSize = 16;
    pax.Layer = 'top';
    rlim([0 1]);
    rticks([]);
    pax.Color = [1 1 1];
    % rticklabels({'','',''});
    fontSize = 16;
    pax.ThetaTick = linspace(0,360,5);
    pax.ThetaTickLabels = compose('%i',[0,6,12,18]);
    
    if iMonth == 2
        title({'Sleep + Sunrise/Sunset','',monthNames{iMonth}});
    else
        title(monthNames{iMonth});
    end
    if sum(counts) == 0
        text(0,0,'No Data','FontSize',fontSize,'Color','k','HorizontalAlignment','center');
    end
end

if doSave
    saveas(h1,'/Users/matt/Desktop/squirrel-day-with-sun.png');
end