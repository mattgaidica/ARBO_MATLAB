function [freq,phase] = dominantFFT(x,fs,f1,f2)
doDebug = false;

L = numel(x);
nPad = 5;
n = (2^nextpow2(L)) * nPad; % force zero padding for interpolation
Y = fft(x,n); % remember, Y is complex
Y = Y(1:n/2+1); % one-sided
f = fs*(0:(n/2))/n;
P = abs(Y/n).^2; % power of FFT
A = angle(Y); % angle of FFT
% % % % Psub = P(1:n/2+1); % make power one-sided
P(f < f1) = 0;
P(f > f2) = 0;
[~,k] = max(P); % find dominant frequency of filtered signal
freq = f(k);
phase = A(k);

if doDebug
    figure;
    plot(f,P);
    xlim([0 10]);
end