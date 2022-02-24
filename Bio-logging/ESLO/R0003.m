if do
    fname = '/Users/matt/Dropbox (University of Michigan)/Biologging/Database/R0003/Recording/ESLORB2.TXT';
    [type,data,labels] = extractSD(fname,5774708);
    SDreport(type,labels);
    dataIntervals = findESLOIntervals_v2(data,type,labels);
    do = 0;
end

esloGain = 12;
cleanThresh = 300;
Fs = 125;
%% forensics on recording
close all
ff;
cols = 1;
useTypes = [0,3,6,7];
rows = numel(useTypes);
for iPlot = 1:numel(useTypes)
    subplot(rows,cols,iPlot);
    dataType = useTypes(iPlot);
    x = find(type==dataType);
    x(x>=5774708) = [];
    plot(data(x),'k');
    title(labels(dataType+1,2));
    xlim([1 numel(x)]);
end
%% data review
close all;
ff(1200,800);

subplot(311);
t_vitals = (1:sum(type==6))/60/24;
plot(t_vitals,double(data(type==6)),'k-');
ylabel('Battery (V)');

yyaxis right;
t_vitals = (1:sum(type==13))/60/24;
plot(t_vitals,double(data(type==13))/1000,'r-');
set(gca,'ycolor','r');
ylabel('Temp (C)');

xlim([min(t_vitals) max(t_vitals)]);
xlabel('Time (days)');
title('Device Vitals (1 sample/minute)');
set(gca,'fontsize',16);
grid on;

trial1_EEG2_id = 33; % 7
all_2 = [];
all_3 = [];
all_axy = [];
for trial1_EEG2_id = 1:33
    trial1_EEG3_id = trial1_EEG2_id + 33; % 55

    axyFs = 10;
    axy = dataIntervals.xl{trial1_EEG2_id};
    EEG2 = ADSgain(double(dataIntervals.data{trial1_EEG2_id}),esloGain); % convert to uV
    EEG2 = cleanEEG(EEG2,cleanThresh);
    EEG3 = ADSgain(double(dataIntervals.data{trial1_EEG3_id}),esloGain); % convert to uV
    EEG3 = cleanEEG(EEG3,cleanThresh);
    all_2 = [all_2 EEG2];
    all_3 = [all_3 EEG3];
    all_axy = [all_axy;axy];
end
t_eeg = linspace(0,numel(all_2)/Fs,numel(all_2))/60/60;
t_axy = linspace(0,size(all_axy,1)/axyFs,size(all_axy,1))/60/60;

subplot(312);
plot(t_axy,all_axy);
xlim([min(t_axy) max(t_axy)]);
xlabel('Time (hrs)');
title(sprintf('Accelerometer (n=%i intervals)',trial1_EEG2_id));
set(gca,'fontsize',16);
legend({'X','Y','Z'});
grid on;
ylabel('2g raw data');

colors = lines(2);
op = 0.2;
subplot(313);
plot(t_eeg,all_2,'color',[colors(1,:) op]);
hold on;
plot(t_eeg,all_3,'color',[colors(2,:) op]);
ylim([-200 200]);
xlim([min(t_eeg) max(t_eeg)]);
xlabel('Time (hrs)');
title(sprintf('Electrophysiology (n=%i intervals)',trial1_EEG2_id));
set(gca,'fontsize',16);
legend({'EEG2','EEG3'});
ylabel('\muV');
grid on;