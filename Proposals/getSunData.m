function [sunYear,sunYearAvg,sunMonth,sunHeader,monthNames] = getSunData(months)
    % https://www.timeanddate.com/sun/canada/whitehorse
    sunPath = 'Data/sunData_WhitehorseCA';
    monthProto = '-Table 1.csv';
    monthNames = {'JAN','FEB','MAR','APR','MAY','JUN','JUL','AUG','SEP','OCT','NOV','DEC'};
    sunHeader = {'day','sunrise','sunset','daylength','difference','solar_noon','mil_mi'};
    sunHeader = sunHeader{1:4}; % not using others right now
    sunYear = [];
    sunMonth = {};
    for iMonth = months
        filename = fullfile(sunPath,[monthNames{iMonth},monthProto]);
        T = readtable(filename);
        arr = table2arr(T);
        sunMonth{iMonth} = arr;
        sunYear = [sunYear;arr];
    end
    % compile averages
    sunYearAvg = zeros(numel(sunMonth),size(sunYear,2));
    for iMonth = 1:numel(sunMonth)
        arr = sunMonth{iMonth};
        sunYearAvg(iMonth,:) = mean(arr);
    end
end

function arr = table2arr(T)
    arr = zeros(size(T,1),3);
    cleanCols = [2,3];
    durCol = 4;
    for iCol = cleanCols
        for iRow = 1:size(T,1)
            arr(iRow,1) = iRow;
            curstr = T{iRow,iCol}{:};
            pos = strfind(curstr,'am');
            if isempty(pos)
                pos = strfind(curstr,'pm');
            end
            curstr = curstr(1:pos+1);
            newstr = datestr(datenum(curstr,['HH:MM ',curstr(end-1:end)]),'HH:MM');
            hrs = str2num(newstr(1:2));
            min = str2num(newstr(end-1:end));
            arr(iRow,iCol) = hrs * 60 + min;
        end
    end
    for iRow = 1:size(T,1)
        arr(iRow,4) = hours(T{iRow,durCol}) * 60;
    end
end