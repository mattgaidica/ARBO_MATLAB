% note: ch2 is rev polarity
if do
    fname = '/Users/matt/Dropbox (University of Michigan)/Biologging/Database/R0002/Recording/ESLORB2.TXT';
    [type,data,labels] = extractSD(fname);
    SDreport(type,labels);
    dataIntervals = findESLOIntervals_v2(data,type,labels);
    do = 0;
end

esloGain = 12;
cleanThresh = 300;
Fs = 125;
axyFs = 10;

%% export SWA to file for testing with C code/CMSIS
FLIMS = [0.5 30];
startSample = round(50*Fs);
trial1_EEG2_id = 7;
EEG2 = double(dataIntervals.data{trial1_EEG2_id}); % raw data
A = EEG2(startSample:startSample+512-1);
[P,F] = pspectrum(A-mean(A),Fs);
figure;
plot(F,P);

% fileID = fopen('FFTData.txt','w');
% fprintf(fileID,'%6.2ff,\n',A);
% fclose(fileID);

%% sleep
FLIMS = [0.5 10];
climScale = 5;

close all;
trial1_EEG2_id = 11; % 7
trial1_EEG3_id = trial1_EEG2_id + 48; % 55

axy = dataIntervals.xl{trial1_EEG2_id};
EEG2 = -ADSgain(double(dataIntervals.data{trial1_EEG2_id}),esloGain); % convert to uV
EEG2 = cleanEEG(EEG2,cleanThresh);
EEG3 = ADSgain(double(dataIntervals.data{trial1_EEG3_id}),esloGain); % convert to uV
EEG3 = cleanEEG(EEG3,cleanThresh);

t_eeg = linspace(0,numel(EEG2)/Fs,numel(EEG2));
t_axy = linspace(0,size(axy,1)/axyFs,size(axy,1));

EEG_SWA = bandpass(EEG2,[0.5 4],Fs);
ff(1200,400);
% plot(t_eeg,EEG2,'k');
% hold on;
plot(t_eeg,EEG_SWA,'k');
[P,F,T] = pspectrum(EEG2,Fs,'spectrogram','FrequencyLimits',[0.5 4]);
yyaxis right;
plot(T,mean(P));

ff(1200,900);
ax1 = subplot(411);
for ii = 1:3
    plot(t_axy,axy(:,ii));
    hold on;
end
xlim([min(t_axy) max(t_axy)]);
ylabel('Axy');
xlabel('Time (s)');

ax2 = subplot(412);
ln1 = plot(t_eeg,EEG2);
hold on;
ln2 = plot(t_eeg,EEG3);
xlim([min(t_eeg) max(t_eeg)]);
ylim([-200 200]);
ylabel('uV');
xlabel('Time (s)');

[P,F,T] = pspectrum(EEG2,Fs,'spectrogram','FrequencyLimits',FLIMS);
ax3 = subplot(413);
imagesc(t_eeg,F,P);
set(gca,'ydir','normal');
colormap(magma);
caxis(caxis/climScale);
title('EEG2');
xlabel('Time (s)');
ylabel('Freq (Hz)');
hold on;

[P,F,T] = pspectrum(EEG3,Fs,'spectrogram','FrequencyLimits',FLIMS);
ax4 = subplot(414);
imagesc(t_eeg,F,P);
set(gca,'ydir','normal');
colormap(magma);
caxis(caxis/climScale/5);
title('EEG2');
xlabel('Time (s)');
ylabel('Freq (Hz)');
hold on;
linkaxes([ax1,ax2,ax3,ax4],'x');

%% hindlimb unloading
FLIMS = [1 30];
climScale = 10;

close all;
trial1_EEG2_id = 23; % trial 2: 23
trial1_EEG3_id = trial1_EEG2_id+48;

EEG2 = -ADSgain(double(dataIntervals.data{trial1_EEG2_id}),esloGain); % convert to uV
EEG2 = detrend(EEG2);
EEG3 = ADSgain(double(dataIntervals.data{trial1_EEG3_id}),esloGain); % convert to uV
EEG3 = detrend(EEG3);
axy = dataIntervals.xl{trial1_EEG2_id};
OA = intervalOA(axy,axyFs);

