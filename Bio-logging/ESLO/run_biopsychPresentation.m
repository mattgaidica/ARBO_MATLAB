if do
    fname = '/Users/matt/Dropbox (University of Michigan)/Biologging/Database/0006/ESLORB2.TXT';
    [type,data,labels] = extractSD(fname);
    do = false;
end
SDreport(type,labels);
useTypes = ["EEG2","EEG3","XlX","XlY","XlZ"];
dataIntervals = findESLOIntervals(data,type,labels,useTypes);
Fs = 50;
axyFs = 1;
useBoutDuration = 30; % seconds
startHour = 20;
showHours = 8;
esloGain = 12;

iSegment = 4%unique(dataIntervals.segment)'
xRow = find(dataIntervals.segment == iSegment & dataIntervals.type == ESLOType("XlX",labels));
x = data(dataIntervals.range{xRow});
yRow = find(dataIntervals.segment == iSegment & dataIntervals.type == ESLOType("XlY",labels));
y = data(dataIntervals.range{yRow});
zRow = find(dataIntervals.segment == iSegment & dataIntervals.type == ESLOType("XlZ",labels));
z = data(dataIntervals.range{zRow});
OA = axyOA(x,y,z,axyFs);
OA_min = equalVectors(OA,round(numel(OA)/60));
[hm,W_z] = quickHomeogram(OA_min);
W_z = normalize(W_z,'range');

EEG_row = find(dataIntervals.segment == iSegment & dataIntervals.type == ESLOType("EEG2",labels));
EEG = double(data(dataIntervals.range{EEG_row}));
EEG = ADSgain(EEG,esloGain); % convert to uV
EEG = cleanEEG(EEG,250); % clean at 300uV
load('SOSG_LP4Hz.mat');
EEG_SWA = filtfilt(SOS,G,EEG);
hm_EEG = equalVectors(double(hm),EEG);
hm_EEG = logical(hm_EEG); % is_asleep
W_z = equalVectors(W_z,EEG);

% data is loaded, trim recording
secondsOffset = startHour*60*60 - (hour(dataIntervals.time(EEG_row))*60*60 ...
    + minute(dataIntervals.time(EEG_row))*60 + second(dataIntervals.time(EEG_row)));
sampleOffset = round(secondsOffset * Fs);
if sampleOffset < 1
    sampleOffset = 1;
end
sampleRange = sampleOffset:sampleOffset+showHours*60*60*Fs;
if sampleRange > numel(EEG)
    error('showHours out of range');
end
EEG = EEG(sampleRange);
EEG_SWA = EEG_SWA(sampleRange);
hm_EEG = hm_EEG(sampleRange);
W_z = W_z(sampleRange);

SWA_locs = slowWaveDetect(EEG_SWA,Fs);

startingPoints = 1:Fs*useBoutDuration:numel(EEG)-Fs*useBoutDuration;
sleepClass = zeros(1,numel(startingPoints));
SWA_power = [];
SWA_count = [];
SWA_OA = [];
% get awake power array
for iP = 1:numel(startingPoints)
    thisRange = startingPoints(iP):startingPoints(iP) + Fs*useBoutDuration;
    if thisRange(end) > numel(hm_EEG)
        break;
    end
    P = pspectrum(EEG_SWA(thisRange),Fs); % bandpass takes care of freq range
    SWA_power(iP) = mean(P);
    SWA_count(iP) = sum(SWA_locs >= thisRange(1) & SWA_locs <= thisRange(end));
    SWA_OA(iP) = mean(W_z(thisRange));
    if median(hm_EEG(thisRange)) == 0
        sleepClass(iP) = 2;
        continue;
    end
end

