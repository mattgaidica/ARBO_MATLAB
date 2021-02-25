load('sampleT');

close all
h = ff(500,150,2);
plot(T.odba(1:1440),'k','linewidth',1.5);
ylabel('Accelerometer');
yticks(ylim);
yticklabels({});
set(gca,'ycolor','k');

yyaxis right;
smData = smoothdata(T.odba(1:1440),'gaussian',50);
plot(smData,'r','linewidth',2.5);
hold on;
plot(xlim,[mean(smData) mean(smData)],'r.-');
plot(xlim,[max(smData) max(smData)],'r--');
set(gca,'ycolor','r');

xlim([1 1440]);
xticks(xlim);
xticklabels({0,23});
xlabel('Time (hours)');
yticks([0,1]);
yticklabels({'Low','High'});
ylabel('Sampling Rate');

xlim
set(gca,'fontsize',14);
box off;
saveas(h,'adaptiveSampling.png');
close(h);