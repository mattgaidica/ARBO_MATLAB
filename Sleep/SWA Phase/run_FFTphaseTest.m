fs = 125; % sampling frequency
t = 0 : 1/fs : 5; % time (0-5s)
fmod = 3.15; % Hz
pdelay = 1.6*pi;
x = sin((2*pi*fmod*t) + pi/2 + pdelay); % create test signal
x = x + rand(size(x))*0.5-0.25;

% setup plot
rows = 4;
cols = 1;
close all
figure('position',[0 0 1000 700]);
set(gcf,'color','w');

subplot(rows,cols,1);
plot(t,x); % plot test signal
hold on;
xlabel('Time (s)');
ylabel('Amplitude');
ylim([-1.2 1.2]);

% setup filter
f1 = 0.5;
f2 = 4;
[A,B,C,D] = ellip(10,0.5,40,[f1/fs*2 f2/fs*2]);
sos = ss2sos(A,B,C,D);
y = sosfilt(sos,x); % filter test signal
plot(t,y,'r'); % plot filtered signal
legend({'original','filtered'},'location','northwest');

% setup FFT
L = numel(t);
nPad = 5;
n = (2^nextpow2(L)) * nPad; % force zero padding for interpolation
Y = fft(y,n); % remember, Y is complex
f = fs*(0:(n/2))/n;
P = abs(Y/n).^2; % power of FFT
A = angle(Y); % angle of FFT
grid

Psub = P(1:n/2+1); % make power one-sided
subplot(rows,cols,2);
plot(f,Psub,'r')
xlabel('Frequency (Hz)')
ylabel('|P(f)|^2')
xlim([0 10]);
grid

[v,k] = max(Psub); % find dominant frequency of filtered signal
freq = f(k);
title(sprintf('Dominant @ %1.2fHz',freq));
hold on;
plot(freq,Psub(k),'*');

Asub = A(1:n/2+1); % make phase one-sided
subplot(rows,cols,3);
plot(f,Asub,'r');
xlabel('Frequency (f)')
ylabel('Phase (rad)');
xlim([fmod-2 fmod+2]);
grid

phase = Asub(k); % use k (key) to identify dominant phase
title(sprintf('Phase @ %1.2fHz = %1.2frad',freq,phase));
hold on;
plot(freq,phase,'*');

subplot(rows,cols,4);
t_sig = max(t) + (0 : 1/fs : 1); % time, forecast 1 second
sig = sin((2*pi*freq*t_sig) + pi/2 + phase); % phase-shifted forecast
plot(t,x);
xlabel('Time (s)');
ylabel('Amplitude');
hold on;
plot(t,y,'r');
plot(t_sig,sig,'k');

% kmod = closest(freqs,fmod);
correction = feval(ffreqs,fmod);
sig_corr = sin((2*pi*freq*t_sig) + pi/2 + phase - correction); % phase-shifted forecast
plot(t_sig,sig_corr,'color',lines(1));

legend({'original','filtered','forecasted','corrected'},'location','northwest');
grid
ylim([-1 1]);