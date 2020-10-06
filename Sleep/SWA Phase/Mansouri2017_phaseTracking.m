Fs = 125;

% Each sample represents 10 seconds of recording starting 10 seconds before the end of a slow oscillation.
% Data provided consists of a N x 1261 matrix.

% The prediction is a label in {0, 1, 2}.
% 1. no slow oscillation is starting in the following second.
% 2. a slow oscillation of low amplitude started in the following second.
% 3. a slow oscillation of high amplitude started in the following second
% High and low are defined with respect with the mean amplitude of slow oscillations measured on the whole record.

% Features
% 1. Number of previous slow oscillations
% 2. Mean amplitude of previous slow oscillations
% 3. Mean duration of previous slow oscillations
% 4. Amplitude of the current slow oscillation
% 5. Duration of the current slow oscillation
% 6. Current Sleep stage
% 7. Time elapsed since the person fell asleep
% 8. Time spent in deep sleep so far
% 9. Time spent in light sleep so far
% 10. Time spent in rem sleep so far
% 11. Time spent in wake sleep so far
% to 1261. EEG signal for 10 seconds (sampling frequency: 125Hz -> 1250 data points)
eegStart = 12;
if do
    h5file = '/Users/matt/Documents/Data/Sleep/dreem/X_train_KBHhQ0d.h5';
    h5disp(h5file);
    trainfile = '/Users/matt/Documents/Data/Sleep/dreem/y_train_2.csv';
    tr = readmatrix(trainfile);
    data = h5read(h5file,'/features');
    do = false;
end

ii = 12;
sampleS = 10;
x = data(eegStart:(Fs*sampleS-1),ii);
                  
T = 1/Fs;             % Sampling period       
L = numel(x)*10;             % Length of signal + padding!
f = Fs*(0:(L/2))/L; % note padding in L
t = (0:numel(x)-1)*T;        % Time vector non-padded

% TEST SIGNAL
fmod = 2;
pdelay = 2.5;
x = sin((2*pi*fmod*t) + pdelay);

load('Mansouri_equiripple_0-5-4Hz.mat');
useFiltFilt = false;
if useFiltFilt
    y = filtfilt(SOS,G,x);
else
    [b,a] = sos2tf(SOS,G);
    y = filter(b,a,x);
end

Y = fft(y,L);
Y1 = Y(1:L/2+1); % use to extract angle

P2 = abs(Y/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);

lw = 1.5;
close all
ff(800,600);
subplot(311);
plot(t,normalize(x,'range'),'k','linewidth',lw);
hold on;
plot(t,normalize(y,'range'),'r','linewidth',lw);
xlabel('Time (s)');
legend('original','filt','location','northwest');
xlim([min(t) max(t)]);

subplot(312);
plot(f,P1,'k','linewidth',lw) 
xlabel('f (Hz)')
ylabel('|P1(f)|')
xlim([0 10]);

[v,k] = max(P1); % !! probably limit this to 0-4Hz
hold on;
F = f(k);
plot(F,v,'r*');
p = angle(Y1(k));
title({'Single-Sided Amplitude Spectrum of X(t)',sprintf('%1.2fHz @ %1.2frad',F,p)});

phi = phasedelay(SOS,[F F],Fs);


figure;
phasedelay(SOS,512,Fs)
xlim([0 10]);

subplot(313);
plot(t,normalize(y,'range'),'r','linewidth',lw);
hold on;
if useFiltFilt
    Fcast = sin((2*pi*F)*t);
else
    Fcast = sin((2*pi*F*t) + p);
    Fcast = circshift(Fcast,-finddelay(Fcast,y));
end
plot(t,normalize(Fcast,'range'),'b','linewidth',lw);
xlabel('Time (s)');
title('Signal');
xlim([min(t) max(t)]);
legend('filt','forecast','location','northwest');