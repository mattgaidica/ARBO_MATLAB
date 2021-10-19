allData = [];
for iBase = 1:5
    baseFile = sprintf("/Users/matt/Downloads/screenlog_BS%i.csv",iBase);
    T = readtable(baseFile);

    useIds_ESLO = T.Var1 == 262705969627137;
    useIds_Time = T.Var2 > 255 & T.Var2 < 1634581000;
%     useIds_RSSI = T.Var3 < -75;
    useIds = useIds_ESLO & useIds_Time;
    timeData = T.Var2(useIds);
    RSSIData = T.Var3(useIds);
    
    useRange = size(allData,1)+1:size(allData,1)+numel(timeData);
    allData(useRange,1) = ones(numel(useRange),1)*iBase;
    allData(useRange,2) = timeData;
    allData(useRange,3) = RSSIData;

%     subplot(2,3,iBase);
%     plot(T.Var2(useIds));
%     yyaxis right;
%     plot(T.Var3(useIds));
%     title(sprintf("Base %i",iBase));
%     drawnow;
end

%%
% datetime(allData(1,2), 'convertfrom', 'posixtime', 'Format', 'dd-MMM-uuuu HH:mm:ss')
close all
ff(1400,800);

latlim = [42.2729,42.2742];
lonlim = [-83.8060,-83.8031];

latLons = [42.273540697100124, -83.80464468159136;
    42.27376146409152, -83.80451611662764;
    42.27341857528876, -83.80470015970569;
    42.27365062152885, -83.804589182111;
    42.273660848093925, -83.80441045105175];

minTime = min(allData(:,2));
maxTime = max(allData(:,2));
minutesRecorded = round(maxTime-minTime)/60;
tBins = linspace(minTime,maxTime,minutesRecorded);
binnedRSSI = [];
for iBin = 1:numel(tBins)-1
    RSSIs = [];
    for iBase = 1:5
        useIds = find(allData(:,1)==iBase & allData(:,2)>tBins(iBin) & allData(:,2)<tBins(iBin+1));
        RSSIs(iBase) = mean(allData(useIds,3));
    end
    binnedRSSI = [binnedRSSI;RSSIs];
    if all(isnan(RSSIs))
        continue;
    end
    geoscatter(latLons(:,1),latLons(:,2),round((db2mag(RSSIs)*1000000).^2),[1 0 0],'filled','MarkerFaceAlpha',.5);
    for iBase = 1:5
        text(latLons(iBase,1),latLons(iBase,2),sprintf('%i',iBase));
    end
    geobasemap satellite;
    geolimits(latlim,lonlim);
    dt = datetime(tBins(iBin),'convertfrom','posixtime','Format','dd-MMM-uuuu HH:mm:ss','TimeZone','local');
    title(datestr(dt));
    set(gca,'fontsize',14);
    drawnow;
end

%%
ff(1000,500);
dtX = datetime(tBins(1:end-1),'convertfrom','posixtime','Format','dd-MMM HH:mm','TimeZone','local');
plot(dtX,db2mag(binnedRSSI),'linewidth',2);
xticks(dtX(round(linspace(1,numel(dtX),20))));
xtickangle(30);
xlim([min(dtX) max(dtX)]);
legend(compose("Base %i",1:5),'location','northwest');
title('Signal Strength vs. Time');
ylabel('Magnitude of RSSI');
grid on;
set(gca,'fontsize',14);
