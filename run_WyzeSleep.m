rootPath = '/Volumes/Seagate Expansion Drive/Gaidica/Database/0009/record';
files = dir2(filepath,'*.mp4','-r');
startName = '20210918/18/11.mp4';
endName = '20210919/05/59.mp4';

nSmooth = 60; % minutes
lns = [];
close all
allBytes = [files.bytes];
t = {files.date};
filtIds = allBytes < 2000 | allBytes > 8000000;
t(filtIds) = [];
allBytes(filtIds) = [];
ff(1200,600);
lns(2) = plot(smoothdata(allBytes,'gaussian',nSmooth),'k-','linewidth',4);
hold on;
lns(1) = plot(allBytes,'-','linewidth',0.5,'color',[1 0 0 0.25]);
xticks(1:240:numel(allBytes));
xticklabels(t(xticks));
xtickangle(30);
set(gca,'fontsize',20);
ylabel('File Size (bytes)');
title('Proxied Nest Movement');

isDark = zeros(1,numel(t));
isDark(hour(t) > 18 | hour(t) < 7 | (hour(t)==7 & minute(t)<30)) = 1;
onLocs = find(diff(isDark) == 1);
offLocs = find(diff(isDark) == -1);
for ii = 1:numel(onLocs)
    yLoc =  max(ylim)-max(ylim)*0.1;
    lns(3) = plot([onLocs(ii),offLocs(ii)],[yLoc yLoc],'-','linewidth',15,'color',[0 0 0 0.5]);
    xline(onLocs(ii),'k--');
    xline(offLocs(ii),'k--');
end

legend(lns,{'Raw Bytes',sprintf('Smoothed (%i min)',nSmooth),'Dark Cycle (6PM-730AM)'});
saveas(gcf,'proxiedNestMovement.jpg');

%%
% clipLength = 60; % seconds
% startId = find(strcmp({files(:).name},startName));
% endId = find(strcmp({files(:).name},endName));
% 
% endId = startId;
% startId = startId-704;
% allBytes = [files(startId:endId).bytes];
% allBytes_norm = normalize(allBytes,'range');
% t = linspace(0,(numel(allBytes)*60)/60/60,numel(allBytes));
% 
% % close all
% ff(1200,600);
% plot(t,allBytes_norm,'k-');
