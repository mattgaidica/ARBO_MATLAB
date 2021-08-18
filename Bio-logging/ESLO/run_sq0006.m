if do
    fname = '/Users/matt/Box Sync/Biologging/Database/0006/ESLORB2.TXT';
    [type,data,labels] = extractSD(fname);
end
SDreport(type,labels);
Fs = 50;

EEG1 = data(type==3);
EEG2 = data(type==4);
nFilt = 60;
OA = abs(double(data(type==7)) - medfilt1(double(data(type==7)),nFilt)) + ...
    abs(double(data(type==8)) - medfilt1(double(data(type==8)),nFilt)) + ...
    abs(double(data(type==9)) - medfilt1(double(data(type==9)),nFilt));
close all
ff(1000,600);
plot(EEG1,'k');
hold on;
OAeq = equalVectors(OA,EEG1);
plot(OAeq,'r');

%%
[xs,ys] = ginput(2);
%%
% xs = 1.0e+06 * [1.5707 2.1706]
% [3827629.13631634;4527600]
fs = 12;
tm = 1.25;
FLIM = [1 10];
ff(800,1000);
EEG_data = {EEG1,EEG2};
rows = 4;
cols = 1;
p_spectrums = {};
ps = {};
iiTitles = {'Left Parietal','Right Parietal'};
caxisVals = []; % 1.0e+05*[0,3]
for ii = 1:2
    subplot(rows,cols,prc(cols,[ii,1]));
    EEG_sub = EEG_data{ii}(round(xs(1)):round(xs(2)));
    EEG_sub = EEG_sub - mean(EEG_sub); % rm DC
    outlierIdx = abs(EEG_sub) > 0.5*10^5;
    EEG_sub(outlierIdx) = NaN;
    OAeq_sub = OAeq(round(xs(1)):round(xs(2)));
    [p_spectrum,f_spectrum,t_spectrum] = pspectrum(double(EEG_sub),Fs,...
        'spectrogram','FrequencyLimits',FLIM);
    p_spectrums{ii} = p_spectrum;
    imagesc(t_spectrum,f_spectrum,p_spectrum);
    colormap(magma);
    c = colorbar;
    ylabel(c,'Power');
    if ii == 1
        caxisVals = caxis/2;
    else
        caxis(caxisVals);
    end
    set(gca,'ydir','normal');
    xlabel('Time (hours)');
    ylabel('Freq (Hz)');
    xticklabels(compose("%1.1f",xticks/60/60));
    yyaxis right;
    plot(equalVectors(OAeq_sub,max(t_spectrum)),'color',[1,1,1,0.3]);
    ylim([-50000 50000]);
    yticks([]);
    set(gca,'ycolor','k');
    set(gca,'fontsize',fs,'TitleFontSizeMultiplier',tm);
    title({iiTitles{ii},'Spectrogram with OA (axy data)'});
    
    [p,f] = pspectrum(double(EEG_sub),Fs,'FrequencyLimits',FLIM);
    subplot(rows,cols,prc(cols,[1,3]));
    plot(f,p,'linewidth',3);
    hold on;
    xlabel('Freq (Hz)');
    ylabel('Power');
    xlim(FLIM);
    set(gca,'fontsize',fs,'TitleFontSizeMultiplier',tm);
    title('Power Spectrum');
    grid on;
end
legend(iiTitles);

subplot(rows,cols,prc(cols,[1,4]));
imagesc(t_spectrum,f_spectrum,p_spectrums{1} - p_spectrums{2});
colormap(gca,magma);
caxis(caxis/2);
set(gca,'ydir','normal');
xlabel('Time (hours)');
ylabel('Freq (Hz)');
% caxis(caxisVals);
xticklabels(compose("%1.1f",xticks/60/60));
c = colorbar;
ylabel(c,'Power');
title(sprintf("%s - %s (difference)",iiTitles{1},iiTitles{2}));
set(gca,'fontsize',fs,'TitleFontSizeMultiplier',tm);

%%
% [x,y] = ginput(1);
% 1.219852355329949e+04
text(x,y,"\leftarrow",'color','red','fontsize',26);
ff(1000,400);
t_sec = linspace(0,round(numel(EEG_sub)/Fs),numel(EEG_sub));
plot(t_sec,EEG_sub,'k','linewidth',2);
xlim([x-3,x+3]);
xlabel('Time (s)');