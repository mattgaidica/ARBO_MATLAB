if do
    fname = '/Users/matt/Dropbox (University of Michigan)/Biologging/Database/S0147/ESLORB2.TXT';
    [type,data,labels] = extractSD(fname);
    SDreport(type,labels);
    dataIntervals = findESLOIntervals_v2(data,type,labels);
    do = 0;
end

esloGain = 12;
cleanThresh = 300;
Fs = 125;
axyFs = 1;
%%
% close all;
ff(800,400);

t_vitals = (1:sum(type==6))/60/24;
plot(t_vitals,double(data(type==6))/1000,'k-');
ylabel('Battery (V)');

yyaxis right;
t_vitals = (1:sum(type==13))/60/24;
plot(t_vitals,double(data(type==13))/1000 * (9/5) + 32,'r-');
set(gca,'ycolor','r');
ylabel('Body Temp (C)');

xlim([min(t_vitals) max(t_vitals)]);
xlabel('Time (days)');
title('Device Vitals (1 sample/minute)');
set(gca,'fontsize',16);
grid on;

%%
close all
colors = lines(3);
for useRec = 160:190
    ff(1000,900);
    for iType = 3:5
        subplot(3,2,prc(2,[iType-2,1]));
        recs = find(dataIntervals.type == iType);

        EEG = ADSgain(double(dataIntervals.data{recs(useRec)}),esloGain); % convert to uV
        f = EEG_startupFilt(EEG');
        y = f(1:numel(EEG));
        EEG = EEG - y';
        tEEG = linspace(0,dataIntervals.duration(recs(useRec)),numel(EEG));
        plot(tEEG,EEG,'k-');
        ylim([-200 200]);
        hold on;

        axy = double(dataIntervals.xl{recs(useRec)});
        tAxy = linspace(0,dataIntervals.duration(recs(useRec)),size(axy,1));
        yyaxis right;
        for iAxis = 1:3
            plot(tAxy,gradient(axy(:,iAxis)),'-');
        end
        ylim([-2000 2000]);
        FLIM = [1 35];
        [P,F,T] = pspectrum(EEG,Fs,'spectrogram','FrequencyLimits',FLIM);
        subplot(3,2,prc(2,[iType-2,2]));
        imagesc(T,F,P);
        colormap(magma);
        caxisauto(P,1);
        set(gca,'ydir','normal');
        ylim(FLIM);
    end
end
%% hm, so far its not 
recs = find(dataIntervals.type == 3);
recs = recs(1:300);
recMedDelta = [];
for iRec = 1:numel(recs)
    fprintf('%i/%i\n',iRec,numel(recs));
    EEG = ADSgain(double(dataIntervals.data{recs(iRec)}),esloGain); % convert to uV
    [P,F,T] = pspectrum(EEG,Fs,'spectrogram');
    recMedDelta(iRec) = mean(mean(P(F > 0.5 & F <= 4,:)));
end

close all;
ff(1000,500);
xt = dataIntervals.startTime(recs);
plot(xt,recMedDelta,'k-');
xlim([min(xt) max(xt)]);

%% is EMG getting HR?
recs = find(dataIntervals.type == 5);

EEG = ADSgain(double(dataIntervals.data{recs(end-100)}),esloGain);
EEG = detrend(abs(EEG));
[locs,pks] = peakseek(EEG,40,30);
ff(1000,300);
plot(EEG,'k-');
hold on;
plot(locs,pks,'ro');
fprintf('%1.1f bpm\n',numel(pks));
% hm, 43 bpm is non-physiological

%% does axy corr with temp?
x = abs(gradient(double(data(type==7))));
y = abs(gradient(double(data(type==8))));
z = abs(gradient(double(data(type==9))));
OA = normalize(x+y+z,'range');
tempF = smoothdata(double(data(type==13))/1000 * (9/5) + 32,'movmean',100);
tTemp = linspace(0,max(tAxy),numel(tempF));

tempLocs = find(type==13);
xLocs = find(type==7);
yLocs = find(type==8);
zLocs = find(type==9);
OA_sub = [];
for iLoc = 1: numel(tempLocs)-1
    use_x = xLocs(xLocs > tempLocs(iLoc) & xLocs <= tempLocs(iLoc+1));
    x = double(data(use_x));
    if ~isempty(x)
        use_y = yLocs(yLocs > tempLocs(iLoc) & yLocs <= tempLocs(iLoc+1));
        y = double(data(use_x));
        use_z = zLocs(zLocs > tempLocs(iLoc) & zLocs <= tempLocs(iLoc+1));
        z = double(data(use_x));
        OA_sub(iLoc) = mean(abs(gradient(x)) + abs(gradient(y)) + abs(gradient(z)));
    else
        OA_sub(iLoc) = NaN;
    end
end

%%
OA_sub_smooth = smoothdata(normalize(OA_sub),'movmean',20);
useIds = find(tempF > 90);
close all
ff(1000,200);

plot(OA_sub_smooth(useIds),'k-','linewidth',2);
ylabel('Axy OA (norm)');
yticks([]);

yyaxis right;
plot(tempF(useIds),'r-');
set(gca,'fontsize',14,'ycolor','r');
ylabel('Body Temp (F)');

xlim([1 numel(useIds)]);
xticklabels(compose('%1.1f',xticks/60/24));
xlabel('Days');
grid on;

title('S0147 OA vs. Body Temp');
saveas(gcf,'S0147_OA-BodyTemp.jpg');
