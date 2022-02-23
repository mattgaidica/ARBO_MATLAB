if do
    fname = '/Users/matt/Dropbox (University of Michigan)/Biologging/Database/R0003/Recording/ESLORB2.TXT';
    [type,data,labels] = extractSD(fname,5774708);
    SDreport(type,labels);
    dataIntervals = findESLOIntervals_v2(data,type,labels);
    do = 0;
end

esloGain = 12;
cleanThresh = 300;
Fs = 125;
%% forensics on recording
close all
ff;
cols = 1;
useTypes = [0,3,6,7];
rows = numel(useTypes);
for iPlot = 1:numel(useTypes)
    subplot(rows,cols,iPlot);
    dataType = useTypes(iPlot);
    x = find(type==dataType);
    x(x>=5774708) = [];
    plot(data(x),'k');
    title(labels(dataType+1,2));
    xlim([1 numel(x)]);
end
%% SWA ratio playground
% find a good interval
FLIMS = [1 12];
trial1_EEG2_id = 6;

axyFs = 10;
axy = dataIntervals.xl{trial1_EEG2_id};
EEG2 = ADSgain(double(dataIntervals.data{trial1_EEG2_id}),esloGain); % convert to uV
EEG2 = detrend(EEG2);

t_eeg = linspace(0,numel(EEG2)/Fs,numel(EEG2));
t_axy = linspace(0,size(axy,1)/axyFs,size(axy,1));

EEG_SWA = bandpass(EEG2,[0.5 4],Fs);

% close all;
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
ln1 = plot(t_eeg,EEG2,'k');
hold on;
plot(t_eeg,EEG_SWA,'r-');
xlim([min(t_eeg) max(t_eeg)]);
ylim([-200 200]);
ylabel('uV');
xlabel('Time (s)');

[P,F,T] = pspectrum(EEG2,Fs,'spectrogram','FrequencyLimits',FLIMS);
ax3 = subplot(413);
imagesc(t_eeg,F,P);
set(gca,'ydir','normal');
colormap(magma);
caxisauto(P);
title('EEG2');
xlabel('Time (s)');
ylabel('Freq (Hz)');
hold on;

ratioF = [0.5,4];
windowSamples = Fs;
ratioArr = NaN(size(EEG2));
M = movstd(double(axy(:,1)),10); % isMoving
for ii = 1:numel(EEG2)
    useRange = ii-windowSamples:ii+windowSamples-1;
    if ii > windowSamples && ii < numel(EEG2) - windowSamples
        axyRange = find(t_axy >= t_eeg(min(useRange))-5 & t_axy < t_eeg(max(useRange))+5);
        if all(M(axyRange) < 190)
            theseData = EEG2(useRange);
            [P,F] = pspectrum(theseData,Fs);
            lowerPower = mean(P(F >= ratioF(1,1) & F < ratioF(1,2)));
            upperPower = mean(P(F > ratioF(1,2)));
            ratioArr(ii) = lowerPower / upperPower;
        end
    end
end
ax4 = subplot(414);
plot(t_eeg,ratioArr,'k');
ylim([0 100]);

linkaxes([ax1 ax2 ax3 ax4],'x');