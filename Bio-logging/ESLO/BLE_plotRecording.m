Fs = 250;
recPath = '/Users/matt/Documents/MATLAB/ARBO/Bio-logging/ESLO/recordings/';
% file = '20201201-104335_ch2_500mHz-10mVpp.csv'; % 0.5Hz
% file = '20201201-112136_HR.csv'; % HR
file = '';

if isempty(file)
    [file,path] = uigetfile(fullfile(recPath,'*.csv'),'Select a recording...');
end

if ~isempty(path)
    A = readmatrix(fullfile(path,file));
    A = reshape(A',1,[]);
    A(isnan(A)) = [];
    t = linspace(0,numel(A)/Fs,numel(A));
    
    % do FFT
    L = numel(t);
    nPad = 5;
    n = (2^nextpow2(L)) * nPad;
    Y = fft(A,n);
    f = Fs*(0:(n/2))/n;
    P = abs(Y/n).^2;
    
    %     close all
    ff(1200,500);
    
    subplot(211);
    plot(t,A,'k');
    xlim([min(t) max(t)]);
    xlabel('Time (s)');
    ylabel('a.u.');
    set(gca,'fontsize',14);
    title(file,'Interpreter','None');
    
    subplot(212);
    plot(f,P(1:n/2+1),'k');
    xlabel('Frequency (f)');
    ylabel('|P(f)|^2');
    xlim([0 5]);
end