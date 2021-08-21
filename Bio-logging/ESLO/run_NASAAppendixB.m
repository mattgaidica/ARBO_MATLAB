if do
    fname = '/Users/matt/Dropbox (University of Michigan)/Biologging/Database/0006/ESLORB2.TXT';
    [type,data,labels] = extractSD(fname);
    do = false;
end
SDreport(type,labels);
useTypes = ["EEG2","EEG3","XlX","XlY","XlZ"];
dataIntervals = findESLOIntervals(data,type,labels,useTypes);
Fs = 50;
axyFs = 1;

FLIM = [0 10];
rows = 3;
cols = 1;
fs = 12;
tm = 1.25;
maxHours = 8;
close all
useRows = find(dataIntervals.type == ESLOType("EEG2",labels));
for iRow = useRows(3)'
    EEGdata = cleanEEG(data(dataIntervals.range{iRow}));
    ff(700,500);
    subplot(rows,cols,1);
    t = linspace(1,numel(EEGdata)/Fs,numel(EEGdata))/60/60;
    plot(t,EEGdata,'k');
    xRow = find(dataIntervals.segment == dataIntervals.segment(iRow) &...
        dataIntervals.type == ESLOType("XlX",labels));
    x = data(dataIntervals.range{xRow});
    yRow = find(dataIntervals.segment == dataIntervals.segment(iRow) &...
        dataIntervals.type == ESLOType("XlY",labels));
    y = data(dataIntervals.range{yRow});
    zRow = find(dataIntervals.segment == dataIntervals.segment(iRow) &...
        dataIntervals.type == ESLOType("XlZ",labels));
    z = data(dataIntervals.range{zRow});
    OA = axyOA(x,y,z,axyFs);
    OA_EEG = equalVectors(OA,EEGdata);
    ylabel('\muV');
    xlabel('Time (hours)');
    xlim([0 maxHours]);
    xticks(0:maxHours);
    xticklabels(compose("%1.0f",xticks));
    
    text(0,max(ylim)-max(ylim)/5,sprintf("%s %s","\leftarrow",dataIntervals.time(iRow)));
    
    yyaxis right;
    plot(t,OA_EEG,'r');
    legend({'EEG','OA (axy)'});
    title('Raw EEG and Axy Data');
    set(gca,'fontsize',fs,'TitleFontSizeMultiplier',tm);
    set(gca,'ycolor','r');
    ylabel('OA');
    grid on;
    
    subplot(rows,cols,2);
    [p_spectrum,f_spectrum,t_spectrum] = pspectrum(EEGdata,Fs,...
        'spectrogram','FrequencyLimits',FLIM);
    imagesc(t_spectrum/60/60,f_spectrum,p_spectrum);
    colormap(magma);
    caxisVals = caxis/2;
    cb = cbAside(gca,'Power','k');
    set(gca,'ydir','normal');
    xlabel('Time (hours)');
    ylabel('Freq (Hz)');
    set(gca,'fontsize',fs,'TitleFontSizeMultiplier',tm);
    title('Spectrogram');
    xlim([0 maxHours]);
    xticks(0:maxHours);
    xticklabels(compose("%1.0f",xticks));
    
    subplot(rows,cols,3);
    fIds = find(f_spectrum > 0.5 & f_spectrum < 4);
    deltaPower = mean(p_spectrum(fIds,:));
    t_spectrum = linspace(min(t),max(t),numel(deltaPower));
    plot(t_spectrum,deltaPower,'k','linewidth',2);
    title('Slow-wave Power (0.5–4 Hz)');
    set(gca,'fontsize',fs,'TitleFontSizeMultiplier',tm);
    grid on;
    xlabel('Time (hours)');
    ylabel('Power');
    xlim([0 maxHours]);
    xticks(0:maxHours);
    xticklabels(compose("%1.0f",xticks));
end

% do extra
plotTitles = ["Awake","Asleep"];

load('spect_xs');
subplot(rows,cols,2);
for ii = 1:2
    text(xs(ii),7,{plotTitles(ii),'\downarrow'},'color','w',...
        'fontsize',12,'horizontalalignment','center');
end
saveas(gcf,'sleepRecording_NASA.jpg');

%% slow-wave supplement
% [xs,~] = ginput(5);
% save('arrows.mat','xs')
% close all
load('arrows.mat');
ff(500,400);
rows = 2;
cols = 1;
useXs = [3.1252e+04,1.9575e+04];


iRow = useRows(3)';
for ii = 1:2
    subplot(rows,cols,ii);
    EEGdata = cleanEEG(data(dataIntervals.range{iRow}));
    t = linspace(1,numel(EEGdata)/Fs,numel(EEGdata));
    plot(t,EEGdata,'k','linewidth',2);
    title(plotTitles(ii));
    ylabel('\muV');
    xlim([useXs(ii) useXs(ii) + 6]);
    ylim([-12000 12000]);
    theseXticks = xticks;
    xticklabels(1:numel(xticks));
    xlabel('Time (sec)');
    grid on;
    for iArrow = 1:numel(xs)
        text(xs(iArrow),ys(iArrow),"\downarrow",'fontsize',22,...
            'color','r','horizontalalignment','center','verticalalignment','bottom');
    end
    hold on;
    ln = plot(0,0,'r');
    text(max(xs)+0.2,max(ys),sprintf("%1.2fHz Oscillation",1/mean(diff(xs))),...
        'fontsize',14,'color','r');
    set(gca,'fontsize',fs,'TitleFontSizeMultiplier',tm);
end
saveas(gcf,'slowOscillation_NASA.jpg');