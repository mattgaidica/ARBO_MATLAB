Fs = 125;

% Each sample represents 10 seconds of recording starting 10 seconds before the end of a slow oscillation.
% Data provided consists of a N x 1261 matrix.

% The prediction is a label in {0, 1, 2}.
% 1. no slow oscillation is starting in the following second.
% 2. a slow oscillation of low amplitude started in the following second.
% 3. a slow oscillation of high amplitude started in the following second
% High and low are defined with respect with the mean amplitude of slow oscillations measured on the whole record.

% Features
% 1. Number of previous slow oscillations
% 2. Mean amplitude of previous slow oscillations
% 3. Mean duration of previous slow oscillations
% 4. Amplitude of the current slow oscillation
% 5. Duration of the current slow oscillation
% 6. Current Sleep stage
% 7. Time elapsed since the person fell asleep
% 8. Time spent in deep sleep so far
% 9. Time spent in light sleep so far
% 10. Time spent in rem sleep so far
% 11. Time spent in wake sleep so far
% to 1261. EEG signal for 10 seconds (sampling frequency: 125Hz -> 1250 data points)
eegStart = 12;
if do
    h5file = '/Users/matt/Documents/Data/Sleep/dreem/X_train_KBHhQ0d.h5';
    h5disp(h5file);
    trainfile = '/Users/matt/Documents/Data/Sleep/dreem/y_train_2.csv';
    tr = readmatrix(trainfile);
    data = h5read(h5file,'/features');
    do = false;
end

targetFs = 44100*2;
adata = [];
for ii=1:10
    adata = [adata;data(eegStart:end,ii)];
end
adata_interp = equalVectors(adata,1:round((targetFs/Fs)*numel(adata)));
audiowrite('test.wav',normalize(adata_interp,'range')*2-1,targetFs);
% soundsc(adata_interp,targetFs);

slow_no = find(tr(:,2)==0);
slow_sm = find(tr(:,2)==1);
slow_lg = find(tr(:,2)==2);
useIds = {slow_no,slow_sm,slow_lg};
dataLabels = {'No SWA','Small SWA','Large SWA'};
close all
ff(1200,800,2);
for iData = 1:3
    subplot(3,1,iData)
    for ii = 1:10
        plot(data(eegStart:end,useIds{iData}(ii)));
        hold on;
    end
    title(dataLabels{iData});
    ylim([-200 200]);
end