% in seconds
unloadIntervals = [8 55;90 135;170 221;255 298];
% unloadIntervals = [31 98; 140 222;260 298];

t_eeg = linspace(0,numel(EEG2)/Fs,numel(EEG2));
t_axy = linspace(0,size(axy,1)/axyFs,size(axy,1));

ff(1200,900);
ax1 = subplot(311);
ln1 = plot(t_eeg,EEG2);
hold on;
ln2 = plot(t_eeg,EEG3);
ylim([-200 200]);
ylabel('uV');

yyaxis right;
plot(t_axy,OA);
xlim([min(t_eeg) max(t_eeg)]);
ylabel('Axy OA');
xlabel('Time (s)');

[P,F,T] = pspectrum(EEG2,Fs,'spectrogram','FrequencyLimits',FLIMS);
ax2 = subplot(312);
imagesc(t_eeg,F,P);
set(gca,'ydir','normal');
colormap(magma);
caxis(caxis/climScale);
title('EEG2');
xlabel('Time (s)');
ylabel('Freq (Hz)');
hold on;

[P,F,T] = pspectrum(EEG3,Fs,'spectrogram','FrequencyLimits',FLIMS);
ax3 = subplot(313);
imagesc(t_eeg,F,P);
set(gca,'ydir','normal');
colormap(magma);
caxis(caxis/climScale);
title('EEG2');
xlabel('Time (s)');
ylabel('Freq (Hz)');
hold on;

linkaxes([ax1 ax2 ax3],'x');
for iPlot = 1:3
    subplot(3,1,iPlot);
    for iHU = 1:size(unloadIntervals,1)
        plot(unloadIntervals(iHU,:),[max(ylim) max(ylim)],'-','color','red','linewidth',4);
    end
end
legend([ln1,ln2],{'EEG2','EEG3'});

%%
% % % % all_unloadedData_EEG2 = unloadedData_EEG2;
% % % % all_loadedData_EEG2 = loadedData_EEG2;
% % % % all_unloadedData_EEG3 = unloadedData_EEG3;
% % % % all_loadedData_EEG3 = loadedData_EEG3;
% gather data
% % % % unloadSamples = round(unloadIntervals * Fs);
% % % % unloadedData_EEG2 = [];
% % % % loadedData_EEG2 = [];
% % % % unloadedData_EEG3 = [];
% % % % loadedData_EEG3 = [];
% % % % for iSample = 1:numel(EEG2)
% % % %     isUnloaded = 0;
% % % %     for iHU = 1:size(unloadIntervals,1)
% % % %         if iSample > unloadIntervals(iHU,1)*Fs && iSample < unloadIntervals(iHU,2)*Fs
% % % %             isUnloaded = 1;
% % % %         end
% % % %     end
% % % %     if isUnloaded
% % % %         unloadedData_EEG2 = [unloadedData_EEG2 EEG2(iSample)];
% % % %         unloadedData_EEG3 = [unloadedData_EEG3 EEG3(iSample)];
% % % %     else
% % % %        loadedData_EEG2 = [loadedData_EEG2 EEG2(iSample)];
% % % %        loadedData_EEG3 = [loadedData_EEG3 EEG3(iSample)];
% % % %     end
% % % % end

load('loadData_R0001');
FLIMS = [1 70];
blockSize = 5; % sec
blockSample = round(blockSize * Fs);

