fs = 125;
eegStart = 12;
if do
    h5file = '/Users/matt/Documents/Data/Sleep/dreem/X_train_KBHhQ0d.h5';
    h5disp(h5file);
    trainfile = '/Users/matt/Documents/Data/Sleep/dreem/y_train_2.csv';
    tr = readmatrix(trainfile);
    data = h5read(h5file,'/features');
    do = false;
end
f1 = 0.5;
f2 = 4;
[A,B,C,D] = ellip(10,0.5,40,[f1/fs*2 f2/fs*2]);
sos = ss2sos(A,B,C,D);
[f,gof] = filterPhaseCorrection(sos,fs,f1,f2);

SWA_HA_idx = find(tr(:,2) == 2);
testSec = 1;
dp_fft_mean = [];
plv_fft = [];
endIdx = 7 * fs;
trainSecs = 0.5:0.5:3;%linspace(0.5,2,5);
all_freqs = [];

corrSamples = round(fs*0.25);

% close all
doDebug = 0;
for iTrain = 1:numel(trainSecs)
    trainSec = trainSecs(iTrain);
    trainSamples = round(trainSec*fs);
    for useHA = 1:10000%numel(SWA_HA_idx)
        fprintf('train:%03d HA:%03d\n',iTrain,useHA);
        x = data(endIdx-round((trainSec+testSec)*fs)+1:endIdx,SWA_HA_idx(useHA));
        y = sosfilt(sos,x);
        train_data = y(1:round(fs*trainSec));
        test_data = y(end-round(fs*testSec)+1:end);
        

        [freq,phase] = dominantFFT(train_data,fs,f1,f2);
        all_freqs(iTrain,useHA) = freq;
        correction = 0;%wrapToPi(feval(f,freq)); % bound
        t_mod = 1/fs : 1/fs : (numel(x)/fs);
        fcast_corr = cos((2*pi*freq*t_mod) + phase - correction)';
%         fcast_data_fft = fcast_corr(end-round(fs*testSec)+1:end)';

        % PLV
        h_test = angle(hilbert(y));
        h_fft = angle(hilbert(fcast_corr));
        r = circ_mean(circ_dist(h_test(trainSamples-corrSamples+1:trainSamples),...
            h_fft(trainSamples-corrSamples+1:trainSamples)));
        h_test = h_test(end-round(fs*testSec)+1:end) - r;
        h_fft = h_fft(end-round(fs*testSec)+1:end);
        dp_fft = wrapToPi(h_fft - h_test);
        dp_fft_mean(iTrain,useHA,:) = dp_fft;
        plv_fft(iTrain,useHA) = abs(sum(exp(1i*(dp_fft))))/length(dp_fft);
        
        if doDebug
            h = ff(800,500);
            t_debug = linspace(-trainSec,testSec,numel(x));
            subplot(211)
            plot(t_debug,x,'k:');
            hold on
            plot(t_debug,y,'linewidth',2,'color',lines(1));
            xlim([min(t_debug) max(t_debug)]);
            ylabel('Amplitude');
            yyaxis right;
            set(gca,'ycolor','r');
            plot(t_debug,fcast_corr,'r','linewidth',2);
            hold on;
            plot([0 0],ylim,'k--');
            legend({'raw EEG','filtered','forecasted','train/test'},'location','northwest');
            set(gca,'fontsize',14);
            title(sprintf('Elliptical filter %1.1f?%1.1fHz',f1,f2));
            grid
            
            subplot(212)
            plot(t_debug,angle(hilbert(y)),'color',lines(1),'linewidth',2);
            hold on;
            plot(t_debug,angle(hilbert(fcast_corr)),'r','linewidth',2);
            plot([0 0],ylim,'k--');
%             plot(angle(hilbert(fcast_corr))-angle(hilbert(y)),'r:');
%             legend({'fft','test','diff'});
            ylim([-pi pi]);
            xlim([min(t_debug) max(t_debug)]);
            title(sprintf('PLV=%1.2f',plv_fft(iTrain,useHA)));
            set(gca,'fontsize',14);
            legend({'filtered phase','forecasted phase','train/test'},'location','northwest');
            xlabel('Time (s)');
            ylabel('Phase (rad)');
            grid
            
            close(h);
        end
    end
end

