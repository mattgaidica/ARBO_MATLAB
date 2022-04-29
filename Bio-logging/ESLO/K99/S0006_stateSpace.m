% see also: /Users/matt/Documents/MATLAB/ARBO/Bio-logging/ESLO/Speaker/ESLOMethods.m
if do
    fname = '/Users/matt/Dropbox (University of Michigan)/Biologging/Database/S0006_0200/ESLORB2.TXT';
    [type,data,labels] = extractSD(fname,Inf,datetime(2021,8,13));
    do = 0;
    SDreport(type,labels);
    useTypes = ["EEG2","EEG3","XlX","XlY","XlZ"];
    dataIntervals = findESLOIntervals(data,type,labels,useTypes);
end

Fs = 50;
axyFs = 1;
startHour = 20;
showHours = 8;
esloGain = 12;

iSegment = 4;
xRow = find(dataIntervals.segment == iSegment & dataIntervals.type == ESLOType("XlX",labels));
x = data(dataIntervals.range{xRow});
yRow = find(dataIntervals.segment == iSegment & dataIntervals.type == ESLOType("XlY",labels));
y = data(dataIntervals.range{yRow});
zRow = find(dataIntervals.segment == iSegment & dataIntervals.type == ESLOType("XlZ",labels));
z = data(dataIntervals.range{zRow});
OA = axyOA(x,y,z,axyFs);

EEG_row = find(dataIntervals.segment == iSegment & dataIntervals.type == ESLOType("EEG2",labels));
EEG = double(data(dataIntervals.range{EEG_row}));
EEG = ADSgain(EEG,esloGain); % convert to uV
EEG = cleanEEG(EEG,300); % clean at 300uV

% data is loaded, trim recording
secondsOffset = startHour*60*60 - (hour(dataIntervals.time(EEG_row))*60*60 ...
    + minute(dataIntervals.time(EEG_row))*60 + second(dataIntervals.time(EEG_row)));
sampleOffset = round(secondsOffset * Fs);
if sampleOffset < 1
    sampleOffset = 1;
end
sampleRange = sampleOffset:sampleOffset+showHours*3600*Fs;
if sampleRange > numel(EEG)
    error('showHours out of range');
end
EEG = detrend(EEG(sampleRange));
x = x(secondsOffset:secondsOffset+showHours*3600*axyFs);
y = y(secondsOffset:secondsOffset+showHours*3600*axyFs);
z = z(secondsOffset:secondsOffset+showHours*3600*axyFs);
OA = OA(secondsOffset:secondsOffset+showHours*3600*axyFs);

t_EEG = linspace(0,numel(EEG)/Fs/3600,numel(EEG));
t_axy = linspace(0,numel(EEG)/Fs/3600,numel(x));

%%
qOA = abs(gradient(double(x))) + abs(gradient(double(y))) + abs(gradient(double(z)));
qOA_smooth = smoothdata(qOA,'gaussian',numel(qOA)/50);
[P,F,T] = pspectrum(EEG,Fs,'spectrogram','frequencylimits',[0.5 55]);
SWpower =  normalize(mean(P(F > 0.5 & F < 4,:)),'range',[1 1000]);
R1 = [0.5 20;0.5 55];
R2 = [0.5 4.5;0.5 9];
R1_series = mean(P(F > R1(1,1) & F < R1(1,2),:)) ./ mean(P(F > R1(2,1) & F < R1(2,2),:));
R2_series = mean(P(F > R2(1,1) & F < R2(1,2),:)) ./ mean(P(F > R2(2,1) & F < R2(2,2),:));
close all;
ff(1200,600);

subplot(121);
colors = magma(1000);
OA_range = floor(linspace(1,numel(qOA),numel(T)));
for ii = 1:numel(R1_series)
    plot3(R1_series(ii),R2_series(ii),qOA(OA_range(ii)),'.','color',colors(round(SWpower(ii)),:),'markerSize',20);
    drawnow;
    hold on;
end
grid on;
hold off;
xlabel('R1');
ylabel('R2');
zlabel('OA');
view(19.0123,34.6294);

op = 0.2;
subplot(122);
for ii = 1:numel(R1_series)-1
    plot3(R1_series(ii),R2_series(ii),ii,'.','color',colors(round(SWpower(ii)),:),'markerSize',20);
    hold on;
    plot3(R1_series(ii:ii+1),R2_series(ii:ii+1),ii:ii+1,'color',[colors(round(SWpower(ii)),:),op]);
    drawnow;
    hold on;
end
grid on;
hold off;
xlabel('R1');
ylabel('R2');
zlabel('Time');
view(19.0123,34.6294);