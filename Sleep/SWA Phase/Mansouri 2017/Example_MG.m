fs = 125;
plotS = 5;
t = 1/fs:1/fs:5;

fmod = 2;
pdelay = 0;
X = cos((2*pi*fmod*t) + pdelay);

close all
ff(800,600);
subplot(311);
plot(t,X);
hold on;
xlabel('Time (s)');
ylabel('Amplitude');

load('Mansouri_equiripple_0-5-4Hz.mat');
% [b,a] = sos2tf(SOS,G);

sig_past = X;
fb_low = 0.5;
fb_high = 4;
K = 1*fs;
sos = SOS;
[sig] = forecasting_alg(sig_past,fs,fb_low,fb_high,K,sos);

t_sig = t(end) + (1/fs:1/fs:1);

plot(t_sig,sig,'r');