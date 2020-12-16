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