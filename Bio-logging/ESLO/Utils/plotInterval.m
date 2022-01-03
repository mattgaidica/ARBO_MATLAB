function plotInterval(dataIntervals,iSeg)

tEEG = linspace(0,dataIntervals.duration(iSeg),numel(dataIntervals.data{iSeg}));
if ~isempty(dataIntervals.xl{iSeg})
    tAxy = linspace(0,dataIntervals.duration(iSeg),size(dataIntervals.xl{iSeg},1));
end

lw = 2;
close all;
ff(900,400);

esloGain = 12;
EEG = ADSgain(double(dataIntervals.data{iSeg}),esloGain); % convert to uV
EEG = cleanEEG(EEG,250); % clean at 300uV
plot(tEEG,EEG,'k-','linewidth',lw);
set(gca,'fontsize',14);
ylabel('EEG (\muV)');
xlim([min(tEEG),max(tEEG)]);
xlabel('Time (s)');
title(sprintf("Segment %i (%s)\n%s",iSeg,dataIntervals.label{iSeg},datestr(dataIntervals.startTime(iSeg))));

if ~isempty(dataIntervals.xl{iSeg})
    useColors = lines(3);
    yyaxis right;
    plot(tAxy,dataIntervals.xl{iSeg}(:,1),'-','color',useColors(1,:),'linewidth',lw);
    hold on;
    plot(tAxy,dataIntervals.xl{iSeg}(:,2),'-','color',useColors(2,:),'linewidth',lw);
    plot(tAxy,dataIntervals.xl{iSeg}(:,3),'-','color',useColors(3,:),'linewidth',lw);
    set(gca,'ycolor','k');
    ylabel('Axy Data');
end