nBase = 5;

base1 = readtable('/Users/matt/Documents/MATLAB/ARBO/Bio-logging/ESLO/Base Stations/Base1.csv');
base2 = readtable('/Users/matt/Documents/MATLAB/ARBO/Bio-logging/ESLO/Base Stations/Base2.csv');
base3 = readtable('/Users/matt/Documents/MATLAB/ARBO/Bio-logging/ESLO/Base Stations/Base3.csv');
base4 = readtable('/Users/matt/Documents/MATLAB/ARBO/Bio-logging/ESLO/Base Stations/Base4.csv');
base5 = readtable('/Users/matt/Documents/MATLAB/ARBO/Bio-logging/ESLO/Base Stations/Base5.csv');

primaryOffset = base1.Var2(1);
base1.Var2 = base1.Var2;
base2.Var2 = base2.Var2 + 5;
base3.Var2 = base3.Var2 + 10;
base4.Var2 = base4.Var2 + 15;
base5.Var2 = base5.Var2 + 20;
startSec = min([base1.Var2;base2.Var2;base3.Var2;base4.Var2;base5.Var2]);
endSec = max([base1.Var2;base2.Var2;base3.Var2;base4.Var2;base5.Var2]);
%%
basePos = [0,0;-30,30;-30,90;30,90;30,30];
% x = basePos(:,1);
% y = basePos(:,2);
% DT = delaunay(x,y);
%%

RSSImax = 105;

close all
h = ff(600,600);
for iBase = 1:nBase
    plot(basePos(iBase,1),basePos(iBase,2),'k.','markerSize',15);
    hold on;
end
xlim([-60 60]);
ylim([-30 120]);
xticks(min(xlim):30:max(xlim));
yticks(min(ylim):30:max(ylim));
xlabel('feet');
ylabel('feet');
set(gca,'fontSize',16);
grid on;

h1 = [];
h2 = [];
h3 = [];
h4 = [];
h5 = [];
hdevice = [];
thalfWindow = 4;
circColor = [1 0 0];
rssiMult = 5e7;

v = VideoWriter('RSSImap','MPEG-4');
v.Quality = 95;
v.FrameRate = 20;
open(v);

for ii = startSec:endSec
    delete(h1);
    delete(h2);
    delete(h3);
    delete(h4);
    delete(h5);
    delete(hdevice);
    
    bestRSSI1 = NaN;
    bestRSSI2 = NaN;
    bestRSSI3 = NaN;
    bestRSSI4 = NaN;
    bestRSSI5 = NaN;
    
    idx = find(base1.Var2 > ii - thalfWindow & base1.Var2 < ii + thalfWindow); % window
    if ~isempty(idx)
        bestRSSI1 = mean(base1.Var3(idx));
        h1 = scatter(basePos(1,1),basePos(1,2),db2mag(bestRSSI1)*rssiMult,circColor,'filled');
        h1.MarkerFaceAlpha = .2;
    end
    
    idx = find(base2.Var2 > ii - thalfWindow & base2.Var2 < ii + thalfWindow); % window
    if ~isempty(idx)
        bestRSSI2 = mean(base2.Var3(idx));
        h2 = scatter(basePos(2,1),basePos(2,2),db2mag(bestRSSI2)*rssiMult,circColor,'filled');
        h2.MarkerFaceAlpha = .2;
    end
    
    idx = find(base3.Var2 > ii - thalfWindow & base3.Var2 < ii + thalfWindow); % window
    if ~isempty(idx)
        bestRSSI3 =mean(base3.Var3(idx));
        h3 = scatter(basePos(3,1),basePos(3,2),db2mag(bestRSSI3)*rssiMult,circColor,'filled');
        h3.MarkerFaceAlpha = .2;
    end
    
    idx = find(base4.Var2 > ii - thalfWindow & base4.Var2 < ii + thalfWindow); % window
    if ~isempty(idx)
        bestRSSI4 = mean(base4.Var3(idx));
        h4 = scatter(basePos(4,1),basePos(4,2),db2mag(bestRSSI4)*rssiMult,circColor,'filled');
        h4.MarkerFaceAlpha = .2;
    end
    
    idx = find(base5.Var2 > ii - thalfWindow & base5.Var2 < ii + thalfWindow); % window
    if ~isempty(idx)
        bestRSSI5 = mean(base5.Var3(idx));
        h5 = scatter(basePos(5,1),basePos(5,2),db2mag(bestRSSI5)*rssiMult,circColor,'filled');
        h5.MarkerFaceAlpha = .2;
    end
    
    baseRSSI = [bestRSSI1,bestRSSI2,bestRSSI3,bestRSSI4,bestRSSI5];
    
    deviceLoc = baseTriangulate(basePos,baseRSSI);
    if ~isnan(deviceLoc)
        hdevice = plot(deviceLoc(1),deviceLoc(2),'b.','markerSize',50);
    end
    
    title(sprintf("frame (seconds): %i",ii));
    drawnow;
    F = getframe(h);
    writeVideo(v,F);
end
close(v);