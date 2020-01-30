function sleepFracData = getDailySquirrelData()

dataFile = '/Users/matt/Box Sync/Biologging/Software/Data/allsquirrelsZ15_daily.csv';
T = readtable(dataFile);

varnames = {'X1', 'Squirrel', 'date', 'breaker', 'Feed',...
    'Forage', 'NestMove', 'NestNotMove', 'notmoving', 'Travel', 'total', 'Deploy'};

sleepData = NaN(12,96);
entryData = zeros(12,96);
for iRow = 1:size(T,1)
    iMonth = month(T.date(iRow));
    iTime = hour(T.breaker(iRow)) * 4 + minute(T.breaker(iRow)) / 15 + 1;
    sleepFrac = (T.NestNotMove(iRow) + T.notmoving(iRow)) / T.total(iRow);
    if isnan(sleepData(iMonth,iTime))
        sleepData(iMonth,iTime) = sleepFrac;
    else
        sleepData(iMonth,iTime) = sleepData(iMonth,iTime) + sleepFrac;
    end
    entryData(iMonth,iTime) = entryData(iMonth,iTime) + 1;
end

sleepFracData = sleepData ./ entryData;