lineColors = lines(5);
lw = 1.5;
lns = [];
close all
ff(1000,600);
xlims = [1933,1933+8;524,524+8]; % awake = 340, asleep = 1930
stateTitle = {'Asleep','Awake'};
for ii = 1:2
    subplot(2,1,ii)
    t = linspace(0,numel(EEG)/Fs,numel(EEG));
    lns(1) = plot(t,EEG,'k-','linewidth',lw);
    hold on;
    lns(2) = plot(t,EEG_SWA,'-','color',lineColors(2,:),'linewidth',lw*2);
    ylabel('\muV');
    %     plot(SWA_locs,EEG_SWA(SWA_locs),'rx');
    ylim([-200 200]);
    yticks(min(ylim):100:max(ylim));
    grid on;
    title(sprintf('EEG & SWA (%s)',stateTitle{ii}));
    xlabel('Time (seconds)');
    xlim(xlims(ii,:));
    set(gca,'fontsize',fs);
    legend(lns,{'EEG','0.5–4Hz Filter (SWA)'},'location','southeast','fontsize',14);
    legend box off;
end
set(gcf,'PaperPositionMode','auto');
saveas(gcf,'coverLetterSWA.eps','epsc');

%%
sleepClass_delta = sleepClass;
% !! very sensitive to SWA_count feature
sleepClass((SWA_power <= 2*median(SWA_power(sleepClass==2))) & sleepClass == 0) = 1; % REM
sleepClass_delta(SWA_power <= 2*median(SWA_power(sleepClass_delta==2)) & sleepClass_delta == 0) = 1; % REM
sleepClass_delta(SWA_power > 2*median(SWA_power(sleepClass_delta==2)) & SWA_count > 0 & sleepClass_delta == 0) = -1; % REM
%     close all
fs = 16;
lns = [];
close all
lineColors = lines(5);
ff(1000,900);
subplot(311);
t = linspace(0,numel(EEG)/Fs,numel(EEG))/60/60;
lns(1) = plot(t,EEG,'k-');
ylabel('\muV');
ylim([-500 500]);
yticks([-200 200]);
yyaxis right;
lns(2) = plot(t,hm_EEG,'r-');
hold on;
lns(3) = plot(t,W_z,'-','color',lineColors(5,:));
ylim([-0.5 6]);
xlim([min(t) max(t)]);
yticks([0 1]);
yticklabels({'Awake','Asleep'});
set(gca,'ycolor','r');
ax = gca;
xax = ax.YAxis;
set(xax,'TickDirection','out');
title('Electrophysiology & Accelerometer Data');
xlabel('Time (hours)');
text(min(t),max(ylim)-max(ylim)/5,'\leftarrow 8PM','fontsize',fs-2);
set(gca,'fontsize',fs);
legend(lns,{'EEG','Homeogram','Overall Acceleration'},'location','northeast','fontsize',11);
legend box off;

subplot(312);
bar(t(startingPoints),SWA_count,'k');
ylabel('SWA Epochs');
ylim([0 20]);
yyaxis right;
plot(t(startingPoints),SWA_power,'-','color',lineColors(2,:),'linewidth',1.5);
hold on;
yline(2*median(SWA_power(sleepClass==2)),':','color',lineColors(2,:));
yticks(2*median(SWA_power(sleepClass==2)));
yticklabels({});
ylabel('SWA Power (a.u.)');
set(gca,'fontsize',fs);
title('SWA Epochs & SWA Power');
xlabel('Time (hours)');
legend({'SWA Epochs','SWA Power','2*median(SWA_{awake})'},'fontsize',11);
legend box off;

subplot(313);
[P,F,T] = pspectrum(EEG,Fs,'spectrogram');
t_spectrum = linspace(0,max(t),numel(T));
imagesc(t_spectrum,F,P);
colormap(magma);
set(gca,'ydir','normal');
ylim([0 20]);
caxis(caxis/3);
ylabel('Frequency (Hz)');
yyaxis right;
sleepClass_small = equalVectors(sleepClass,numel(T));
stairs(t_spectrum,round(sleepClass_small),'w-');
yticks([0:2]);
yticklabels({'NREM','REM','Awake'});
ax = gca;
xax = ax.YAxis;
set(xax,'TickDirection','out');
set(gca,'ycolor','k');
ylim([-3 3]);
set(gca,'fontsize',fs);
title('Spectrogram & Sleep Stages');
xlabel('Time (hours)');
%     xlim([1 max(startingPoints)]);

