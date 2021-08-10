function deviceLoc = baseTriangulate(basePos,baseRSSI)

estRadius = 40;
baseMag = db2mag(baseRSSI);

deviceLoc = NaN;
if sum(isnan(baseMag)) > 3
    return;
end

% find greatest RSSI, break tie?
[bestMag,k] = max(baseMag);
bestBase = basePos(k(1),:);

% sum vestors to other locations
deviceLoc = [];
baseCount = 0;
for iBase = 1:numel(baseMag)
    if iBase == k || isnan(baseMag(iBase))
        continue;
    end
    baseCount = baseCount + 1;
    deviceLoc(baseCount,1) = (baseMag(iBase)/bestMag) * (basePos(iBase,1) - bestBase(1,1));
    deviceLoc(baseCount,2) = (baseMag(iBase)/bestMag) * (basePos(iBase,2) - bestBase(1,2));
end

deviceLoc = mean(deviceLoc,1) + bestBase;