%% for MCU
filtOrder = 10;
f1 = 0.5;
f2 = 4;
att = 40;
ripple = 0.5;
plot_results = true;
fs = 250;

coeffs = design_iir_bandpass_cmsis_elliptical(filtOrder,ripple,att,f1,f2,fs,plot_results);
writematrix(coeffs','eslo_ellip_coeffs.csv');

%% Dreem data
% x = readmatrix('dreemVals.csv');
x = readmatrix('sineVals.csv');
requested_order = 10;
f1 = 0.5;
f2 = 4;
att = 40;
ripple = 0.5;
fs = 250;
x2 = equalVectors(x,numel(x)*2);

writematrix(x2,'x2.csv');

filtOrder = requested_order/2;
fNyquist = fs/2;

% CMSIS COEFFS
[z,p,k] = ellip(filtOrder,ripple,att,f2/fNyquist,'low');
[sos] = zp2sos(z,p,k);
% compute biquad coefficients
coeffs = sos(:,[1 2 3 5 6]);
% negate a1 and a2 coeffs (CMSIS expects them negated)
coeffs(:,4) = -coeffs(:,4);
coeffs(:,5) = -coeffs(:,5);
% make a linear array of it
coeffs = coeffs';
coeffs = coeffs(:);
clc;
str = sprintf('%1.10ff,\n',coeffs);
disp(str(1:end-2));
% END COEFFS

% [b,a] = ellip(filtOrder,ripple,att,[f1 f2]/fNyquist);
[b,a] = ellip(filtOrder,ripple,att,f2/fNyquist,'low');
filtered = filter(b,a,x2);

close all
t = linspace(0,numel(x2)/fs,numel(x2));
ff(1000,400);
plot(t,x2,'r');
hold on;
plot(t,filtered,'k','linewidth',1.5);
xlim([min(t) max(t)]);
legend({'original','filtered'});
xlabel('time (s)');