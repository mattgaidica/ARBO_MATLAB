[type,data,labels] = extractNAND('/Users/matt/Downloads/ESLO_20210226_122311.txt');



close all
ff(1000,600);
subplot(211);
for ii = 7:9
    plot(data(type==ii));
    disp(numel(data(type==ii)));
    hold on;
end

subplot(212);
for ii = 10:12
    plot(data(type==ii));
    disp(numel(data(type==ii)));
    hold on;
end

%%
close all
h = ff(600,600);
heading = atan2(double(data(type==11)),double(data(type==10)));
heading = unwrap(heading);
heading = smoothdata(heading,'movmean',20);
heading = (180/pi) * heading + 180;
heading = mod(heading,360);

[u,v] = pol2cart(deg2rad(heading),linspace(0.2,1,numel(heading)));
c = compass(u,v);

colors = jet(numel(heading));
for ii = 1:numel(heading)
%     polarplot(deg2rad(heading(ii)),ii,'.','color',colors(ii,:),'markersize',15);
%     hold on;
    c(ii).Color = [colors(ii,:),.5];
    c(ii).LineWidth = 2;
end
set(gca,'fontsize',16);
title('Walking direction over time');
cb = colorbar('location','southoutside');
colormap(jet);
cb.Ticks = cb.Limits;
cb.TickLabels = {'Start','Finish'};