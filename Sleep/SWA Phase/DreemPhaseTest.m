fs = 125;

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

SWA_HA_idx = find(tr(:,2) == 2);
% % sampleS = 10;
x = data(:,SWA_HA_idx(2));
x = x(eegStart:end);
t = 1/fs : 1/fs : numel(x)/fs;

fb_low = 0.5;
fb_high = 4;
K = fs; % forecast 1 second
load('Mansouri_equiripple_0-5-4Hz.mat');



close all
ff(1000,500);
plot(t,normalize(x,'range')*2-1);
hold on;
plot(t,normalize(sig_past,'range')*2-1);
plot(t_sig,sig,'r');