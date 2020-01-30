function [squirrelArr,dailyMean,dailyStd,squirrelHeader] = getSquirrelData()
% ODBA is the sum of the acceleration over the day. notmoving is out of the 
% nest and not moving.  NestMove is in the nest but moving, and 
% sleep (poorly named) is in nest not moving. -Emily Studd
accelPath = 'Data/allsquirrelsDA.csv';
origHeader = ["","X1","Squirrel","date","ODBA","Feed","Forage","NestMove",...
    "notmoving","Sleep","Travel","Deploy"];
T = readtable(accelPath);

squirrelHeader = {'doy','odba','feed','forage','nestmove','notmove','sleep','travel'};
squirrelArr = [];
rowCount = 0;
for iRow = 1:size(T,1)
    if(strcmp(T{iRow,8}{:},'NA') == 0 && strcmp(T{iRow,11}{:},'NA') == 0)
        rowCount = rowCount + 1;
        squirrelArr(rowCount,1) = day(T{iRow,4},'dayofyear');
        squirrelArr(rowCount,2) = T{iRow,5};
        squirrelArr(rowCount,3) = str2num(T{iRow,6}{:});
        squirrelArr(rowCount,4) = str2num(T{iRow,7}{:});
        squirrelArr(rowCount,5) = str2num(T{iRow,8}{:});
        squirrelArr(rowCount,6) = T{iRow,9};
        squirrelArr(rowCount,7) = str2num(T{iRow,10}{:});
        squirrelArr(rowCount,8) = str2num(T{iRow,11}{:});
    end
end
% sort by doy
squirrelArr = sortrows(squirrelArr);
dailyMean = NaN(max(squirrelArr(:,1)),size(squirrelArr,2));
dailyStd = dailyMean;
skipDays = [104,114:129,272,310:313];
for iDay = 1:max(squirrelArr(:,1))
    dailyMean(iDay,1) = iDay;
    dailyStd(iDay,1) = iDay;
    if ~ismember(iDay,skipDays)
        for iCol = 2:8
            dailyMean(iDay,iCol) = mean(squirrelArr(squirrelArr(:,1) == iDay,iCol),1);
            dailyStd(iDay,iCol) = std(squirrelArr(squirrelArr(:,1) == iDay,iCol),1);
        end
    end
end