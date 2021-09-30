% paste data from spreadsheet

close all
ff(1200,800);
useData = {HR,HR_pad};
startEndLabel = {'Start','End'};
titleLabels = {'Heart Rate Relative to Start','Heart Rate Relative to End'};
for iZ = 1:2
    for iPlot = 1:2
        subplot(2,2,prc(2,[iZ,iPlot]));
        theseData = useData{iPlot};
        colors = lines(5);
        for iHr = 1:2
            thisArr = [theseData{iHr,:}];
            if iPlot == 2 && iHr == 2
                thisArr = [NaN(1,size(theseData,2)-numel(thisArr)) thisArr];
            end
            if iZ == 2
                thisArr = normalize(thisArr);
%                 thisArr = thisArr - thisArr(1); % normalize to zero?
            end
            plot(thisArr,'-','color',colors(iHr,:),'linewidth',3);
            hold on;
        end
        xticklabels(compose('%1.2f',xticks*5/60));
        xlim([1 size(theseData,2)]);
        if iZ == 1
            ylim([0 300]);
            ylabel('Heart Rate (BPM)');
        else
             ylabel('Heart Rate (Z-score)');
        end
        xlabel(sprintf('Time Rel. to %s (hrs)',startEndLabel{iPlot}));
        set(gca,'fontsize',20);
        grid on;
        title(titleLabels{iPlot});
        legend({'S0008','S0009'},'location','northwest');
    end
end
saveas(gcf,'squirrelSurgeryHR.jpg');
save('HR_data_S0008-9.mat','HR','HR_pad');