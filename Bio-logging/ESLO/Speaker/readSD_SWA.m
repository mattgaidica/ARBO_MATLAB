% note: there is a lot of typing going on to play nice between C and MATLAB
% i.e. keep values uint32 until adding sign and convert all to double after
fname = '/Volumes/SWA_REC/00013.BIN';
fid = fopen(fname);
A = uint32(fread(fid,inf,'uint32'));
fclose(fid);
% these come from central device
trialVars = {};
trialVars.doSham        = double(A(dataLen + 1));
trialVars.dominantFreq  = double(A(dataLen + 2));
trialVars.phaseAngle    = double(A(dataLen + 3));
trialVars.trialCount    = double(A(dataLen + 4));
trialVars.absoluteTime  = double(A(dataLen + 5));
trialVars.msToStim      = double(A(dataLen + 6));
trialVars.targetPhase   = double(A(dataLen + 7));

doSave = false;
Fs = 125; % Hz
dataLen = numel(A) - numel(fieldnames(trialVars));
t = linspace(0,dataLen/Fs,dataLen);
data = A(1:dataLen);

% add EEG Channel
dataType = bitshift(bitand(data(1),uint32(0xFF000000)),-24);
trialVars.eegChannel    = dataType - 1;

for iData = 1:numel(data)
    data(iData) = bitand(data(iData),uint32(0x00FFFFFF));
    if (bitget(data(iData),24) == 1) % apply sign
        data(iData) = bitor(data(iData),uint32(0xFF000000));
    end
end
data = double(typecast(data,'int32'));

fs = 16;
close all;
ff(1000,600);

subplot(211);
plot(t,data,'k-','linewidth',2);
xlim([min(t), max(t)]);
xticks(min(t):max(t)/8:max(t));
grid on;
xlabel('Time (s)');
ylabel('Amplitude (uV)');
d = datetime(trialVars.absoluteTime,'ConvertFrom','epochtime','timezone','Etc/UTC');
title(sprintf('Recovered SWA (target = %1.1f°)\nat %s',trialVars.targetPhase/1000,...
    datetime(d,'Format','dd-MMM-yyyy HH:mm:ss','timezone','America/Detroit')));
xline(max(t)/2,'r:','linewidth',2);
text(max(t)/2,min(ylim),'DETECT\rightarrow','color','r','fontsize',fs,'verticalalignment','bottom','horizontalalignment','right');
set(gca,'fontsize',fs-2);
stimIdx = closest(t,max(t)/2+(trialVars.msToStim/1000));
xline(t(stimIdx)+0.05,'r-','linewidth',20);
text(t(stimIdx),max(ylim),'STIM\rightarrow','color','r','fontsize',fs,'verticalalignment','top','horizontalalignment','right');

%%
% % % % L = 2048*2; % this is a double-sided FFT, ESLO is one-sided
% % % % fftData = double(data(1:round(dataLen/2)))';
% % % % y = decimate(fftData,2); % also performed on ESLO
% % % % Y = fft(fftData,L);
% % % % P2 = abs(Y/3.6).^2; % this divisor was empirically found, don't know why it is required
% % % % P1 = P2(1:L/2+1);
% % % % P1(2:end-1) = 2*P1(2:end-1);
% % % % close all
% % % % figure;
% % % % plot(P1);
% % % % xlim([1 90]);
%%

subplot(212);
[p,f] = pspectrum(fftData,Fs);
[v,k] = max(p);
plot(f,p,'k-','linewidth',2);
hold on;
plot(f(k),v,'k.','markersize',35);
xline(f(k));
title('SWA FFT (0–DETECT)');
xlim([0 10]);
xlabel('Freq (Hz)');
ylabel('|Y|');
text(f(k)+0.2,v,sprintf("%1.2f Hz",f(k)),'color','k','fontsize',fs);
set(gca,'fontsize',fs-4);

if doSave
    stripfn = strrep(fname,'/','');
    saveas(gcf,stripfn(1:end-4) + ".png");
end