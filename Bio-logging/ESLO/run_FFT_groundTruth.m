clear all
n = 2048;
Fs = 250;
dt = 1/Fs;
StopTime = 10;
t = (0:dt:StopTime-dt)';
t = t(1:n);
Fc = 10;
x = cos(2*pi*Fc*t);

L = numel(t);
n = (2^nextpow2(L));
Y = fft(x,n);
f = Fs*(0:(n/2))/n;
P = abs(Y/n).^2;

close all
ff(800,500);
subplot(211);
plot(x);
title('Signal');

subplot(212);
plot(P(1:n/2+1));
title('half FFT');

writematrix(x','sineVals.csv');