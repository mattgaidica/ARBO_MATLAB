function SWA_locs = slowWaveDetect(EEG_SWA,Fs)
doPlot = 0;

sd_mult = 1.5;
SWA_sd = std(EEG_SWA);
[pos_locs, pos_pks] = peakseek(EEG_SWA,Fs/2,SWA_sd*sd_mult); % min 0.5Hz peaks
[neg_locs, neg_pks] = peakseek(-EEG_SWA,Fs/2,SWA_sd*sd_mult); % min 0.5Hz peaks

nPeaks = 3;
% perform search w/ criteria
SWA_locs = [];
SWA_pks = [];
for iPos = 1:numel(pos_locs)
    if iPos+nPeaks-1 > numel(pos_locs)
        continue; % not enough peaks
    end
    nextPos = pos_locs(iPos:iPos+nPeaks-1);
    nextNeg = neg_locs(find(neg_locs > pos_locs(iPos),nPeaks));
    if numel(nextNeg) < nPeaks
        continue; % not enough peaks
    end
    if all(nextNeg-nextPos > Fs*0.5 & nextNeg-nextPos < Fs*4)
        SWA_locs = [SWA_locs pos_locs(iPos)];
        SWA_pks = [SWA_pks pos_pks(iPos)];
    end
end

if doPlot
    t = linspace(0,numel(EEG_SWA)/Fs,numel(EEG_SWA));
    ff(1200,600);
    plot(EEG_SWA,'k-');
    hold on;
    plot(SWA_locs,SWA_pks,'go');
    plot(pos_locs,pos_pks,'rx');
    plot(neg_locs,-neg_pks,'kx');
    xlim([1 Fs*10]);
end