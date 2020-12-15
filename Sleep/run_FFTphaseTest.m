% see https://www.mathworks.com/matlabcentral/answers/604459-finding-dominant-frequency-and-phase-using-fft

Fs = 125;
plotS = 5;
t = linspace(0,plotS,plotS*Fs);

fmod = 5;
pdelay = 0;
X = sin((2*pi*fmod*t) + pdelay);

close all
ff(800,600);
subplot(311);
plot(t,X);
hold on;
xlabel('Time (s)');
ylabel('Amplitude');

% load('Mansouri_equiripple_0-5-4Hz.mat');
% [b,a] = sos2tf(SOS,G);
% y = filter(b,a,X);
% plot(t,y);

L = numel(t);
nPad = 5;
n = (2^nextpow2(L)) * nPad;
Y = fft(X,n);
f = Fs*(0:(n/2))/n;
P = abs(Y/n).^2;
A = angle(Y);
Atan = atan2(imag(Y),real(Y));
grid

subplot(312);
plot(f,P(1:n/2+1))
xlabel('Frequency (f)')
ylabel('|P(f)|^2')
xlim([0 10]);
grid

Asub = A(1:n/2+1);
Atansub = Atan(1:n/2+1);
subplot(313);
plot(f,Asub);
hold on;
plot(f,Atansub,'r:');
xlabel('Frequency (f)')
ylabel('Phase (rad)');
xlim([fmod-2 fmod+2]);
grid