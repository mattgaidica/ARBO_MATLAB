% function batteryModel(batterySize, recordingDuration)
% batterySize: mAh
% recordingDuration: seconds

recordingDuration = 5;
recordingDuration_hours = recordingDuration/60;

recordingDraw_active = 12; % mA
recordingDraw_sleep = 1; % mA
% recordingDuration_inHours = recordingDuration / 60 / 60;

batterySizes = [100,200,400,800];
nRec = [0,10,100];
nDays = 30;
legends = {};
for ii = 1:numel(nRec)
    legends{ii} = [num2str(nRec(ii)),' rec/day @ ',num2str(recordingDuration),'min '...
        '(',num2str(recordingDuration*nRec(ii)/24,2),'hrs)'];
end
close all
ff(900,600);
recArr = [];
for iBatt = 1:numel(batterySizes)
    subplot(2,2,iBatt);
    for iN = 1:numel(nRec)
        for iDay = 0:nDays
            recArr(iDay+1) = batterySizes(iBatt)...
                - iDay*recordingDraw_active*(recordingDuration_hours * nRec(iN))...
                - iDay*recordingDraw_sleep*(24 - recordingDuration_hours * nRec(iN));
        end
        plot([0:nDays],recArr,'lineWidth',2);
        hold on;
    %     recArr(iN) = batterySize - (batteryLife_inHours_active / nRec(iN));% - (86400 - recordingDraw_sleep * nRec(iN));
    end
    legend(legends);
    legend boxoff;
    ylabel('Battery Remaining (mAh)');
    xlabel('Day');
    title([num2str(batterySizes(iBatt)),'mAh - ',num2str(recordingDraw_active),'mA_{rec}, ',...
        num2str(recordingDraw_sleep),'mA_{sleep}']);
    ylim([0 batterySizes(iBatt)]);
    xlim([0 nDays]);
end