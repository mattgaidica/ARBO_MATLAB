if do
    fname = '/Users/matt/Dropbox (University of Michigan)/Biologging/Database/R0010/ESLORB2.TXT';
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

%% respiratory and HR
EEG = ADSgain(double(dataIntervals.data{1}),esloGain);

tEEG = linspace(0,dataIntervals.duration(1),numel(EEG));
close all;
ff(1000,800);

subplot(311);
EEG = detrend(EEG);
plot(tEEG,EEG,'k-','linewidth',1.5);
xlim([min(tEEG) max(tEEG)]);
grid on;
xlabel('Time (s)');
ylabel('\muV');
title('Raw Signal');
set(gca,'fontsize',14);

subplot(312);
EEG_resp = bandpass(EEG,[1 4],Fs);
plot(tEEG,EEG_resp,'b-','linewidth',1.5);
xlim([min(tEEG) max(tEEG)]);
grid on;
xlabel('Time (s)');
ylabel('\muV');
[locs,pks] = peakseek(EEG_resp,100,12);
hold on;
plot(tEEG(locs),pks,'ko');
title(sprintf('Respiratory Filter, ~%1.0f BPM',60/median(diff(tEEG(locs)))));
set(gca,'fontsize',14);

subplot(313);
EEG_card = bandpass(EEG,[10 40],Fs);
plot(tEEG,EEG_card,'r-','linewidth',1.5);
xlim([min(tEEG) max(tEEG)]);
grid on;
xlabel('Time (s)');
ylabel('\muV');
[locs,pks] = peakseek(EEG_card,20,5);
hold on;
plot(tEEG(locs),pks,'ko');
title(sprintf('Cardiac Filter, ~%1.0f BPM',60/median(diff(tEEG(locs)))));
ylim([-10 15]);
set(gca,'fontsize',14);

saveas(gcf,'R0010_respCardFilters.jpg');
%% HR only
EEG = ADSgain(double(dataIntervals.data{2}),esloGain);

close all;
ff(1000,300);
plot(EEG);