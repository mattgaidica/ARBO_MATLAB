%% 
cd '/Users/matt/Documents/MATLAB/ARBO/Bio-logging/ESLO/Speaker';
Fs = 125;
fname = '/Users/matt/Dropbox (University of Michigan)/Biologging/Database/R0003/SWA Trials Selected/00231.BIN';
[trialVars,EEG,t] = extractSWATrial(fname,Fs);
%% SW detection
Fc = trialVars.dominantFreq / 1000;
Fp = trialVars.phaseAngle / 1000;
Ms = trialVars.msToStim;
t = linspace(0,4,numel(EEG)); % just use even numbers
stimIdx = closest(t,max(t)/2+Ms/1000);
endStim = stimIdx + round(0.05/diff(t(1:2)));
midStim = closest(t,max(t)/2+(Ms+25)/1000);
midPoint = round(numel(t)/2);
EEG_cos = [flip(cos(-t(2:midPoint) * (2*pi*Fc) + deg2rad(Fp))) cos(t(1:midPoint+1) * (2*pi*Fc) + deg2rad(Fp))];
t = linspace(-2,2,numel(EEG)); % just use even numbers

fs = 14;
EEG_filt = bandpass(EEG,[0.5 4],Fs);
close all;
ff(600,250);
ln1 = plot(t,detrend(EEG),'k-','linewidth',2);
ylabel('EEG (\muV)');
hold on;
ln2 = plot(t,EEG_filt,'color',[0 0 0 0.7]);
legend([ln1,ln2],{'Raw','Filtered'},'Autoupdate','off','location','northwest','fontsize',fs-2);
legend box off;
yticks(-100:50:100);

yyaxis right;
plot(t(1:midPoint),EEG_cos(1:midPoint),'r-','linewidth',2);
hold on;
plot(t(midPoint:end),EEG_cos(midPoint:end),'r:','linewidth',2);
ylabel('Signal Estimate');
ylim([-1.5 1.8]);
yticks(ylim);
yticklabels([]);
set(gca,'ycolor','r');

colors = lines(5);
x = [t(stimIdx) t(endStim) t(endStim) t(stimIdx)];
y = [min(ylim) min(ylim) max(ylim) max(ylim)];
patch('XData',x,'YData',y,'FaceColor','red','EdgeColor','none','FaceColor',colors(5,:),'FaceAlpha',0.5);

xlim([min(t), max(t)]);
xticks(min(t):max(t)/4:max(t));
grid on;
xlabel('Time (s)');
xline(t(midPoint),'k-');
set(gca,'fontsize',14);

text(t(endStim),max(ylim),'\leftarrowSTIM','color',colors(5,:),'fontsize',fs-2,'verticalalignment','top','horizontalalignment','left');
text(t(midPoint),max(ylim),'DETECT\rightarrow','color','k','fontsize',fs-2,'verticalalignment','top','horizontalalignment','right');
title('SW Detection and Stimulus');

% if doSave
%     print(gcf,'-painters','-depsc',fullfile(exportPath,'QBTransitions.eps')); % required for vector lines
    saveas(gcf,'ESLOMethods_R0003.jpg','jpg');
%     close(gcf);
% end

%% squirrel sleep
cd '/Users/matt/Documents/MATLAB/ARBO/Bio-logging/ESLO';
doSave = 1;
if do
    fname = '/Users/matt/Dropbox (University of Michigan)/Biologging/Database/S0006_0200/ESLORB2.TXT';
    [type,data,labels] = extractSD(fname,Inf,datetime(2021,8,13));
    do = false;
    SDreport(type,labels);
    useTypes = ["EEG2","EEG3","XlX","XlY","XlZ"];
    dataIntervals = findESLOIntervals(data,type,labels,useTypes);
end

Fs = 50;
axyFs = 1;
startHour = 20;
showHours = 8;
esloGain = 12;

iSegment = 4;
xRow = find(dataIntervals.segment == iSegment & dataIntervals.type == ESLOType("XlX",labels));
x = data(dataIntervals.range{xRow});
yRow = find(dataIntervals.segment == iSegment & dataIntervals.type == ESLOType("XlY",labels));
y = data(dataIntervals.range{yRow});
zRow = find(dataIntervals.segment == iSegment & dataIntervals.type == ESLOType("XlZ",labels));
z = data(dataIntervals.range{zRow});
OA = axyOA(x,y,z,axyFs);

EEG_row = find(dataIntervals.segment == iSegment & dataIntervals.type == ESLOType("EEG2",labels));
EEG = double(data(dataIntervals.range{EEG_row}));
EEG = ADSgain(EEG,esloGain); % convert to uV
EEG = cleanEEG(EEG,300); % clean at 300uV

% data is loaded, trim recording
secondsOffset = startHour*60*60 - (hour(dataIntervals.time(EEG_row))*60*60 ...
    + minute(dataIntervals.time(EEG_row))*60 + second(dataIntervals.time(EEG_row)));
sampleOffset = round(secondsOffset * Fs);
if sampleOffset < 1
    sampleOffset = 1;
