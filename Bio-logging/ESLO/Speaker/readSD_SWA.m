fname = '/Volumes/SWA_REC/00033.BIN';
fid = fopen(fname);
A = fread(fid,inf,'int32');
fclose(fid);

%%
doSave = true;
Fs = 125; % Hz
data = A(1:dataLen);
t = linspace(0,dataLen/Fs,dataLen);
trialVars = {'doSham';'dominantFreq';'phaseAngle';'absoluteTime';'msToStim';'targetPhase'};
for ii = 1:numel(trialVars)
    trialVars{ii,2} = A(dataLen + ii);
end

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

subplot(212);
[p,f] = pspectrum(double(data(1:round(dataLen/2))),Fs);
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