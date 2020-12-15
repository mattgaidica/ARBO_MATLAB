% A1=ESLO, A2=neurologger, Ahr=esloHr
close all
ff(1200,800);
rows = 3;
cols = 1;

xlimVals = [min(t),max(t);15 20];
legendVals = {'Dantzer','Eban-R'};
titles = {'~60s data','5s data'};

for ii=1:2
    subplot(rows,cols,ii);
    t = linspace(0,numel(A1)/250,numel(A1));
    plot(t,A1,'k');
    
    yyaxis right;
    t = linspace(0,numel(A2)/400,numel(A2));
    plot(t,A2,'r');
    xlim(xlimVals(ii,:));
    xlabel('time (s)');
    title(titles{ii});
    set(gca,'fontsize',14);
    legend(legendVals);
end

subplot(rows,cols,3);
l1 = plot(f1,normalize(smoothdata(P1,'movmean',250),'range'),'k');
set(gca,'yscale','log');
ylabel('|P(f)|^2');
ylim([0.0003,3.2370]);

yyaxis right;
l2 = plot(f2,normalize(smoothdata(P2,'movmean',400),'range'),'r');
set(gca,'yscale','log');
ylim([0.0021,2.1401]);

yyaxis left;
hold on;
l3 = plot(fhr,normalize(smoothdata(Phr,'movmean',250)*.5,'range'),'k:');

xlim([0 80]);
title('FFT');
xlabel('Frequency (f)');
legendVals = {'Dantzer','Eban-R'};
set(gca,'fontsize',14);
legend([l1,l2,l3], {legendVals{:}, 'Dantzer HR'});