if do
    fname = '/Users/matt/Dropbox (University of Michigan)/Biologging/Database/R0008/ESLORB2.TXT';
    [type,data,labels] = extractSD(fname);
    SDreport(type,labels);
    dataIntervals = findESLOIntervals_v2(data,type,labels);
    do = 0;
end

esloGain = 12;
cleanThresh = 300;
Fs = 125;
%%
% close all;
ff(800,400);

t_vitals = (1:sum(type==6))/60/24;
plot(t_vitals,double(data(type==6))/1000,'k-');
ylabel('Battery (V)');

% % % % yyaxis right;
% % % % t_vitals = (1:sum(type==13))/60/24;
% % % % plot(t_vitals,double(data(type==13))/1000,'r-');
% % % % set(gca,'ycolor','r');
% % % % ylabel('Temp (C)');

xlim([min(t_vitals) max(t_vitals)]);
xlabel('Time (days)');
title('Device Vitals (1 sample/minute)');
set(gca,'fontsize',16);
grid on;