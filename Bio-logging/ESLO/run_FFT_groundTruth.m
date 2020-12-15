clear all;
useCos = true;
n = 1024;

if useCos
    Fs = 250;
    t = linspace(0,(1/Fs)*n,n)';
    x = zeros(n,1);
    for Fc = [5,25]
        x = x + cos(2*pi*Fc*t);
    end
    
%     x = x + 1000;
else
    Fs = 125;
    x = readmatrix('dreemVals.csv');
    t = linspace(0,n/Fs,n);
end


L = numel(t);
n = (2^nextpow2(L));
Y = fft(x,n);
f = Fs*(0:(n/2))/n;
P = abs(Y/n); % not squared

A = atan2(imag(Y),real(Y));
% A = angle(Y);
lw = 2;

close all
ff(600,600);
subplot(311);
plot(x,'k','linewidth',lw);
xlim([1 numel(x)]);
title('Signal');
set(gca,'fontsize',14);

subplot(312);
plot(P(1:n/2+1),'k','linewidth',lw);
title('Single-sided FFT');
xlim([1 n/2]);
set(gca,'fontsize',14);
ylabel('|Y|');

subplot(313);
plot(A(1:n/2+1),'k','linewidth',lw);
title('FFT Phase');
xlim([1 n/2]);
ylabel('rad');
set(gca,'fontsize',14);

if useCos
    writematrix(x','sineVals.csv');
end