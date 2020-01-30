% [sunYear,sunYearAvg,sunMonth,sunHeader,monthNames] = getSunData(1:12);
% [squirrelArr,dailyMean,dailyStd,squirrelHeader] = getSquirrelData();
% yearlyWeather = getWeatherData();

colors = lines(8);
sunColor = colors(3,:);
accelColor = [0 0 0]; %colors(5,:);
mutedYl = [0.55 0.43 0.13];
linewidth = 2;
rows = 1;
cols = 2;
close all;
ff(800,800);
plotOrder = [2,7,6];
plotTitles = {'Sum Acceleration','Sleep','Not Moving (out of nest)'}; %2,7,6

% shade
edges = linspace(-pi,pi,13);
counts = ones(1,12);
h = polarhistogram('BinEdges',edges,'BinCounts',counts,...
    'FaceColor',zeros([1,3]),'LineWidth',0.25,'FaceAlpha',0.8);
h.EdgeColor = 'none';

hold on;

% sun
edges = linspace(-pi,pi,size(sunYear,1)+1);
counts = sunYear(:,4) / 60 / 24;
h = polarhistogram('BinEdges',edges,'BinCounts',counts,...
    'FaceAlpha',1,'FaceColor',sunColor,'EdgeColor','none');

iBehavior = 7; % sleep
edges = linspace(-pi,pi,size(dailyMean,1)+1);
counts = fillmissing(dailyMean(:,iBehavior),'linear') / 86400;
h = polarhistogram('BinEdges',edges,'BinCounts',counts,...
    'FaceColor','none','LineWidth',linewidth);
h.DisplayStyle = 'stairs';
h.EdgeColor = 'k';

iBehavior = 6; % out of nest, not moving
edges = linspace(-pi,pi,size(dailyMean,1)+1);
counts = fillmissing(dailyMean(:,iBehavior),'linear') / 86400;
h = polarhistogram('BinEdges',edges,'BinCounts',counts,...
    'FaceColor','none','LineWidth',linewidth);
h.DisplayStyle = 'stairs';
h.EdgeColor = mutedYl;

counts = smooth(normalize(yearlyWeather)+1);
edges = linspace(-pi,pi,numel(counts));
colors = parula(numel(counts));
colorLookup = linspace(1,2,size(colors,1));
for ii = 1:numel(counts)
%     ct = zeros(size(counts));
%     ct(ii) = counts(ii);
    colorId = closest(colorLookup,counts(ii));
%     h = polarhistogram('BinEdges',edges,'BinCounts',ct,...
%         'FaceColor',colors(colorId,:),'EdgeColor','none','FaceAlpha',0.5);
    polarplot([edges(ii) edges(ii)],[1 counts(ii)],'-','Color',colors(colorId,:),...
        'MarkerSize',15,'LineWidth',1);
    hold on;
end

iBehavior = 2; % accel
edges = linspace(-pi,pi,size(dailyMean,1)+1);
counts = normalize(inpaint_nans(dailyMean(:,iBehavior),4)) + 1;
h = polarhistogram('BinEdges',edges,'BinCounts',counts,...
    'FaceColor',accelColor,'LineWidth',linewidth,'FaceAlpha',0.25);
h.DisplayStyle = 'stairs';
h.EdgeColor = accelColor;

h = polarplot(edges,ones(size(edges))*1.5); 
h.Color = repmat(0.75,[1,3]);
h.LineStyle = ':';

% black border at r=1
h = polarplot(edges,ones(size(edges))); 
h.Color = 'k';

pax = gca;
pax.ThetaZeroLocation = 'bottom';
pax.ThetaDir = 'clockwise';
pax.FontSize = 20;
pax.Layer = 'top';
rlim([0 2]);
rticks([]);
pax.Color = [1 1 1];
% rticklabels({'','',''});
text(pi/2,1,'24 hrs \rightarrow','FontSize',16,'Color','k','HorizontalAlignment','right');
text(-pi/2,1.5,'\leftarrow 0°C','FontSize',16,'Color','k','color','k');
text(0.7,1.6,'daily g-force','FontSize',16,'Color',accelColor);
text(2.7,0.6,'sleep','FontSize',16,'Color','k');
text(6,0.15,'naps','FontSize',16,'Color',mutedYl);
thetaticklabels(circshift(monthNames,6));
title('Daily Activity')
