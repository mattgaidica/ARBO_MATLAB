if do
    fname = '/Users/matt/Dropbox (University of Michigan)/Biologging/Database/R0009/ESLORB2.TXT';
    [type,data,labels] = extractSD(fname);
    SDreport(type,labels);
    dataIntervals = findESLOIntervals_v2(data,type,labels);
    do = 0;
end

esloGain = 12;
cleanThresh = 300;
Fs = 125;
%%
% close all;
ff(800,400);

t_vitals = (1:sum(type==6))/60/24;
plot(t_vitals,double(data(type==6))/1000,'k-');
ylabel('Battery (V)');
ylim([2.5 3]);

% % % % yyaxis right;
% % % % t_vitals = (1:sum(type==13))/60/24;
% % % % plot(t_vitals,double(data(type==13))/1000,'r-');
% % % % set(gca,'ycolor','r');
% % % % ylabel('Temp (C)');

xlim([min(t_vitals) max(t_vitals)]);
xlabel('Time (days)');
title('Device Vitals (1 sample/minute)');
set(gca,'fontsize',16);
grid on;

%% EEG4 is HR
useId = 2350;

EEG = ADSgain(double(dataIntervals.data{useId}),esloGain);
tEEG = linspace(0,dataIntervals.duration(useId),numel(EEG));
close all;
ff(1000,600);

subplot(211);
EEG = detrend(EEG);
plot(tEEG,EEG,'k-','linewidth',1.5);
xlim([min(tEEG) max(tEEG)]);
grid on;
xlabel('Time (s)');
ylabel('\muV');
title('Raw Signal');
set(gca,'fontsize',14);

subplot(212);
EEG_card = bandpass(EEG,[5 40],Fs);
plot(tEEG,EEG_card,'k-','linewidth',1.5);
xlim([min(tEEG) max(tEEG)]);
grid on;
xlabel('Time (s)');
ylabel('\muV');
title('Filtered');
set(gca,'fontsize',14);
ylim([-40 40]);

% % saveas(gcf,'R0010_respCardFilters.jpg');
%% EEG2 (frontal)
useId = 15;

EEG = ADSgain(double(dataIntervals.data{useId}),esloGain);
tEEG = linspace(0,dataIntervals.duration(useId),numel(EEG));
close all;
ff(1000,600);

subplot(211);
EEG = detrend(EEG);
plot(tEEG,EEG,'k-','linewidth',1.5);
xlim([min(tEEG) max(tEEG)]);
grid on;
xlabel('Time (s)');
ylabel('\muV');
title('Raw Signal');
set(gca,'fontsize',14);

subplot(212);
EEG_card = bandpass(EEG,[1 40],Fs);
plot(tEEG,EEG_card,'k-','linewidth',1.5);
xlim([min(tEEG) max(tEEG)]);
grid on;
xlabel('Time (s)');
ylabel('\muV');
title('Filtered');
set(gca,'fontsize',14);
ylim([-100 100]);

%% EEG3 (frontal)
useId = 175;

EEG = ADSgain(double(dataIntervals.data{useId}),esloGain);
tEEG = linspace(0,dataIntervals.duration(useId),numel(EEG));
close all;
ff(1000,600);

subplot(211);
EEG = detrend(EEG);
plot(tEEG,EEG,'k-','linewidth',1.5);
xlim([min(tEEG) max(tEEG)]);
grid on;
xlabel('Time (s)');
ylabel('\muV');
title('Raw Signal');
set(gca,'fontsize',14);

subplot(212);
EEG_card = bandpass(EEG,[1 40],Fs);
plot(tEEG,EEG_card,'k-','linewidth',1.5);
xlim([min(tEEG) max(tEEG)]);
grid on;
xlabel('Time (s)');
ylabel('\muV');
title('Filtered');
set(gca,'fontsize',14);
ylim([-100 100]);