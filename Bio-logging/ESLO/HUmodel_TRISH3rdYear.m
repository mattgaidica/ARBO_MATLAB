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

%% hindlimb unloading
fs = 14;
FLIMS = [1 30];
climScale = 10;
colors = lines(1);

rows = 2;
cols = 2;

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

ff(800,400);
subplot(rows,cols,1);
yyaxis left;
plot(t_eeg,EEG2);
ylim([-200 200]);
ylabel('EEG (\muV)');
set(gca,'ycolor',colors(1,:));

yyaxis right;
plot(t_axy,normalize(OA,'range'),'k-');
xlim([min(t_eeg) max(t_eeg)]);
yticklabels([]);
ylabel('Move (A.U.)');
% xlabel('Time (s)');
set(gca,'fontsize',fs,'ycolor','k');
grid on;
title('EEG and Movement Data');
hold on;

for iHU = 1:size(unloadIntervals,1)
    plot(unloadIntervals(iHU,:),[max(ylim) max(ylim)],'-','color','red','linewidth',4);
    text(mean(unloadIntervals(iHU,:)),max(ylim),'HU','color','r','verticalalignment','top','horizontalalignment','center');
end

[P,F,T] = pspectrum(EEG2,Fs,'spectrogram','FrequencyLimits',FLIMS);
subplot(rows,cols,3);
imagesc(t_eeg,F,P);
set(gca,'ydir','normal');
colormap(magma);
caxis(caxis/climScale);
title('EEG');
xlabel('Time (s)');
ylabel('Freq (Hz)');
set(gca,'fontsize',fs);
title('EEG Spectrogram');
hold on;

for iHU = 1:size(unloadIntervals,1)
    plot(unloadIntervals(iHU,:),[max(ylim) max(ylim)],'-','color','red','linewidth',4);
    text(mean(unloadIntervals(iHU,:)),max(ylim),'HU','color','r','verticalalignment','top','horizontalalignment','center');
end



subplot(rows,cols,[2,4]);
load('loadData_R0001');
FLIMS = [1 30];
blockSize = 5; % sec
blockSample = round(blockSize * Fs);

buffer_EEG2 = [];
all_P_unloaded_EEG2 = [];
iBlock = 0;
for iSample = 1:numel(all_unloadedData_EEG2)
    if numel(buffer_EEG2) < blockSample
        buffer_EEG2 = [buffer_EEG2 all_unloadedData_EEG2(iSample)];
    else
        iBlock = iBlock + 1;
        [P,F] = pspectrum(buffer_EEG2,Fs,'FrequencyLimits',FLIMS);
        all_P_unloaded_EEG2(iBlock,:) = P;
        buffer_EEG2 = [];
    end
end
buffer_EEG2 = [];
all_P_loaded_EEG2 = [];
iBlock = 0;
for iSample = 1:numel(all_loadedData_EEG2)
    if numel(buffer_EEG2) < blockSample
        buffer_EEG2 = [buffer_EEG2 all_loadedData_EEG2(iSample)];
    else
        iBlock = iBlock + 1;
        [P,F] = pspectrum(buffer_EEG2,Fs,'FrequencyLimits',FLIMS);
        all_P_loaded_EEG2(iBlock,:) = P;
        buffer_EEG2 = [];
    end
end

all_pvals = [];
greaterCond = [];
for iFreq = 1:size(all_P_unloaded_EEG2,2)
    y = [all_P_unloaded_EEG2(:,iFreq)' all_P_loaded_EEG2(:,iFreq)'];
    group = [zeros(1,size(all_P_unloaded_EEG2,1)) ones(1,size(all_P_loaded_EEG2,1))];
    all_pvals(iFreq) = anova1(y,group,'off');
end

alpha = 0.05;
nSmooth = 2;

y = smoothdata(mean(all_P_unloaded_EEG2),'gaussian',nSmooth);
ln1 = plot(F,y,'r-','linewidth',2);
hold on;

y = smoothdata(mean(all_P_loaded_EEG2),'gaussian',nSmooth);
ln2 = plot(F,y,'k-','linewidth',2);

colors = lines(5);
sigIds = find(all_pvals < alpha);
ln3 = plot(F(sigIds),0,'|','color',colors(5,:));

xlim([min(F),max(F)]);
xlabel('Freq. (Hz)');
ylabel('Power (|Y|)');
legend([ln1,ln2,ln3(1)],{'HU','Normal','P < 0.05'});
title('EEG Power Spectrum');
set(gca,'fontsize',fs);
hold off;
grid on;

saveas(gcf,'TRISH_3rdYear.png');