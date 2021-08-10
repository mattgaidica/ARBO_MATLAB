fname = '/Volumes/LEXAR633X/ESLORB2.TXT';
% [type,data,labels] = extractSD(fname);
SDreport(type,labels);

Fs = 125; % eff: 85Hz
Fs_batt = 1/60; % 1/period
useSamples = Fs*10;
useCh = median(type);
typeIds = type==useCh;
useEEGData = data(typeIds(1:useSamples));
fs = 14;

close all
ff(700,700);
subplot(311);
t_eeg = linspace(0,numel(useEEGData)/Fs,numel(useEEGData));
plot(t_eeg,useEEGData,'k');
xlim([min(t_eeg) max(t_eeg)]);
xlabel('Time (seconds)');
ylabel('\muV');
title('raw data');
grid on;
set(gca,'fontsize',fs);

subplot(312);
[p_spectrum,f_spectrum,t_spectrum] = pspectrum(double(useEEGData),Fs,'spectrogram');
imagesc(t_spectrum,f_spectrum,p_spectrum);
colormap(jet);
set(gca,'ydir','normal');
xlabel('Time (seconds)');
ylabel('Freq (Hz)');
[p,f] = pspectrum(double(useEEGData),Fs);
[v,k] = max(p);
title(sprintf("peak at %2.3f Hz",f(k)));
grid on;
set(gca,'fontsize',fs);

subplot(313);
useBatteryData = data(type==6);
t_batt = linspace(0,numel(useBatteryData)/Fs_batt,numel(useBatteryData)) / 60;
plot(t_batt,useBatteryData,'r');
xlabel('Time (minutes)');
xlim([min(t_batt) max(t_batt)]);
ylabel('V');
title('voltage');
grid on;
set(gca,'fontsize',fs);