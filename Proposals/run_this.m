close all
counts = smooth(normalize(yearlyWeather)+1);
edges = linspace(-pi,pi,numel(counts));
colors = jet(numel(counts));
colorLookup = linspace(1,2,size(colors,1));
for ii = 1:numel(counts)
%     ct = zeros(size(counts));
%     ct(ii) = counts(ii);
    colorId = closest(colorLookup,counts(ii));
%     h = polarhistogram('BinEdges',edges,'BinCounts',ct,...
%         'FaceColor',colors(colorId,:),'EdgeColor','none','FaceAlpha',0.5);
    polarplot([edges(ii) edges(ii)],[1 counts(ii)],'-','Color',colors(colorId,:),...
        'MarkerSize',15,'LineWidth',2);
    hold on;
end