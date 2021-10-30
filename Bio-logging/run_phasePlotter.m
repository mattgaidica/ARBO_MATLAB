Fc = 2; 
Fs = 250;                   % samples per second
dt = 1/Fs;                   % seconds per sample
StopTime = 1.6;             % seconds
t = (0:dt:StopTime-dt)';     % seconds
%%Sine wave:                    % hertz
pShift = 180 * (pi/180);
x = cos(2*pi*Fc*t + pShift);


close all
ff(1200,400);
subplot(131);
plot(t,x,'k','linewidth',3);
xlabel('time (in seconds)');
title(sprintf("%1.2fHz",Fc));
% zoom xon;

[X,freq] = positiveFFT_zero_padding(x,Fs,1024);

xlims = [0 20];
subplot(132);
plot(freq,abs(X),'k');
xlim(xlims);

[~,maxIdx] = max(abs(X));
maxFreq = freq(maxIdx);
hold on;
xline(freq(maxIdx));
title(sprintf("Max Freq: %1.2fHz",maxFreq));

phaseAngle = angle(X);
subplot(133);
xlims = [0 20];
plot(freq,phaseAngle,'k');
xlim(xlims);
hold on;
maxAngle = phaseAngle(maxIdx);
xline(freq(maxIdx));
title(sprintf("Max Angle: %1.2fr, %1.2fdeg",maxAngle,maxAngle*(180/pi)));

%%
% Fn = Fs/2;                                                  % Nyquist Frequency
% L  = length(x);
% fts = fft(x)/L;                                        % Normalised Fourier Transform
% Fv = linspace(0, 1, fix(L/2)+1)*Fn;                         % Frequency Vector
% Iv = 1:length(Fv);                                          % Index Vector
% amp_fts = abs(fts(Iv))*2;                                   % Spectrum Amplitude
% phs_fts = angle(fts(Iv));                                   % Spectrum Phase

xlims = [0 20];
subplot(132);
plot(amp_fts,'k');
title('amp');
xlim(xlims);

subplot(133);
plot(phs_fts,'k');
title('phase');
xlim(xlims);

%% calculates delay based on phase degrees
Fs = 2000; % mHz
remPhase = int32([]);
degs = int32(-180*1000:180*1000);
for ii = 1:numel(degs)
    if degs(ii) < 0
        remPhase(ii) = int32(-degs(ii));
    else
        remPhase(ii) = int32((360*1000) - degs(ii));
    end
end
msToStim = int32((1000*remPhase / (360*Fs)));
close all
figure;
plot(degs/1000, msToStim);