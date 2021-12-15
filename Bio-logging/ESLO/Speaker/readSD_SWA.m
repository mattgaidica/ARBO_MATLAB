% note: there is a lot of typing going on to play nice between C and MATLAB
% i.e. keep values uint32 until adding sign and convert all to double after
fname = '/Volumes/SWA_REC/00001.BIN';
fid = fopen(fname);
A = uint32(fread(fid,inf,'uint32'));
fclose(fid);
% these come from central device
trialVars = {'doSham';'dominantFreq';'phaseAngle';'absoluteTime';'msToStim';'targetPhase'};

doSave = false;
Fs = 125; % Hz
dataLen = numel(A) - numel(trialVars);
t = linspace(0,dataLen/Fs,dataLen);
for ii = 1:numel(trialVars)
    trialVars{ii,2} = double(A(dataLen + ii));
end
data = A(1:dataLen);
dataType = bitshift(bitand(data(1),uint32(0xFF000000)),-24);
trialVars{size(trialVars,1)+1,1} = 'eegChannel';
trialVars{size(trialVars,1),2} = dataType - 1;
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
title(sprintf('Recovered SWA (target = %1.1f°)',trialVars{6,2}/1000));
xline(max(t)/2,'r:','linewidth',2);
text(max(t)/2,min(ylim),'DETECT\rightarrow','color','r','fontsize',fs,'verticalalignment','bottom','horizontalalignment','right');
set(gca,'fontsize',fs-2);
stimIdx = closest(t,max(t)/2+(trialVars{5,2}/1000));
xline(t(stimIdx)+0.05,'r-','linewidth',20);
text(t(stimIdx),max(ylim),'STIM\rightarrow','color','r','fontsize',fs,'verticalalignment','top','horizontalalignment','right');

%%
L = 2048*2; % this is a double-sided FFT, ESLO is one-sided
fftData = double(data(1:round(dataLen/2)))';
y = decimate(fftData,2); % also performed on ESLO
Y = fft(fftData,L);
P2 = abs(Y/3.6).^2; % this divisor was empirically found, don't know why it is required
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);
close all
figure;
plot(P1);
xlim([1 90]);
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