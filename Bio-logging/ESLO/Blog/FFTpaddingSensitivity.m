fs = 250;
eegStart = 12;
if do
    h5file = '/Users/matt/Documents/Data/Sleep/dreem/X_train_KBHhQ0d.h5';
    h5disp(h5file);
    trainfile = '/Users/matt/Documents/Data/Sleep/dreem/y_train_2.csv';
    tr = readmatrix(trainfile);
    data = h5read(h5file,'/features');
    do = false;
end

Hd = eslo_lp_ellip;
nTrial = 1;
padFactor = 1:10;
results_phase = zeros(nTrial,numel(padFactor));
results_freq = zeros(nTrial,numel(padFactor));
ff(600,500);
for iTrial = 8%1:nTrial
    x = data(eegStart:end,iTrial);
    x = x(1:1024);
    y = sosfilt(Hd.sosMatrix,x);
    % setup FFT
    L = numel(y);
    lns = [];
    for iPad = 1:numel(padFactor)
        n = (2^nextpow2(L)) * padFactor(iPad); % force zero padding for interpolation
%         z = repmat(y,padFactor(iPad),1);
%         n = numel(z);
        Y = fft(y,n); % remember, Y is complex
        f = fs*(0:(n/2))/n;
        P = abs(Y/n).^2; % power of FFT
        A = angle(Y); % phase of FFT
        Psub = P(1:n/2+1); % make power one-sided
        Asub = A(1:n/2+1); % make phase one-sided
        [v,k] = max(Psub); % find dominant frequency of filtered signal
        freq = f(k);
        phase = Asub(k); % use k (key) to identify dominant phase
        results_phase(iTrial,iPad) = phase;
        results_freq(iTrial,iPad) = freq;
        
        if iPad == 1
            subplot(311);
            plot(x,'k','linewidth',2);
            ylabel('amplitude');
            yyaxis right;
            plot(y,'r','linewidth',2);
            xlabel('samples');
            grid on;
            set(gca,'ycolor','r');
            xlim([1 numel(x)]);
            set(gca,'fontsize',14);
            legend({'original','filtered'});
        end
        
        if iPad == 1 || iPad == 10
            subplot(312);
            lns(numel(lns)+1) = plot(f,normalize(Psub,'range'),'linewidth',2);
            hold on;
            xlim([0 4]);
            ylim([0 1]);
            hold on;
            plot([freq,freq],ylim,'k--');
            grid on
            legend(lns,{'n=1','n=10'});
            set(gca,'fontsize',14);
            xlabel('freq (Hz)');
            ylabel('power (a.u.)');

            subplot(313);
            plot(f,Asub,'linewidth',2);
            hold on;
            xlim([0 4]);
            ylim([-pi pi]);
            plot([freq,freq],ylim,'k--');
            set(gca,'fontsize',14);
            xlabel('freq (Hz)');
            ylabel('phase (rad)');
            grid on
        end
        
    end
end

%% plot
close all
ff(800,600);
rows = 2;
cols = 1;
% subplot(221);
% for iTrial = 1:nTrial
%     diffData = abs(wrapToPi(diff(results_phase(iTrial,:))));
%     plot(padFactor,[0 diffData],'color',repmat(0.2,[1,4]));
%     hold on;
% end
% set(gca,'fontsize',14);
% xlabel('padFactor (n)');
% ylabel(['\delta ',char(177),'phase (rad)']);
% title('Phase difference after padding n times');
% ylim([0 pi]);
% xlim(size(diffData));

subplot(rows,cols,1);
for iTrial = 1:nTrial
    diffData = (wrapToPi(results_phase(iTrial,:)-results_phase(iTrial,end)));
    plot(padFactor,diffData,'color',repmat(0.025,[1,4]));
    hold on;
end
set(gca,'fontsize',14);
xlabel('padFactor (n)');
ylabel(['\delta ',char(177),'phase (rad)']);
title('Phase difference after padding n times');
ylim([-pi pi]);
xlim(size(diffData));

subplot(rows,cols,2);
for iTrial = 1:nTrial
    diffData = abs(wrapToPi(results_phase(iTrial,:)-results_phase(iTrial,end)));
    plot(padFactor,diffData,'color',repmat(0.025,[1,4]));
    hold on;
end
set(gca,'fontsize',14);
xlabel('padFactor (n)');
ylabel(['\delta ',char(177),'phase (rad)']);
title('Phase difference after padding n times');
ylim([0 pi]);
xlim(size(diffData));

% subplot(212);
% for iTrial = 1:nTrial
%     diffData = abs(diff(results_freq(iTrial,:)));
%     plot(padFactor(2:end),diffData,'color',repmat(0.2,[1,4]));
%     hold on;
% end
% set(gca,'fontsize',14);
% xlabel('padFactor (n)');
% ylabel(['\delta ',char(177),'freq (Hz)']);
% title('Freq difference after padding n times');
% ylim([-pi pi]);

%% stats
radSweep = [pi/2, pi/4, pi/8, pi/16];
a = abs(wrapToPi(results_phase(:,:)-results_phase(:,end)));
results_rad = zeros(numel(padFactor),numel(radSweep));
for iPad = 1:numel(padFactor)
    for iRad = 1:numel(radSweep)
        results_rad(iPad,iRad) = 100*sum(a(:,iPad) > radSweep(iRad))/size(a,1);
    end
end

close all
ff(600,600);
for iPlot = 1:2
    subplot(2,1,iPlot);
    for iRad = 1:numel(radSweep)
        plot(results_rad(:,iRad),'linewidth',2);
        hold on;
    end
%     ylim([0 1]);
    xlabel({'padFactor (n)',''});
    xlim([1 size(results_rad,1)]);
    ylabel('Fraction of data > r');
    set(gca,'fontsize',14);
    title({'','Phase difference statistics'});
    grid on
    if iPlot == 1
        set(gca,'yscale','linear');
        legend({['r = ',char(177),'\pi/2'],...
            ['r = ',char(177),'\pi/4'],...
            ['r = ',char(177),'\pi/8'],...
            ['r = ',char(177),'\pi/16'],...
            },'location','northeast');
    else
        set(gca,'yscale','log');
    end
end