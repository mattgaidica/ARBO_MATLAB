if do
    fname = '/Users/matt/Dropbox (University of Michigan)/Biologging/Database/0008/ESLORB2.TXT';
    [type,data,labels] = extractSD(fname);
    do = 0;
end

SDreport(type,labels);
dataIntervals = findESLOIntervals_v2(data,type,labels);

%%
Fs = 125;
esloGain = 12;
axyFs = 1;

close all

FLIMS = [1 15];
allP = [];
load('SOSG_LP4Hz.mat');
for ii = 1:68
    EEG = ADSgain(double(dataIntervals.data{ii}),esloGain); % convert to uV
    [EEG_clean,locs] = cleanEEG(EEG,250); % clean at 300uV
    if numel(locs) > 200
        continue;
    end
%     EEG_SWA = filtfilt(SOS,G,EEG_clean);
    [P,F,T] = pspectrum(EEG_clean,Fs,'spectrogram','FrequencyLimits',FLIMS);
    allP = [allP P];
end

ff(1400,400);
imagesc(1:size(allP,2),F,allP);
set(gca,'ydir','normal');
colormap(magma);
caxis(caxis/3)