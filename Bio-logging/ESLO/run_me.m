[type,data,labels] = extractNAND('/Users/matt/Downloads/ESLO_20210311_122749.txt'); % 500
% [type,data,labels] = extractNAND('/Users/matt/Downloads/ESLO_20210311_094313.txt'); % 100
% [type,data,labels] = extractNAND('/Users/matt/Downloads/ESLO_20210311_094101.txt'); % 750
% [type,data,labels] = extractNAND('/Users/matt/Downloads/ESLO_20210311_093525.txt'); % 7500
close all;
ff(1000,600);

subplot(211);
if ~isempty(data(type==2))
    plot(data(type==2),'linewidth',1);
    hold on;
    plot(data(type==3),'linewidth',1);
    plot(data(type==4),'linewidth',1);
    plot(data(type==5),'linewidth',1);
    xlim(size(data(type==5)));
end
title('EEG');
legend({'Ch1','Ch2','Ch3','Ch4'});
set(gca,'fontsize',14);
xlabel('samples');
ylabel('raw amplitude');

subplot(212);
if ~isempty(data(type==7))
    plot(data(type==7)-mean(data(type==7)),'linewidth',1.5);
    hold on;
    plot(data(type==8)-mean(data(type==8)),'linewidth',1.5);
    plot(data(type==9)-mean(data(type==9)),'linewidth',1.5)
    xlim([1 sum((type==7))]);
    legend({'X','Y','Z'});
end
title('Axy')
set(gca,'fontsize',14);
xlabel('samples');
ylabel('raw amplitude');