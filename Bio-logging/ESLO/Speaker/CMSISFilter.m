function coeffs = CMSISFilter(f1,f2,Fs,data,doPlot)
% from https://hackernoon.com/fast-iir-filtering-on-arm-cortex-m-with-cmsis-dsp-and-gnu-octave-qk1n3y66
% order = requested_order/2;
% fNyquist=fs/2;
% [z,p,k] = butter(order,[f1 f2]/fNyquist, 'bandpass');

% my own
[dataFilt,bpd] = bandpass(data,[f1,f2],Fs);
%% ^these data look fine, but not when converted to b,a then filtered
% [z,p,k] = zpk(bpd);
% sos = zp2sos(z,p,k);
% [b,a] = zp2tf(z,p,k);
% dataFilt = filter(b,a,data);

% compute biquad coefficients
coeffs = bpd.Coefficients(:,[1 2 3 5 6]);
% coeffs = sos(:,[1 2 3 5 6]);

% negate a1 and a2 coeffs (CMSIS expects them negated)
coeffs(:,4) = -coeffs(:,4);
coeffs(:,5) = -coeffs(:,5);
% make a linear array of it
coeffs = coeffs';
coeffs = coeffs(:);
% print the coefficients as expected by CMSIS
clc;
fprintf('Order: %i\n\n',filtord(bpd));
coeffStr = sprintf('%1.10ff,\n',coeffs);
disp(coeffStr(1:end-2));

if doPlot
    close all
    ff(600,600,2);
    subplot(211);
    t = linspace(0,numel(data)/Fs,numel(data));
    plot(t,data,'k-','linewidth',2);
    yyaxis right;
    plot(t,dataFilt,'r-');
    set(gca,'ycolor','r');
    xlim([min(t),max(t)]);
    xlabel('Time (s)');
    legend({'Original','Filtered'});
    title(sprintf('%1.1f-%1.1fHz @ Fs=%1.1f, %i samples',f1,f2,Fs,numel(data)));
    set(gca,'fontsize',14);
    grid on;
    
    subplot(212);
    [P,F] = pspectrum(data,Fs);
    plot(F,P,'k','linewidth',2);
    yyaxis right;
    [P,F] = pspectrum(dataFilt,Fs);
    [locs,pks] = peakseek(P);
    [v,k] = max(pks);
    plot(F,P,'r-');
    hold on;
    plot(F(locs(k)),v,'r.');
    set(gca,'ycolor','r');
    text(F(locs(k)),v,sprintf('  Fc = %1.2fHz',F(locs(k))),'color','r','fontsize',14);
    xlim([0 f2*3]);
    xlabel('Freq. (Hz)');
    set(gca,'fontsize',14);
    legend({'Original','Filtered'});
    title('0.5-4Hz Filtered Power Spectrum');
    grid on;
end