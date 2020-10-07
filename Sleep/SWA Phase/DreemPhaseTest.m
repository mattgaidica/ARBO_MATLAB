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
fs = 125;
savePath = '/Users/matt/Documents/MATLAB/ARBO/Sleep/SWA Phase/dreemAnalysis';
eegStart = 12;
if do
    h5file = '/Users/matt/Documents/Data/Sleep/dreem/X_train_KBHhQ0d.h5';
    h5disp(h5file);
    trainfile = '/Users/matt/Documents/Data/Sleep/dreem/y_train_2.csv';
    tr = readmatrix(trainfile);
    data = h5read(h5file,'/features');
    do = false;
end
f1 = 0.25;
f2 = 4;
[A,B,C,D] = ellip(10,0.5,40,[f1/fs*2 f2/fs*2]);
sos = ss2sos(A,B,C,D);

SWA_HA_idx = find(tr(:,2) == 2);
useHA = 15;
% % for useHA = 1:100
%     x = data(eegStart:end,SWA_HA_idx(useHA));
    x = data(end-(4*fs)+1:end,SWA_HA_idx(useHA));

    doDebug = false;
    if doDebug
        t = 0 : 1/fs : 5; % time (0-5s)
        fmod = 3; % Hz
        pdelay = pi;
        x = sin((2*pi*fmod*t) + pi/2 + pdelay); % create test signal
        x = x + rand(size(x))*0.5-0.25;
    end

    y = sosfilt(sos,x);

    [freq,phase] = dominantFFT(y,fs,f1,f2);
    [f,gof] = filterPhaseCorrection(sos,fs,f1,f2);
    correction = wrapToPi(feval(f,freq)); % bound

    t = 1/fs : 1/fs : numel(x)/fs;

    t_mod = 1/fs : 1/fs : (numel(x)+fs*4)/fs;%max(t) + (1/fs : 1/fs : 1); % 1s
    fcast = cos((2*pi*freq*t_mod) + phase);
    fcast_corr = cos((2*pi*freq*t_mod) + phase - correction);

    close all
    h = ff(1400,450);
    subplot(211);
    plot(t,x);
    hold on;
    plot(t,y,'r');
    yyaxis right;
    plot(t_mod,fcast,':','color','r');
    hold on;
    plot(t_mod,fcast_corr,':','color',lines(1));
    legend({'raw','filtered','forecasted','corrected'},'location','northwest');
    xlim([min(t) max(t_mod)]);
    xlabel('Time (s)');
    title({sprintf('f=%1.2fHz, phi=%1.2frad, corr=%1.2frad',freq,phase,correction),...
        sprintf('f1=%1.2fHz, f2=%1.2fHz, r2=%1.3f',f1,f2,gof.rsquare)});

    subplot(212);
    plot(t,x);
    yyaxis right;
    plot(t_mod,fcast_corr,':','color',lines(1));
    xlim([min(t) max(t_mod)]);
    xlabel('Time (s)');
    
    % when will fcast_corr == pi?
    targetPhase = pi;
    phi = phase - correction;
    curPhase = wrapToPi(2*pi*freq*max(t) + phi);
    phaseRem = targetPhase - curPhase;
    
    hold on;
    for ii=1:3
        samplesToTarget = (phaseRem/(2*pi)) * (fs/freq);
        timeToTarget = (samplesToTarget + (ii-1)*(fs/freq))/fs;
        plot([timeToTarget,timeToTarget]+max(t),ylim,'r--');
        text(timeToTarget+max(t),0.5,sprintf('+%1.2fs',timeToTarget),'color','red');
    end
    title(sprintf('target=%1.2frad',targetPhase));
    legend({'raw','corrected','stim1','stim2','stim3'},'location','northwest');
    
% %     saveas(h,fullfile(savePath,sprintf('dreemFiltered_s_%03d.jpg',useHA)));
% %     close(h);
% % end