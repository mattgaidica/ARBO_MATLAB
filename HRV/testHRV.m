% clc
% close all
Fs = 250;
signal = readmatrix('XX02.csv');
[qrs_amp_raw,qrs_i_raw,delay] = pan_tompkin(signal,Fs,0);
qrs_t = qrs_i_raw / Fs;
RR = diff(qrs_t);

t = linspace(0,numel(signal)/Fs,numel(signal));

figure;
plot(t,signal);
xlabel('time (s)');
ylabel('A');
hold on;
plot(qrs_t,signal(qrs_i_raw),'ro');

figure;
plot(diff(qrs_t));

% see if you can compute the rest of the HRV statistics
HRV.HR(RR);
[pLF,pHF,LFHFratio,VLF,LF,HF,f,Y,NFFT] = HRV.fft_val_fun(RR,Fs);