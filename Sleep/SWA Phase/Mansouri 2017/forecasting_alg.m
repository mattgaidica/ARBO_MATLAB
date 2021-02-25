%
% Function: forecasting_alg
%
% Inputs:
%
% sig_past: vector holding past signal from the past window
% fs: sampling frequency of sig_past
% fb_low: frequency band lower bound
% fb_high: frequency band upper bound
% K: number of samples to be forecasted
% sos: Second order section filter
%
% Output:
%
% sig: forecasted signal
% 
% For more information refer to:
% Mansouri, Farrokh, et al. "A fast EEG forecasting algorithm for 
% phase-locked transcranial electrical stimulation of the human brain." 
% Frontiers in neuroscience 11 (2017).

function [sig,sig_past,freq,phase] = forecasting_alg(sig_past,fs,fb_low,fb_high,K,sos)

% Correction factor
correction = 0;


% Filtering
L=length(sig_past);
sig_past = sosfilt(sos,sig_past);

% FFT
freq=(10000/2+1-(1:10000))*fs/10000;
y=fftshift(fftn(sig_past,[1 10000]));

% Taking the frequency band
y(freq<fb_low)=0;
y(freq>fb_high)=0;

% Calculating the phase and freq
[~,indx]=max(abs(y));
freq=freq(indx);
phase = angle(y(indx));

% Forecasting
sig = sin(2*pi*(L+1:L+K)*freq/fs-phase+pi/2+correction);

end