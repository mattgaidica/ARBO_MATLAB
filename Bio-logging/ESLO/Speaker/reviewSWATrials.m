rootPath = '/Users/matt/Dropbox (University of Michigan)/Biologging/Database/R0003/SWA Trials';
[file,path] = uigetfile(fullfile(rootPath,'*.BIN'),'MultiSelect','on');
Fs = 125;
all_Freq = [];
all_Phase = [];
all_Sham = [];
all_Trials = [];
for iFile = 1:numel(file)
    fname = fullfile(rootPath,file{iFile});
    [trialVars,EEG] = extractSWATrial(fname,Fs);
    all_Freq(iFile) = trialVars.dominantFreq / 1000;
    all_Phase(iFile) = trialVars.phaseAngle / 1000;
    all_Sham(iFile) = trialVars.doSham;
    all_Trials(iFile) = trialVars.trialCount;
end
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