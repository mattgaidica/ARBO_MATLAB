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
f1 = 0.25;
f2 = 4;
[A,B,C,D] = ellip(10,0.5,40,[f1/fs*2 f2/fs*2]);
sos = ss2sos(A,B,C,D);

SWA_HA_idx = find(tr(:,2) == 2);
trainSec = 1;
testSec = 1;
arOrder = 3;
plv_ar = [];
plv_fft = [];
plv_ctrl = [];
for useHA = 1:100
    disp(useHA);
    x = data(end-((trainSec+testSec)*fs)+1:end,SWA_HA_idx(useHA));
    y = sosfilt(sos,x);
    train_data = y(1:fs*trainSec);
    test_data = y(end-fs*testSec+1:end);

    xid = iddata(train_data,[]);
    sys = ar(xid,arOrder,'yw','ppw');
    K = numel(test_data);
    p = forecast(sys,xid,K);
    fcast_data_ar = p.y;

    [freq,phase] = dominantFFT(train_data,fs,f1,f2);
    [f,gof] = filterPhaseCorrection(sos,fs,f1,f2);
    correction = wrapToPi(feval(f,freq)); % bound
    t_mod = 1/fs : 1/fs : (numel(x)+fs*testSec)/fs;
    fcast_corr = cos((2*pi*freq*t_mod) + phase - correction);
    fcast_data_fft = fcast_corr(end-fs+1:end)';
    
    % control
    ctrl_freq = randsample([f1:.01:f2],1);
    ctrl_phase = rand*2*pi;
    fcast_corr_ctrl = cos((2*pi*ctrl_freq*t_mod) + ctrl_phase);
    fcast_data_ctrl = fcast_corr_ctrl(end-fs+1:end)';

    % PLV
    h_test = angle(hilbert(test_data));
    h_ar = angle(hilbert(fcast_data_ar));
    h_fft = angle(hilbert(fcast_data_fft));
    h_ctrl = angle(hilbert(fcast_data_ctrl));
    
    dp_ar = wrapToPi(h_ar - h_test);
    dp_fft = wrapToPi(h_fft - h_test);
    dp_ctrl = wrapToPi(h_ctrl - h_test);
    
    plv_ar(useHA) = abs(sum(exp(1i*(dp_ar))))/length(dp_ar);
    plv_fft(useHA) = abs(sum(exp(1i*(dp_fft))))/length(dp_fft);
    plv_ctrl(useHA) = abs(sum(exp(1i*(dp_ctrl))))/length(dp_ctrl);
end
close all
anova1([plv_ctrl plv_ar plv_fft],[zeros(size(plv_ctrl)) ones(size(plv_ar)) ones(size(plv_fft))*2])
ylabel('PLV');
xticklabels({'CTRL','AR3','FFT'});