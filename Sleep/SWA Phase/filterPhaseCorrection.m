function [f,gof] = filterPhaseCorrection(sos,fs,f1,f2)
doDebug = false;

t = 0 : 1/fs : 50; % time, substantially long
L = numel(t);
nPad = 5;

freqs = linspace(f1,f2,100);
resp = zeros(size(freqs));
for ii = 1:numel(freqs)
    fmod = freqs(ii);
    x = sin((2*pi*fmod*t) + pi/2); % create test signal
    y = sosfilt(sos,x); % filter test signal
    n = (2^nextpow2(L)) * nPad; % force zero padding for interpolation
    Y = fft(y,n); % remember, Y is complex
    f = fs*(0:(n/2))/n;
    P = abs(Y/n).^2; % power of FFT
    A = angle(Y); % angle of FFT
    Psub = P(1:n/2+1); % make power one-sided
    Asub = A(1:n/2+1); % make phase one-sided
    [~,k] = max(Psub);
    resp(ii) = Asub(k);
end

[f,gof] = fit(freqs',unwrap(resp)','poly3');

if doDebug
    ff(600,400);
    plot(f,freqs',unwrap(resp)');
    xlabel('Dominant Freq (Hz)');
    ylabel('Phase Shift (rad)');
    grid
end