fs = 125; % sampling frequency
t = 0 : 1/fs : 500; % time (0-5s)

f1 = 0.5;
f2 = 4;
[A,B,C,D] = ellip(10,0.5,40,[f1/fs*2 f2/fs*2]);
sos = ss2sos(A,B,C,D);

freqs = linspace(0.5,4,1000);
resp = [];
for ii=1:numel(freqs)
    fmod = freqs(ii);
    x = sin((2*pi*fmod*t) + pi/2); % create test signal
    y = sosfilt(sos,x); % filter test signal
    L = numel(t);
    nPad = 5;
    n = (2^nextpow2(L)) * nPad; % force zero padding for interpolation
    Y = fft(y,n); % remember, Y is complex
    f = fs*(0:(n/2))/n;
    P = abs(Y/n).^2; % power of FFT
    A = angle(Y); % angle of FFT
    Psub = P(1:n/2+1); % make power one-sided
    Asub = A(1:n/2+1); % make phase one-sided
    [v,k] = max(Psub);
    f(k)
    phase = Asub(k);
    resp(ii) = phase;%finddelay(x,y);
end
% close all
ff(600,400);
plot(freqs,resp);
% xlim([0.5 4]);
ylim([-pi pi]);
xlabel('Dominant Freq (Hz)');
ylabel('Phase Shift (rad)');
grid

ff(600,400);
[ffreqs,gof] = fit(freqs',unwrap(resp)','poly3');
plot(ffreqs,freqs',unwrap(resp)');
xlabel('Dominant Freq (Hz)');
ylabel('Phase Shift (rad)');
grid