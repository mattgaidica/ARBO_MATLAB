% function writeTrialForCMSIS()
% review for algo: 358,368 looks mis-timed, 361,367 would be good for exclusion
% criteria, 369 looks like higher power in lower freq, 
Rat = 3;
fname = '/Users/matt/Dropbox (University of Michigan)/Biologging/Database/R0003/SWA Trials/00362.BIN';

Fs = 125;
writePath = '/Users/matt/Documents/Software/ESLO-Libraries/FFT';
[~,name] = fileparts(fname);
[trialVars,EEG,t,rawEEG] = extractSWATrial(fname,Fs);
EEG_detect = rawEEG(1:round(numel(rawEEG)/2));
t_detect = t(1:round(numel(rawEEG)/2));
fileID = fopen(fullfile(writePath,sprintf('R%04d_%s.h',Rat,name)),'w');
fprintf(fileID,'extern int32_t swaBuffer[SWA_LEN * 2] = {');
fprintf(fileID,'%i,\n',EEG_detect(1:end-1));
fprintf(fileID,'%i};\n',EEG_detect(end));
fclose(fileID);

coeffs = CMSISFilter(0.5,4,Fs,EEG_detect,1);

%% how does tail end power compare to full?
colors = jet(128);
ff(1200,600);
lns = [];
for ii = 1:16:128
    dataFilt = bandpass(EEG_detect,[1 20],Fs);
    [P,F] = pspectrum(dataFilt(ii:end),Fs);
    lns(ii) = plot(F,P,'-','color',colors(ii,:),'linewidth',2);
    hold on;
end
legend([lns(1) lns(end)],{'full 2s','last 1s'});
xlim([0 20]);