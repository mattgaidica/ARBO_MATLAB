clear all;
clc;

%%
fs=500;
t=1/fs:1/fs:5;
L=size(t,2);
f=10; % frequency of the signal

% frequency band
f1=8;
f2=14;

% Window sizes
b_size=100; % future window size
h_size=500; % past window size

%% Making artificial Signal

sa=sin(2*pi*f*t+10);
s=sa+0.5*sin(2*pi*3*t);
s=s+0.5*sin(2*pi*17*t);
s=s+0.5*sin(2*pi*30*t+20);
s=s+1*randn(1,L);

%% Filter design

[A,B,C,D] = ellip(10,0.5,40,[f1/fs*2 f2/fs*2]);
sos = ss2sos(A,B,C,D);


%%

stim=zeros(size(s));

tic
for i=1000:b_size:L-b_size
    sig_past=s(i-h_size+1:i);
    sig_past=detrend(sig_past);
    [stim(i+1:i+b_size)]= forecasting_alg(sig_past,fs,f1,f2,b_size,sos);
end
delay=toc;

%% Calculating PLV

h1=hilbert(stim(1000:end));
h2=hilbert(sa(1000:end));
a=angle(h1);
a_g=angle(h2);
dp = a_g-a;
dp(dp>pi)= dp(dp>pi)-2*pi;
dp(dp<-pi)= dp(dp<-pi)+2*pi;
plv=abs(sum(exp(1i*(dp))))/length(dp)

%% Ploting


subplot(3,1,1)
plot(t,stim);
title('Foreccasting');
subplot(3,1,2)
plot(t,sa);
title('desired signal');
subplot(3,1,3);
plot(t,s);
title('original signal');