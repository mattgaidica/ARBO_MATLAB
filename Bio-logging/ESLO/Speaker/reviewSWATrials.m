doPlot = 0;
rootPath = '/Users/matt/Dropbox (University of Michigan)/Biologging/Database/R0003/SWA Trials';
[file,path] = uigetfile(fullfile(rootPath,'*.BIN'),'MultiSelect','on');
if ~iscell(file)
    file = {file}; % always cell for loop
end
Fs = 125;
all_Freq = [];
all_Phase = [];
all_Sham = [];
all_Trials = [];
all_EEG = [];
all_EEG_filt = [];
for iFile = 1:numel(file)
    fname = fullfile(rootPath,file{iFile});
    [trialVars,EEG,t] = extractSWATrial(fname,Fs);
    all_Freq(iFile) = trialVars.dominantFreq / 1000;
    all_Phase(iFile) = trialVars.phaseAngle / 1000;
    all_Sham(iFile) = trialVars.doSham;
    all_Trials(iFile) = trialVars.trialCount;
    all_EEG(iFile,:) = EEG;
    all_EEG_filt(iFile,:) = bandpass(EEG,[0.5 4],Fs);
    if doPlot
        fs = 16;
        h = ff(1200,500);
        plot(t,detrend(EEG),'k-','linewidth',2); % NOTE: detrend
        ylabel('Raw (uV)');
        
        yyaxis right;
        plot(t,all_EEG_filt(iFile,:),'r-');
        set(gca,'ycolor','r');
        ylabel('SWA (uV)');
        
        yyaxis left;
        xlim([min(t), max(t)]);
        xticks(min(t):max(t)/8:max(t));
        grid on;
        xlabel('Time (s)');
        d = datetime(trialVars.absoluteTime,'ConvertFrom','epochtime','timezone','Etc/UTC');
        title(sprintf('Trial %i at %s (target = %1.1f°)\nFc: %1.2fHz @ %3.1f°',trialVars.trialCount,...
            datetime(d,'Format','dd-MMM-yyyy HH:mm:ss','timezone','America/Detroit'),trialVars.targetPhase/1000,...
            trialVars.dominantFreq/1000,trialVars.phaseAngle/1000));
        xline(max(t)/2,'r:','linewidth',2);
        text(max(t)/2,min(ylim),'DETECT\rightarrow','color','r','fontsize',fs,'verticalalignment','bottom','horizontalalignment','right');
        set(gca,'fontsize',fs-2);
        stimIdx = closest(t,max(t)/2+(trialVars.msToStim/1000));
        xline(t(stimIdx)+0.05,'r-','linewidth',20,'alpha',0.2);
        text(t(stimIdx),max(ylim),'STIM\rightarrow','color','r','fontsize',fs,'verticalalignment','top','horizontalalignment','right');
        
        saveas(h,sprintf("%s.png",fname));
        close(h);
    end
end
%% stim vs. sham ephys
op = 0.2;
lw = 2;
colors = [1,0,0;0,0,0];
close all
ff(1200,400);
lns = [];
for iSham = 0:1
    plot_distribution(t,all_EEG_filt(all_Sham==iSham,:),'Color',colors(iSham+1,:),'Alpha',op,'LineWidth',lw);
    hold on;
    lns(iSham+1) = plot([0,0],[max(ylim) max(ylim)]*2,'color',colors(iSham+1,:),'linewidth',lw);
end
xline(max(t)/2,'k:');
xlim([min(t),max(t)]);
xticks([0,max(t)/2,max(t)]);
ylabel('uV');
ylim([-50 50]);
xlabel('Time (s)');
text(max(t)/2,max(ylim)-5,'\leftarrowSTIM');
title('SWA Peri-stim');
grid on;
set(gca,'fontsize',14);
legend(lns,{sprintf('Stim (n=%i)',sum(all_Sham==0)),sprintf('Sham (n=%i)',sum(all_Sham==1))});

%% freq, phase, and sham by trials (overview)
[all_Trials,k] = sort(all_Trials);
labelSpace = round(linspace(1,numel(all_Trials),min([numel(all_Trials),100])));
labelTrials = all_Trials(labelSpace);
tTrials = 1:numel(all_Trials);
fCut = 0.7;
rows = 3;
cols = 5;
close all;
lw = 1.5;
ms = 20;
fs = 12;
ff(1200,800);
subplot(rows,cols,[1:4]);
blackTrials = find(all_Freq(k) >= fCut);
plot(tTrials(blackTrials),all_Freq(k(blackTrials)),'k.','linewidth',lw,'markersize',ms);
hold on;
redTrials = find(all_Freq(k) < fCut);
plot(tTrials(redTrials),all_Freq(k(redTrials)),'r.','linewidth',lw,'markersize',ms);
ylabel('Freq (Hz)');
xlabel('Trial');
xticks(labelSpace);
xtickangle(-90);
xticklabels(compose('%4d',labelTrials));
xlim([min(tTrials) max(tTrials)]);
grid on;
title('SWA Trials');
set(gca,'fontsize',fs);

subplot(rows,cols,5);
fHistBins = 0:.1:4;
histogram(all_Freq(k(blackTrials)),fHistBins,'facecolor','k');
hold on;
histogram(all_Freq(k(redTrials)),fHistBins,'facecolor','r');
ylabel('# Trials');
xlabel('Freq (Hz)');
set(gca,'fontsize',fs);
set(gca,'view',[90 -90]);
grid on;

subplot(rows,cols,[6:9]);
plot(tTrials(blackTrials),all_Phase(k(blackTrials)),'k.','linewidth',lw,'markersize',ms);
hold on;
plot(tTrials(redTrials),all_Phase(k(redTrials)),'r.','linewidth',lw,'markersize',ms);
ylim([0 360]);
ylabel('Phase (Degrees)');
xlabel('Trial');
xticks(labelSpace);
xtickangle(-90);
xticklabels(compose('%4d',labelTrials));
xlim([min(tTrials) max(tTrials)]);
grid on;
set(gca,'fontsize',fs);

subplot(rows,cols,10);
pHistBins = 0:30:360;
histogram(all_Phase(k(blackTrials)),pHistBins,'facecolor','k');
hold on;
histogram(all_Phase(k(redTrials)),pHistBins,'facecolor','r');
ylabel('# Trials');
xlabel('Phase (Degrees)');
set(gca,'fontsize',fs);
set(gca,'view',[90 -90]);
grid on;

subplot(rows,cols,[11:14]);
plot(tTrials(blackTrials),all_Sham(k(blackTrials)),'kx','linewidth',lw,'markersize',ms);
hold on;
plot(tTrials(redTrials),all_Sham(k(redTrials)),'rx','linewidth',lw,'markersize',ms);
ylabel('Sham?');
yticks([0 1]);
ylim([-0.5 1.5]);
yticklabels({'No','Yes'});
xlabel('Trial');
xticks(labelSpace);
xtickangle(-90);
xticklabels(compose('%4d',labelTrials));
xlim([min(tTrials) max(tTrials)]);
grid on;
set(gca,'fontsize',fs);

subplot(rows,cols,15);
sHistBins = -0.5:1.5;
histogram(all_Sham(k),sHistBins,'facecolor','k');
hold on;
histogram(all_Sham(k),sHistBins,'facecolor','k');
ylabel('# Trials');
xticks([0 1]);
xticklabels({'No','Yes'});
set(gca,'fontsize',fs);
set(gca,'view',[90 -90]);
grid on;