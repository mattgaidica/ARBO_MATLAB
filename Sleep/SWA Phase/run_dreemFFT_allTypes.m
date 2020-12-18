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
fs = 125;
savePath = '/Users/matt/Documents/MATLAB/ARBO/Sleep/SWA Phase/dreemAnalysis';
eegStart = 12;
if do
    h5file = '/Users/matt/Documents/Data/Sleep/dreem/X_train_KBHhQ0d.h5';
    h5disp(h5file);
    trainfile = '/Users/matt/Documents/Data/Sleep/dreem/y_train_2.csv';
    tr = readmatrix(trainfile);
    data = h5read(h5file,'/features');
    do = false;
end

Hd = eslo_lp_ellip;

nSamples = 1000;
rowType = NaN(nSamples * 3,1);
FFT_P = zeros(nSamples * 3, 5121);
ii = 0;
jj = 0;
tryFeatures = zeros(nSamples,3); % max, traps, sum
while any(isnan(rowType))
    ii = ii + 1;
    if sum(rowType == tr(ii,2)) == nSamples
        continue;
    end
    jj = jj + 1;
    x = data(eegStart:end,ii);
    y = sosfilt(Hd.sosMatrix,x);
    [freq,phase,P,f] = dominantFFT(y,fs,0,fs);
    FFT_P(jj,:) = P;
    rowType(jj) = tr(ii,2);
    
    tryFeatures(jj,1) = max(P(f<=4));
    tryFeatures(jj,2) = trapz(P(f<=4));
    tryFeatures(jj,3) = sum(P(f<=4));
end

%% plot features
close all
ff(800,600);
% plot(rowType,tryFeatures(:,1),'k.');
titles = {'Max','Trapz','Sum'};
for ii = 1:3
    subplot(1,3,ii);
%     beeswarm(rowType,tryFeatures(:,ii),'corral_style','omit','overlay_style','box');
    boxplot(tryFeatures(:,ii),rowType,'plotstyle','compact');
    ylim([0 mean(tryFeatures(rowType==0,ii))+3*std(tryFeatures(rowType==0,ii))]);
    title(titles{ii});
end
clc
[r,p] = corr(rowType,tryFeatures(:,1));
disp(sprintf('Max r=%1.4f, p=%1.2e',r,p));
[r,p] = corr(rowType,tryFeatures(:,2));
disp(sprintf('Trapz r=%1.4f, p=%1.2e',r,p));
[r,p] = corr(rowType,tryFeatures(:,3));
disp(sprintf('Sum r=%1.4f, p=%1.2e',r,p));
%% plot stats
legendText = {'No SWA','Low SWA','High SWA'};
close all
ff(500,400);
for ii = 1:3
    meanP = mean(FFT_P(rowType == ii-1,:));
    plot(f,meanP,'linewidth',2);
    hold on;
end
xlim([0 5]);
legend(legendText);