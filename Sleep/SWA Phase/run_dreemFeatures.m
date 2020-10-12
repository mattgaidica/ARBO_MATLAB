fs = 125;
eegStart = 12;
if do
    h5file = '/Users/matt/Documents/Data/Sleep/dreem/X_train_KBHhQ0d.h5';
    h5disp(h5file);
    trainfile = '/Users/matt/Documents/Data/Sleep/dreem/y_train_2.csv';
    tr = readmatrix(trainfile);
    data = h5read(h5file,'/features');
    do = false;
end
f1 = 0.5;
f2 = 4;
[A,B,C,D] = ellip(10,0.5,40,[f1/fs*2 f2/fs*2]);
sos = ss2sos(A,B,C,D);
[f,gof] = filterPhaseCorrection(sos,fs,f1,f2);

trainSecs = 3;
compile_P = [];
compile_P_filt = [];
for useHA = 1:10000%numel(SWA_HA_idx)
    fprintf('HA:%03d\n',useHA);
    x = data(eegStart:end,SWA_HA_idx(useHA));
    [~,~,P] = dominantFFT(x,fs,0,fs);
    compile_P(useHA,:) = P;
    y = sosfilt(sos,x);
    [~,~,P,f] = dominantFFT(y,fs,0,fs);
    compile_P_filt(useHA,:) = P;
end

%% PLOT
close all
ff(400,300);
plot(f,smooth(mean(compile_P),1),'color','k','linewidth',2);
hold on;
plot(f,smooth(mean(compile_P_filt),1),'color',lines(1),'linewidth',2);
xlim([0 4]);
set(gca,'fontsize',14);
title('Dreem Data');
ylabel({'','|Y|^2'})
xlabel({'Freq (Hz)',''});
legend('Unfiltered FFT (n=10,000)','Filtered FFT (n=10,000)');