%%
nSmooth = 50;
ff(1000,300);
plot(t(startingPoints),smoothdata(SWA_count,'movmean',nSmooth),'k');
yticks([]);
ylabel('SWA Epochs (a.u.)');
ylim([min(ylim) max(ylim)*1.2]);
%     ylim([0 20]);
yyaxis right;
plot(t(startingPoints),smoothdata(SWA_power,'movmean',nSmooth),'-','color',lineColors(2,:),'linewidth',1.5);
hold on;
ylim([min(ylim) max(ylim)*1.2]);
yticks([]);
ylabel('SWA Power (a.u.)');
set(gca,'fontsize',fs);
title('Smoothed SWA Epochs & SWA Power');
legend({'SWA Epochs','SWA Power'},'fontsize',11);
legend box off;
xlabel('Time (hours)');
%%
%     close all
fs = 18;
ff(800,400);
subplot(121);
colors = [[0 1 0];zeros([1,3]);repmat(0.9,[1,3])];
p = pie([sum(sleepClass==2),sum(sleepClass==0),sum(sleepClass==1)],...
    {sprintf('Awake (%1.0f%%)',100*sum(sleepClass==2)/numel(sleepClass)),...
    sprintf('NREM (%1.0f%%)',100*sum(sleepClass==0)/numel(sleepClass)),...
    sprintf('REM (%1.0f%%)',100*sum(sleepClass==1)/numel(sleepClass))});
colorCount = 0;
for ii = 1:numel(p)
    if mod(ii,2)
        colorCount = colorCount + 1;
        p(ii).FaceColor = colors(colorCount,:);
    else
        p(ii).FontSize = fs;
    end
end

colors = [[0 1 0];zeros([1,3]);repmat(0.3,[1,3]);repmat(0.9,[1,3])];
subplot(122);
p = pie([sum(sleepClass_delta==2),sum(sleepClass_delta==0),sum(sleepClass_delta==-1),sum(sleepClass_delta==1)],...
    {sprintf('Awake (%1.0f%%)',100*sum(sleepClass_delta==2)/numel(sleepClass_delta)),...
    sprintf('NREM (%1.0f%%)',100*sum(sleepClass_delta==0)/numel(sleepClass_delta)),...
    sprintf('SWA Detect (%1.0f%%)',100*sum(sleepClass_delta==-1)/numel(sleepClass_delta)),...
    sprintf('REM (%1.0f%%)',100*sum(sleepClass_delta==1)/numel(sleepClass_delta))});
colorCount = 0;
for ii = 1:numel(p)
    if mod(ii,2)
        colorCount = colorCount + 1;
        p(ii).FaceColor = colors(colorCount,:);
    else
        p(ii).FontSize = fs;
    end
end

%% SWA and movement offset
asleepIds = find(diff(W_z<0.1)==1);
useWindow = 30*60; % s
allTraces = [];
Wz_traces = [];
traceCount = 0;
for ii = 1:numel(asleepIds)
    useRange = round(asleepIds(ii)-Fs*useWindow):round(asleepIds(ii)+Fs*useWindow);
    if min(useRange) < 1
        continue;
    end
    if max(useRange) > numel(hm_EEG)
        break;
    end
    traceCount = traceCount + 1;
    Wz_traces(traceCount,:) = W_z(useRange);
    [P,F,T] = pspectrum(EEG_SWA(useRange),Fs,'spectrogram');
    allTraces(traceCount,:) = mean(P);
end
close all
ff(1000,600);
t_power = linspace(-useWindow,useWindow,size(allTraces,2)) / 60;
plot(t_power,median(allTraces),'k-','linewidth',2);
hold on;
plot(t_power,smoothdata(median(allTraces),'movmean',60),'r-','linewidth',2);
xlim([min(t_power) max(t_power)]);
xlabel('Time rel. to movement offset (minutes)');
yticks([]);
ylabel('Median SWA Power (a.u.)');
set(gca,'fontsize',16);
grid on;
title(sprintf('SWA Power Relative to Movement (%i offsets)',traceCount));
legend({'Median SWA Power','Smoothed'},'location','northwest');
