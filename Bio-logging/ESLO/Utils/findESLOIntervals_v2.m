function dataIntervals = findESLOIntervals(data,type,labels)
% The goal here is to extract the EEG signal with a relatively accurate
% time point. Since axy data is either OFF or CONTINUOUS (1Hz or 10Hz) then
% it should be accessible time-locked to EEG or somehow be related to EEG
% through a lookup. Note: EEG could be continuous (one start)
% !! add axy data to intervals
% !! find where user connected over BLE???

recInterval = 60; % seconds, for battery, time, temperature
nBetween = 16;
dataIntervals = table;
timeIds = find(type == ESLOType("AbsoluteTime",labels));

dataCount = 0;
for iEEG = 1:4
    useType = ESLOType("EEG1",labels) + iEEG - 1;
    EEG_ids = find(type == useType);
    offLocs = EEG_ids(diff([EEG_ids numel(type)]) > nBetween); % add numel(type) as final 'off'
    onLocs = [];
    for iOff = 1:numel(offLocs)
        if iOff == 1
            onLocs(iOff) = EEG_ids(find(EEG_ids < offLocs(iOff),1,'first'));
        else
            onLocs(iOff) = EEG_ids(find(EEG_ids < offLocs(iOff) & EEG_ids > offLocs(iOff-1),1,'first'));
        end
    end
    if numel(onLocs) ~= numel(offLocs)
        error('on/off mismatch');
    end
    
    warning ('off','all');
    typeIds = find(type == useType);
    for iOnOff = 1:numel(onLocs)
        theseDataIds = typeIds(typeIds >= onLocs(iOnOff) & typeIds <= offLocs(iOnOff));

        if isempty(theseDataIds)
            continue;
        end

        dataCount = dataCount + 1;

        t1Id = closest(timeIds,onLocs(iOnOff));
        % add 0x61000000 for unix/posix time !! may change based on deployment date
        t1 = data(timeIds(t1Id)) + int32(0x61000000);
        t2Id = closest(timeIds,offLocs(iOnOff));
        t2 = data(timeIds(t2Id)) + int32(0x61000000);

        dataIntervals.segment(dataCount) = iOnOff;
        dataIntervals.type(dataCount) = useType;
        dataIntervals.label(dataCount) = labels(str2double(labels(:,1)) == useType,2);
        dataIntervals.time(dataCount) = datetime(t1,'ConvertFrom','posixtime',...
            'Format','dd-MMM-yyyy HH:mm:ss','TimeZone','America/Detroit');
        dataIntervals.duration(dataCount) = t2 - t1;
        dataIntervals.data(dataCount) = {data(theseDataIds)};
    end
    warning ('on','all');
end