if do
    x = readtable('/Users/matt/Desktop/currentExport.csv');
    y = [];
    for ii = 1:numel(x)
        y(ii) = str2num(x.Current_uinteger{ii});
    end
    x = y;
    clear y;
    do = false;
end

L = numel(x);
fs = L/5; % recorded 5s of data
n = (2^nextpow2(L)); % force zero padding for interpolation
Y = fft(x,n); % remember, Y is complex
Y = Y(1:n/2+1); % one-sided
f = fs*(0:(n/2))/n;
P = abs(Y/n).^2; % power of FFT

close all
figure;
plot(f,P);
ylim([0 3*10^9]);
xlim([0 fs/2]);

meanPeriod = mean(diff(xs));
oscFreq = 1/(meanPeriod/fs);
fprintf('%1.0f Hz\n',oscFreq);