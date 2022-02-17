rootPath = '/Users/matt/Dropbox (University of Michigan)/Biologging/Database/R0003/SWA Trials';
[file,path] = uigetfile(fullfile(rootPath,'*.BIN'),'MultiSelect','on');
% 242-343 were Bypass SWA
% 352-377 are no-axy trials
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
end
%%
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

%%
all_Trials = sort(all_Trials);
tTrials = 1:numel(all_Trials);
close all;
lw = 1.5;
ms = 20;
ff(1200,400);
subplot(131);
% histogram(all_Freq,0:0.02:4);
plot(tTrials,all_Freq,'k.','linewidth',lw,'markersize',ms);
ylabel('Freq (Hz)');
xlabel('Trial');
xticks(tTrials);
xtickangle(-90);
xticklabels(compose('%4d',all_Trials));
xlim([min(tTrials) max(tTrials)]);
grid on;

subplot(132);
% histogram(all_Phase,0:30:360);
plot(tTrials,all_Phase,'k.','linewidth',lw,'markersize',ms);
ylabel('Phase (Degrees)');
xlabel('Trial');
xticks(tTrials);
xtickangle(-90);
xticklabels(compose('%4d',all_Trials));
xlim([min(tTrials) max(tTrials)]);
grid on;

subplot(133);
plot(tTrials,all_Sham,'kx','linewidth',lw,'markersize',ms);
ylabel('Sham?');
yticks([0 1]);
ylim([-0.5 1.5]);
yticklabels({'No','Yes'});
xlabel('Trial');
xticks(tTrials);
xtickangle(-90);
xticklabels(compose('%4d',all_Trials));
xlim([min(tTrials) max(tTrials)]);
grid on;