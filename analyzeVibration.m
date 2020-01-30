% filename = '/Volumes/ARBO/ANALOG08.TXT'; % natural at 5000ms
filename = '/Volumes/ARBO/ANALOG25.TXT'; % natural at 30000ms
vib = readmatrix(filename);

actualMs = 30000;
tvib = linspace(0,actualMs/1000,numel(vib));
Fs = numel(vib) / (actualMs / 1000); % Hz

T = 1/Fs; % Sample time
L = length(vib); % Length of signal
t = (0:L-1)*T; % Time vector
NFFT = 2^nextpow2(L); % Next power of 2 from length of y
f = Fs/2*linspace(0,1,NFFT/2+1);
Y = fft(double(vib),NFFT)/L;
A = 2*abs(Y(1:NFFT/2+1));

close all
rows = 3;
cols = 1;
ff(800,800);

subplot(rows,cols,1);
plot(tvib,vib);
xlabel('time (s)');
title('Raw Data');

subplot(rows,cols,2);
semilogy(f,A);
xlabel('frequency (Hz)')
ylabel('|Y(f)|')
xlim([min(f) max(f)]);
title('FFT');

subplot(rows,cols,3);
semilogy(f,A); % was semilogy
xlabel('frequency (Hz)')
ylabel('|Y(f)|')
xlim([0 25]);
title('FFT');