buffer_EEG2 = [];
buffer_EEG3 = [];
all_P_unloaded_EEG2 = [];
all_P_unloaded_EEG3 = [];
iBlock = 0;
for iSample = 1:numel(all_unloadedData_EEG2)
    if numel(buffer_EEG2) < blockSample
        buffer_EEG2 = [buffer_EEG2 all_unloadedData_EEG2(iSample)];
        buffer_EEG3 = [buffer_EEG3 all_unloadedData_EEG3(iSample)];
    else
        iBlock = iBlock + 1;
        [P,F] = pspectrum(buffer_EEG2,Fs,'FrequencyLimits',FLIMS);
        all_P_unloaded_EEG2(iBlock,:) = P;
        [P,F] = pspectrum(buffer_EEG3,Fs,'FrequencyLimits',FLIMS);
        all_P_unloaded_EEG3(iBlock,:) = P;
        buffer_EEG2 = [];
        buffer_EEG3 = [];
    end
end
buffer_EEG2 = [];
buffer_EEG3 = [];
all_P_loaded_EEG2 = [];
all_P_loaded_EEG3 = [];
iBlock = 0;
for iSample = 1:numel(all_loadedData_EEG2)
    if numel(buffer_EEG2) < blockSample
        buffer_EEG2 = [buffer_EEG2 all_loadedData_EEG2(iSample)];
        buffer_EEG3 = [buffer_EEG3 all_loadedData_EEG3(iSample)];
    else
        iBlock = iBlock + 1;
        [P,F] = pspectrum(buffer_EEG2,Fs,'FrequencyLimits',FLIMS);
        all_P_loaded_EEG2(iBlock,:) = P;
        [P,F] = pspectrum(buffer_EEG3,Fs,'FrequencyLimits',FLIMS);
        all_P_loaded_EEG3(iBlock,:) = P;
        buffer_EEG2 = [];
        buffer_EEG3 = [];
    end
end

nSmooth = 10;
close all;
ff(800,500);
subplot(211);
ln1 = plot(F,smoothdata(median(all_P_unloaded_EEG2),'gaussian',nSmooth),'r-','linewidth',2);
hold on;
ln2 = plot(F,smoothdata(median(all_P_loaded_EEG2),'gaussian',nSmooth),'k-','linewidth',2);
xlim([min(F),max(F)]);
xlabel('Freq. (Hz)');
ylabel('Power (|Y|)');
legend([ln1,ln2],{'Unloaded','Loaded'});
title('EEG2');

subplot(212);
ln1 = plot(F,smoothdata(median(all_P_unloaded_EEG3),'gaussian',nSmooth),'r-','linewidth',2);
hold on;
ln2 = plot(F,smoothdata(median(all_P_loaded_EEG3),'gaussian',nSmooth),'k-','linewidth',2);
xlim([min(F),max(F)]);
xlabel('Freq. (Hz)');
ylabel('Power (|Y|)');
legend([ln1,ln2],{'Unloaded','Loaded'});
title('EEG3');

%% where are freqs sig diff?
all_pvals = [];
greaterCond = [];
for iFreq = 1:size(all_P_unloaded_EEG2,2)
    y = [all_P_unloaded_EEG2(:,iFreq)' all_P_loaded_EEG2(:,iFreq)'];
    group = [zeros(1,size(all_P_unloaded_EEG2,1)) ones(1,size(all_P_loaded_EEG2,1))];
    all_pvals(iFreq) = anova1(y,group,'off');
    if mean(all_P_unloaded_EEG2(:,iFreq)) > mean(all_P_loaded_EEG2(:,iFreq))
        greaterCond(iFreq) = 1;
    else
        greaterCond(iFreq) = 0;
    end
end

alpha = 0.001;
nSmooth = 1;

close all;
ff(1200,900);

subplot(211);
y = smoothdata(mean(all_P_unloaded_EEG2),'gaussian',nSmooth);
ln1 = plot(F,y,'r-','linewidth',2);
hold on;
sigIds = find(all_pvals < alpha & greaterCond == 1);
plot(F(sigIds),y(sigIds),'r*');

y = smoothdata(mean(all_P_loaded_EEG2),'gaussian',nSmooth);
ln2 = plot(F,y,'k-','linewidth',2);
sigIds = find(all_pvals < alpha & greaterCond == 0);
plot(F(sigIds),y(sigIds),'k*');

