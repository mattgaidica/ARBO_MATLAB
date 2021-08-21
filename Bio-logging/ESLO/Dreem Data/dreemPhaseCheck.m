%% Dreem data
fs = 250;
forecastSec = 2;
x = normalize(readmatrix('dreemVals.csv'),'range')*2-1;
x = x(1:512);
Hd = eslo_lp_ellip;

y = normalize(sosfilt(Hd.sosMatrix,x),'range')*2-1;
t = linspace(0,numel(x)/fs,numel(x));

% setup plot
rows = 4;
cols = 1;
close all
figure('position',[0 0 1000 700]);
set(gcf,'color','w');

subplot(rows,cols,1);
plot(t,x,'b'); % plot test signal
hold on;
xlabel('Time (s)');
xlim([min(t) max(t)]);
ylabel('Amplitude');
ylim([-1 1]);

% setup filter
plot(t,y,'r'); % plot filtered signal
legend({'original','filtered'},'location','northwest');

% setup FFT
L = numel(t);
nPad = 4;
n = (2^nextpow2(L)) * nPad; % force zero padding for interpolation
Y = fft(y,n); % remember, Y is complex
f = fs*(0:(n/2))/n;
P = abs(Y/n).^2; % power of FFT
A = angle(Y); % phase of FFT
grid

Psub = P(1:n/2+1); % make power one-sided
subplot(rows,cols,2);
plot(f,Psub,'r')
xlabel('Frequency (f)')
ylabel('|P(f)|^2')
xlim([0 5]);
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
xlim([0 5]);
ylim([-pi pi]);
grid

phase = Asub(k); % use k (key) to identify dominant phase
title(sprintf('Phase @ %1.2fHz = %1.2frad',freq,phase));
hold on;
plot(freq,phase,'*');

subplot(rows,cols,4);
t_sig = max(t) + (0 : 1/fs : forecastSec); % time, forecast 1 second
sig = sin((2*pi*freq*t_sig) + pi/2 + phase); % phase-shifted forecast
plot(t,x);
xlim([0 max(t_sig)]);
xlabel('Time (s)');
ylabel('Amplitude');
hold on;
plot(t,y,'r');
plot(t_sig,sig,'k');
legend({'original','filtered','forecasted'},'location','northwest');
grid
ylim([-1 1]);