end
sampleRange = sampleOffset:sampleOffset+showHours*3600*Fs;
if sampleRange > numel(EEG)
    error('showHours out of range');
end
EEG = detrend(EEG(sampleRange));
x = x(secondsOffset:secondsOffset+showHours*3600*axyFs);
y = y(secondsOffset:secondsOffset+showHours*3600*axyFs);
z = z(secondsOffset:secondsOffset+showHours*3600*axyFs);

t_EEG = linspace(0,numel(EEG)/Fs/3600,numel(EEG));
t_axy = linspace(0,numel(EEG)/Fs/3600,numel(x));

fs = 14;
lw = 1.5;
lns = [];
close all;
rows = 3;
cols = 2;
ff(800,600);

t_sleep = 2.2003;
t_wake = 6.3818;
t_int = 10/3600; % 10 seconds

iPlotTitles = {'Overnight EEG and Accelerometer (Axy) Data','Sleep','Wake'};
plotMap = {1:2,3,4};
for iPlot = 1:3
    subplot(rows,cols,plotMap{iPlot});
    lns(1) = plot(t_EEG,EEG,'k','linewidth',lw);
    ylim([-500,800]);
    yticks([-200,0,200]);
    xlim([min(t),max(t)]);
    set(gca,'fontsize',fs);
    if ismember(iPlot,[1,2])
        ylabel('EEG (\muV)');
    end
    grid on;

    yyaxis right;
    colors = lines(3);
    lns(2) = plot(t_axy,normalize(x,'range'),'-','color',colors(1,:),'linewidth',lw);
    hold on;
    lns(3) = plot(t_axy,normalize(y,'range'),'-','color',colors(2,:),'linewidth',lw);
    lns(4) = plot(t_axy,normalize(z,'range'),'-','color',colors(3,:),'linewidth',lw);

    ylim([-2.35 1.5]);
    yticks(0.5);
    yticklabels({'±2'});
    
    if ismember(iPlot,[1,3])
        ylabel('Axy (mg)','VerticalAlignment','top');
    end
    grid on;
    set(gca,'ycolor','k');
    if iPlot == 1
        lg = legend(lns,{'EEG','X-axis','Y-axis','Z-axis'},'orientation','horizontal','location','southwest','fontsize',fs-2);
        pos = lg.Position;
        lg.Position = pos.*[1,.98,1,1];
        legend box off;
        xlabel('Time (hours)');
        text(min(xlim),max(ylim),' 8PM','fontsize',fs,'verticalalignment','top');
        text(t_sleep,max(ylim),'\downarrowSleep','fontsize',fs,'verticalalignment','top');
        text(t_wake,max(ylim),'\downarrowWake','fontsize',fs,'verticalalignment','top');
    end
    if iPlot == 2
        xlim([t_sleep t_sleep+t_int]);
    end
    if iPlot == 3
        xlim([t_wake t_wake+t_int]);
    end
    if ismember(iPlot,2:3)
        xticks(xlim);
        xticklabels({'0','10'});
        xlabel('Time (seconds)','verticalalignment','bottom');
    end

    title(iPlotTitles{iPlot});
end

subplot(rows,cols,5:6);
[P,F,T] = pspectrum(EEG,Fs,'spectrogram','frequencylimits',[0.5 20]);
T = linspace(0,8,numel(T));
imagesc(T,F,P);
set(gca,'ydir','normal','fontsize',fs);
colormap(magma);
xlabel('Time (hours)');
ylabel('Frequency (Hz)');
caxisauto(P,1);

yyaxis right;
colors = lines(3);
lns(2) = plot(t_axy,normalize(x,'range'),'-','color',colors(1,:),'linewidth',lw);
hold on;
lns(3) = plot(t_axy,normalize(y,'range'),'-','color',colors(2,:),'linewidth',lw);
lns(4) = plot(t_axy,normalize(z,'range'),'-','color',colors(3,:),'linewidth',lw);
ylabel('Axy (mg)','VerticalAlignment','top');
set(gca,'ycolor','k');
title('EEG Spectrogram');
ylim([-2.35 1.5]);
yticks(0.5);
yticklabels({'±2'});
text(min(xlim),max(ylim),' 8PM','fontsize',fs,'verticalalignment','top','color','w');
text(t_sleep,max(ylim),'\downarrowSleep','fontsize',fs,'verticalalignment','top','color','w');
text(t_wake,max(ylim),'\downarrowWake','fontsize',fs,'verticalalignment','top','color','w');

if doSave
%     print(gcf,'-painters','-depsc',fullfile(exportPath,'QBTransitions.eps')); % required for vector lines
    [xs,ys] = ginput(3);
    fs = 28;
    text(xs(1),ys(1),'A','fontsize',fs);
    text(xs(1),ys(2),'B','fontsize',fs);
    text(xs(1),ys(3),'C','fontsize',fs);
    saveas(gcf,'ESLOMethods_S0006.jpg','jpg');
%     close(gcf);
end
        