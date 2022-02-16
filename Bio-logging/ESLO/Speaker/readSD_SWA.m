% note: there is a lot of typing going on to play nice between C and MATLAB
% i.e. keep values uint32 until adding sign and convert all to double after
% fname = '/Volumes/SWA_REC/00038.BIN';
% !! investigate 229-232, 346-349 (348 is likely K-complex)
Fs = 125; % Hz
doSave = false;
fname = '/Users/matt/Dropbox (University of Michigan)/Biologging/Database/R0003/SWA Trials/00349.BIN';
[trialVars,EEG,t] = extractSWATrial(fname,Fs);
EEG = detrend(EEG);

[EEG_SWA, bpdf] = bandpass(EEG, [0.5 4], 125); % can also: filtfilt(bpdf,EEG_SWA)
fftData = EEG(1:round(numel(EEG)/2))';

fs = 16;
close all;
ff(1000,600);

subplot(211);
plot(t,EEG,'k-','linewidth',2);
ylabel('Raw (uV)');

yyaxis right;
plot(t,EEG_SWA,'r-');
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
xline(t(stimIdx)+0.05,'r-','linewidth',20,'alpha',0.2);
text(t(stimIdx),max(ylim),'STIM\rightarrow','color','r','fontsize',fs,'verticalalignment','top','horizontalalignment','right');

% % % % L = 2048*2; % this is a double-sided FFT, ESLO is one-sided
% % % % y = decimate(fftData,2); % also performed on ESLO
% % % % Y = fft(fftData,L);
% % % % P2 = abs(Y/3.6).^2; % this divisor was empirically found, don't know why it is required
% % % % P1 = P2(1:L/2+1);
% % % % P1(2:end-1) = 2*P1(2:end-1);
% % % % close all
% % % % figure;
% % % % plot(P1);
% % % % xlim([1 90]);

FLIMS = [0.5 10];
subplot(212);
padFFT = padarray(fftData,[0,numel(fftData)*10],0,'post');
[p,f] = pspectrum(padFFT,Fs,'FrequencyLimits',FLIMS);
[v,k] = max(p);
plot(f,p,'k-','linewidth',2);
hold on;
plot(f(k),v,'k.','markersize',35);
xline(f(k));
title('Offline FFT Estimation (0–DETECT)');
xlim([min(FLIMS) max(FLIMS)]);
xlabel('Freq (Hz)');
ylabel('|Y|');
text(f(k)+0.2,v,sprintf("%1.2f Hz",f(k)),'color','k','fontsize',fs);
set(gca,'fontsize',fs-4);

if doSave
    [~,name] = fileparts(fname);
    saveas(gcf,"Trial" + name + ".png");
end