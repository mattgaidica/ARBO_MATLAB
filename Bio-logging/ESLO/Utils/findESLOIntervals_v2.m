function dataIntervals = findESLOIntervals_v2(data,type,labels)
% The goal here is to extract the EEG signal with a relatively accurate
% time point. Since axy data is either OFF or CONTINUOUS (1Hz or 10Hz) then
% it should be accessible time-locked to EEG or somehow be related to EEG
% through a lookup. Note: EEG could be continuous (one start)
% !! add axy data to intervals
% !! find where user connected over BLE???
Fs = 125;
fprintf("Using Fs = %iHz\n",Fs);
dataIntervals = table;
timeIds = find(type == ESLOType("AbsoluteTime",labels));
XlX_ids = find(type == ESLOType("XlX",labels));
XlY_ids = find(type == ESLOType("XlY",labels));
XlZ_ids = find(type == ESLOType("XlZ",labels));

dataCount = 0;
stateIds = find(type==ESLOType("EEGState",labels));
EEGstate = data(stateIds);
for iEEG = 1:4
    useType = ESLOType("EEG1",labels) + iEEG - 1;
    theseEEGids = find(type == useType);
    EEG_on = stateIds(EEGstate == 1);
    EEG_off = stateIds(EEGstate == 0);
    onLocs = [];
    offLocs = [];
    % the first EEGState should always be 0 (written at init)
    for ii = 1:numel(EEG_on)
        onLoc = find(theseEEGids > EEG_on(ii),1,'first');
        if ~isempty(onLoc)
            onLocs(ii) = onLoc;
            offLoc = EEG_off(find(EEG_off > theseEEGids(onLoc),1,'first'));
            if ~isempty(offLoc)
                offLocs(ii) = find(theseEEGids < offLoc,1,'last');
            else
                offLocs(ii) = numel(theseEEGids);
                break; % this must be the last recording epoch
            end
        end
    end
    
    if numel(onLocs) ~= numel(offLocs)
        error('on/off mismatch');
    end
    
    warning ('off','all');
    typeIds = find(type == useType);
    for ii = 1:numel(onLocs)
        dataCount = dataCount + 1;
        dataRange = theseEEGids(onLocs(ii):offLocs(ii));
        t1Id = closest(timeIds,dataRange(1));
        t1 = data(timeIds(t1Id));
        t2Id = closest(timeIds,dataRange(end));
        t2 = data(timeIds(t2Id));

        dataIntervals.segment(dataCount) = ii;
        dataIntervals.type(dataCount) = useType;
        dataIntervals.label(dataCount) = labels(str2double(labels(:,1)) == useType,2);
        dataIntervals.startTime(dataCount) = datetime(t1,'ConvertFrom','posixtime',...
            'Format','dd-MMM-yyyy HH:mm:ss','TimeZone','America/Detroit');
        dataIntervals.duration(dataCount) = numel(dataRange) / Fs;
%         dataIntervals.dataRange(dataCount) = {dataRange};
        dataIntervals.data(dataCount) = {data(dataRange)};
        
        % do axy extraction
        xData = data(XlX_ids(XlX_ids > dataRange(1) & XlX_ids < dataRange(end)));
        yData = data(XlY_ids(XlY_ids > dataRange(1) & XlY_ids < dataRange(end)));
        zData = data(XlZ_ids(XlZ_ids > dataRange(1) & XlZ_ids < dataRange(end)));
        dataIntervals.xl(dataCount) = {[xData',yData',zData']};
    end
    warning ('on','all');
end