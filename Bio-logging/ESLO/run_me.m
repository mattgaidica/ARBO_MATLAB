close all;ff(1000,600);

subplot(211);plot(data(type==2),'k','linewidth',1.5);
title('EEG');
legend({'Ch1'});
set(gca,'fontsize',14);
xlabel('samples');
ylabel('raw amplitude');

subplot(212);
plot(data(type==7)-mean(data(type==7)),'linewidth',1.5);
hold on;
plot(data(type==8)-mean(data(type==8)),'linewidth',1.5);
plot(data(type==9)-mean(data(type==9)),'linewidth',1.5)
xlim([1 sum((type==7))]);
title('Axy')
legend({'X','Y','Z'});
set(gca,'fontsize',14);
xlabel('samples');
ylabel('raw amplitude');