%% PLOT
% close all
mu_arr = [];
ul_arr = [];
ll_arr = [];
for iTrain = 1:numel(trainSecs)
    for iTest = 1:size(dp_fft_mean,3)
        [mu,ul,ll] = circ_mean(dp_fft_mean(iTrain,:,iTest)');
        mu_arr(iTrain,iTest) = (mu);
        ul_arr(iTrain,iTest) = (ul);
        ll_arr(iTrain,iTest) = (ll);
    end
end
t_train = linspace(0,testSec,size(ul_arr,2));

ff(400,200);
imagesc(t_train,trainSecs,unwrap(mu_arr,pi,2));
if false
    ff(400,400);
    imagesc(t_train,trainSecs,abs(unwrap(mu_arr_notOpt,pi,2) - unwrap(mu_arr_Opt,pi,2)));
    colorbar;
    caxis([0 0.5]);
    
    close all
    ff(800,350);
    mu_un = unwrap(mu_arr_notOpt(4,:));
    errBar = [];
    errBar(1,:) = unwrap(ul_arr_notOpt(4,:)) - mu_un;
    errBar(2,:) = mu_un - unwrap(ll_arr_notOpt(4,:));
    H1 = shadedErrorBar(t_train,mu_un,errBar,'lineProps',{'-k'});
    
    mu_un = unwrap(mu_arr_opt(4,:));
    errBar = [];
    errBar(1,:) = unwrap(ul_arr_opt(4,:)) - mu_un;
    errBar(2,:) = mu_un - unwrap(ll_arr_opt(4,:));
    H2 = shadedErrorBar(t_train,mu_un,errBar,'lineProps',{'-g'});
    
    hold on;
    H3 = plot(t_train,mu_arr_notOpt(4,:)-unwrap(mu_arr_opt(4,:)),'k:');
    
    title({'Phase w/ 2s Training'});
    legend([H1.mainLine,H2.mainLine,H3],{'Non-optimized','0.25s Optimized','Difference'},...
        'location','northwest');
    set(gca,'fontsize',14);
    xlim([min(t_train) max(t_train)]);
    grid;
    ylabel({'','Phase Error (rad)'});
    xlabel({'Test (s)',''});
    
    
    mu_arr_opt = mu_arr;
    ul_arr_opt = ul_arr;
    ll_arr_opt = ll_arr;
    
    mu_arr_notOpt = mu_arr;
    ul_arr_notOpt = ul_arr;
    ll_arr_notOpt = ll_arr;
end
caxis([0 pi]);
% set(gca,'ydir','normal');
set(gca,'fontsize',14);
title('Phase error');
ylabel({'','Train (s)'});
xlabel({'Test (s)',''});
c = colorbar;
c.Label.String = 'radians';
%%
ff(300,900);
rows = numel(trainSecs);
cols = 1;

colors = cool(numel(trainSecs));
for iTrain = 1:numel(trainSecs)
    subplot(rows,cols,iTrain);
    plot(t_train,unwrap(mu_arr(iTrain,:)),'-','color','k','lineWidth',2);
    hold on;
    plot(t_train,unwrap(ul_arr(iTrain,:)),':','color','k','lineWidth',1);
    plot(t_train,unwrap(ll_arr(iTrain,:)),':','color','k','lineWidth',1);
    xlabel('Test (s)');
    xlim([0 max(t_train)]);
    title(sprintf('Trained with %1.1fs of data',trainSecs(iTrain)));
    ylim([0 pi]);
    yticks(ylim);
    yticklabels({'0','\pi'});
    set(gca,'fontsize',12);
    ylabel('Mean Phase');
    grid
end

%%
ff(600,800);
subplot(211);
colors = cool(numel(trainSecs));
useEnd = false;
for iTrain = 1:numel(trainSecs)
    if useEnd
        h = polarhistogram(squeeze(dp_fft_mean(iTrain,:,end)),20);
    else
        h = polarhistogram(squeeze(dp_fft_mean(iTrain,:,1)),20);
    end
    h.DisplayStyle = 'stairs';
    h.EdgeColor = colors(iTrain,:);
    h.LineWidth = 2;
    hold on;
end
if useEnd
    title(sprintf('Phase diff @ %1.1fs',testSec));
else
    title(sprintf('Phase diff @ %1.1fs',0));
end

subplot(212);
plot(trainSecs,mean(plv_fft,2),'k-');
hold on;
for iTrain = 1:numel(trainSecs)
    plot(trainSecs(iTrain),mean(plv_fft(iTrain,:)),'.','markerSize',50,'color',colors(iTrain,:));
end
ylim([0.5 0.7]);
% legend(['PLV trend',compose('%1.1f train',trainSecs)],'fontsize',14,'location','northwest');
% yyaxis right;
% plot(trainSecs,mean(dp_fft_mean,2));
% ylim([0 pi]);
xlabel('Train (s)');
ylabel('PLV');
title({'PLV vs. Train Window','(1s Test Window)'});
set(gca,'fontsize',14);
grid