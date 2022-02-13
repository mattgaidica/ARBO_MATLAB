esloGain = 12;
cleanThresh = 600;
Fs = 125;
axyFs = 10;
FLIMS = [1 30];

blockSize = 5; % seconds
blockSample = round(blockSize*Fs);
axySample = round(blockSize*axyFs);

all_SD = [];
all_FFT = [];
for ii = 1:47
    EEG = -ADSgain(double(dataIntervals.data{ii}),esloGain); % convert to uV
    axy = dataIntervals.xl{ii};
    
    iPos = 0;
    while(1)
        iPos = iPos + 1;
        EEGRange = (iPos-1)*blockSample+1:iPos*blockSample;
        SDRange = (iPos-1)*axySample+1:iPos*axySample;
        
        if EEGRange(end) > numel(EEG) || SDRange(end) > size(axy,1)
            break;
        end
        
        theseEEG = EEG(EEGRange);
        theseEEG = theseEEG - mean(theseEEG);
        if any(abs(theseEEG) > cleanThresh) % noise
            continue;
        end
        [P,F] = pspectrum(theseEEG,Fs,'FrequencyLimits',FLIMS);
        all_FFT = [all_FFT P];
        
        all_SD = [all_SD axySD(axy(SDRange,:))];
    end
end

%%
SDnorm = normalize(all_SD,'range');
nBins = 5;
useBins = linspace(0,1,nBins+1);
FFT_Bins = [];
for iBin = 1:nBins
    OArows = find(SDnorm >= useBins(iBin) & SDnorm < useBins(iBin+1));
    FFT_Bins(iBin,:) = mean(all_FFT(:,OArows),2);
end

colors = magma(nBins);
close all;
ff(1200,600);
lnLabels = {};
lns = [];
for iBin = 1:nBins
    lns(iBin) = plot(F,FFT_Bins(iBin,:),'color',colors(iBin,:),'linewidth',4);
    hold on;
    lnLabels{iBin} = sprintf('axy %1.1f-%1.1f',useBins(iBin),useBins(iBin+1));
end
xlim([min(F),max(F)]);
xlabel('Freq. (Hz)');
ylabel('Power |Y|');
legend(lns,lnLabels);
grid on;
set(gca,'fontsize',16);

