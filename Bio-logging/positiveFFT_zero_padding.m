function [X,freq] = positiveFFT_zero_padding(x,Fs,N)

k = 0:N-1;
T = N/Fs;
freq = k/T;
X = fft(x,N)/length(x);

cutOff = ceil(N/2);

X = X(1:cutOff);
freq = freq(1:cutOff);