xlim([min(F),max(F)]);
xlabel('Freq. (Hz)');
ylabel('Power (|Y|)');
legend([ln1,ln2],{'Unloaded','Loaded'});
title('EEG2');

% EEG3
all_pvals = [];
greaterCond = [];
for iFreq = 1:size(all_P_unloaded_EEG3,2)
    y = [all_P_unloaded_EEG3(:,iFreq)' all_P_loaded_EEG3(:,iFreq)'];
    group = [zeros(1,size(all_P_unloaded_EEG3,1)) ones(1,size(all_P_loaded_EEG3,1))];
    all_pvals(iFreq) = anova1(y,group,'off');
    if mean(all_P_unloaded_EEG3(:,iFreq)) > mean(all_P_loaded_EEG3(:,iFreq))
        greaterCond(iFreq) = 1;
    else
        greaterCond(iFreq) = 0;
    end
end
subplot(212);
y = smoothdata(mean(all_P_unloaded_EEG3),'gaussian',nSmooth);
ln1 = plot(F,y,'r-','linewidth',2);
hold on;
sigIds = find(all_pvals < alpha & greaterCond == 1);
plot(F(sigIds),y(sigIds),'r*');

y = smoothdata(mean(all_P_loaded_EEG3),'gaussian',nSmooth);
ln2 = plot(F,y,'k-','linewidth',2);
sigIds = find(all_pvals < alpha & greaterCond == 0);
plot(F(sigIds),y(sigIds),'k*');

xlim([min(F),max(F)]);
xlabel('Freq. (Hz)');
ylabel('Power (|Y|)');
legend([ln1,ln2],{'Unloaded','Loaded'});
title('EEG3');

%%
trial1_EEG2_id = 23;
trial1_EEG3_id = 71;
EEG2 = -ADSgain(double(dataIntervals.data{trial1_EEG2_id}),esloGain); % convert to uV
EEG3 = ADSgain(double(dataIntervals.data{trial1_EEG3_id}),esloGain); % convert to uV

%% euthanasia
FLIMS = [1 80];
EEG2 = -ADSgain(double(dataIntervals.data{48}),esloGain); % convert to uV
EEG3 = ADSgain(double(dataIntervals.data{96}),esloGain); % convert to uV
EEG2_clean = cleanEEG(EEG2,cleanThresh); % clean at uV
EEG3_clean = cleanEEG(EEG3,cleanThresh); % clean at uV
%     EEG_SWA = filtfilt(SOS,G,EEG_clean); % use: load('SOSG_LP4Hz.mat');

t_eeg = linspace(0,numel(EEG2_clean)/Fs/60,numel(EEG2_clean));

close all
ff(1200,900);
ax1 = subplot(3,1,1);
plot(t_eeg,EEG2_clean);
hold on;
plot(t_eeg,EEG3_clean);
xlim([min(t_eeg) max(t_eeg)]);
legend({'EEG2','EEG3'});

[P,F,T] = pspectrum(EEG2_clean,Fs,'spectrogram','FrequencyLimits',FLIMS);
ax2 = subplot(3,1,2);
imagesc(t_eeg,F,P);
set(gca,'ydir','normal');
colormap(magma);
caxis(caxis/20);
title('EEG2');
xlabel('Time (min)');
hold on;

[P,F,T] = pspectrum(EEG3_clean,Fs,'spectrogram','FrequencyLimits',FLIMS);
ax3 = subplot(3,1,3);
imagesc(t_eeg,F,P);
set(gca,'ydir','normal');
colormap(magma);
caxis(caxis/20);
title('EEG3');
xlabel('Time (min)');
hold on;

linkaxes([ax1 ax2 ax3],'x');
eventTimes = [3.5,8.33,14.1,15.6];
eventLabels = {'Induction','Unconcious','Heart Snipped','Dead'};
for iPlot = 1:3
    subplot(3,1,iPlot);
    for iEvent = 1:numel(eventTimes)
        xline(eventTimes(iEvent));
        text(eventTimes(iEvent),min(ylim),eventLabels{iEvent});
    end
end