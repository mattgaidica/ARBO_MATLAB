function [hm,W_z] = quickHomeogram(OA)
% note: based on Fs=1Hz (1 sec), not 1/60Hz (1 min)
doPlot = 0;
n = 60;
if doPlot
    colors = magma(n);
    close all;
    ff(900,700);
    subplot(211);
    plot(OA,'k');
    hold on;
    xlim([1 numel(OA)]);
    yyaxis right;
end
W = zeros(size(OA));
for iFilt = 1:n
    filtFactor = 240/iFilt;
    thisSmooth = smoothdata(OA,'loess',filtFactor);
    W = W + normalize(thisSmooth,'range',[0 1]);
    if doPlot
        plot(W,'-','color',colors(iFilt,:));
    end
end
W_norm = normalize(W,'zscore'); % use this to estimate where sleep exists
useStd = std(W(W_norm < 0));
useMean = mean(W(W_norm < 0));
W_z = (W - useMean) ./ useStd;

W_bin = zeros(numel(OA),1);
W_bin(W_z > 0) = 1;
hm = ~W_bin;

if doPlot
    subplot(212);
    plot(OA,'k');
    yyaxis right;
    plot(hm,'r-');
    hold on;
    plot(W_z,'r:');
    xlim([1 numel(OA)]);
end