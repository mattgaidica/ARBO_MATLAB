doPlot = 1;
rootPath = '/Users/matt/Dropbox (University of Michigan)/Biologging/Database/R0004/SWA Trials/TryNoFail7';
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
all_msToStim = [];
fileCount = 0;
for iFile = 1:numel(file)
    fname = fullfile(rootPath,file{iFile});
    [trialVars,EEG,t] = extractSWATrial(fname,Fs);
    if trialVars.msToStim > 5000 || any(abs(normalize(EEG)) > 15)
        fprintf('Outlying trial file %i, trial %i\n',iFile,trialVars.trialCount);
        continue;
    end
    fileCount = fileCount + 1;
    all_Freq(fileCount) = trialVars.dominantFreq / 1000;
    all_Phase(fileCount) = trialVars.phaseAngle / 1000;
    all_Sham(fileCount) = trialVars.doSham;
    all_Trials(fileCount) = trialVars.trialCount;
    all_EEG(fileCount,:) = detrend(EEG);
    all_EEG_filt(fileCount,:) = bandpass(EEG,[0.5 4],Fs);
    all_msToStim(fileCount,:) = trialVars.msToStim;
    if doPlot
        fs = 16;
        h = ff(1200,500);
        plot(t,detrend(EEG),'k-','linewidth',2); % NOTE: detrend
        ylabel('Raw (uV)');
        
        yyaxis right;
        plot(t,all_EEG_filt(fileCount,:),'r-');
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
        if trialVars.doSham == 0
            xline(t(stimIdx)+0.05,'r-','linewidth',20,'alpha',0.2);
            text(t(stimIdx),max(ylim),'STIM\rightarrow','color','r','fontsize',fs,'verticalalignment','top','horizontalalignment','right');
        else
            xline(t(stimIdx)+0.05,'k-','linewidth',20,'alpha',0.2);
            text(t(stimIdx),max(ylim),'STIM\rightarrow','color','k','fontsize',fs,'verticalalignment','top','horizontalalignment','right');
        end
        
        saveas(h,sprintf("%s.png",fname));
        close(h);
    end
end
chime
%% stim vs. sham ephys
% pre-process for stim time
periStimEEG = [];
windowSamples = 100;
stimDuration = 50; % ms
for iTrial = 1:size(all_EEG,1)
    stimIdx = closest(t,max(t)/2+((all_msToStim(iTrial)+(stimDuration/2))/1000));
    periStimEEG(iTrial,:) = all_EEG(iTrial,stimIdx-windowSamples+1:stimIdx+windowSamples);
end
t_peri = linspace(0,size(periStimEEG,2)/125,size(periStimEEG,2));
op = 0.2;
lw = 2;
colors = [1,0,0;0,0,0];
close all
ff(1200,400);
lns = [];
for iSham = 0%:1
    plot_distribution(t_peri,periStimEEG(all_Sham==iSham,:),'Color',colors(iSham+1,:),'Alpha',op,'LineWidth',lw);
    hold on;
    lns(iSham+1) = plot([0,0],[max(ylim) max(ylim)]*2,'color',colors(iSham+1,:),'linewidth',lw); % for legend
end
xline(max(t_peri)/2,'k:');
xlim([min(t_peri),max(t_peri)]);
xticks([-max(t_peri)/2,0,max(t_peri)/2]);
ylabel('uV');
ylim([-100 100]);
xlabel('Time (s)');
text(max(t_peri)/2,max(ylim)-5,'\leftarrowSTIM');
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