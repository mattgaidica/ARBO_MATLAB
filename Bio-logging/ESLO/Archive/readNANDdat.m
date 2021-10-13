clear all
fname = '/Users/matt/ti/workspaces/ESLO_dev/NAND_CC2652RB_LAUNCHXL/memory.dat';
isDat = true;
% fname = '/Users/matt/ti/workspaces/ESLO_dev/NAND_CC2652RB_LAUNCHXL/memory_20210105_InesMouse.dat';
% fname = '/Users/matt/ti/workspaces/ESLO_dev/NAND_CC2652RB_LAUNCHXL/memory_20210108_MattHeart.dat';
% fname = '/Users/matt/ti/workspaces/ESLO_dev/NAND_CC2652RB_LAUNCHXL/memory.dat';
% fid = fopen(fname);

% A = fread(fid,inf);
% A = A(1:20000); %
% A = A(4097:end); % Heart
% A = A(262145:(262145+50000-1)); % Ines
% fclose(fid);

% video is 1:28:55, = 88:55
% stoped at 12:10PM, -1:10 in video
% best sleep at ~11:55, -15min video, +73min
% % type = A(1:4:end);
% % A = A(1:(find(type==255,1,'first')-1)*4);
% % secRec = sum(type)/250;
% % t = linspace(0,5335,numel(A));
% % startId = closest(t,45*60);
% % startId = startId - mod(startId,4) + 1; % empirical + 1
% % endId = closest(t,50*60);
% % endId = endId - mod(endId,4);
% % A = A(startId:endId);

[type,data,labels] = extractNAND(fname,isDat);
SDreport(type,labels);
%%
close all
colors = lines(10);
ff(1200,800);
axs = [];
rowCount = 0;
Fs = 128;
Hd = filt_4Hzbutter;

for ii = 2:5
    theseData = data(type == ii);
    theseData = normalize(theseData,'range');
    theseData = theseData - mean(theseData) + rowCount;
    y = filter(Hd,theseData);
    
    t = linspace(0,numel(theseData)/Fs,numel(theseData));
    
    subplot(311);
    lns(rowCount+1) = plot(t,theseData,'color',colors(rowCount+1,:));
    hold on;
%     plot(t,normalize(y,'range')-0.5 + rowCount,'color','r');
    
    subplot(312);
    L = numel(t);
    n = (2^nextpow2(L))*5; % force zero padding for interpolation
    Y = fft(theseData-mean(theseData),n); % remember, Y is complex
    f = Fs*(0:(n/2))/n;
    P = abs(Y/n).^2; % power of FFT
    Psub = P(1:n/2+1); % make power one-sided
    plot(f,normalize(smoothdata(Psub,'movmedian',numel(Psub)/700),'range'));
    hold on;
    
    rowCount = rowCount + 1;
end
axs(1) = subplot(311);
yticks([0:rowCount-1]);
ylim([-1 3]);
legend(lns,{'Ch1','Ch2','Ch3','Ch4'},'location','northwest');
xlim([min(t) max(t)]);
xlabel('Time (s)');
ylabel('Amplitude (a.u.)');
set(gca,'fontsize',14);
grid on;
set(gca,'XGrid','off');
title('EEG');

subplot(312);
ylim([0 1]);
xlim([0 65]);
xticks([0:2:10,20:10:100]);
xlabel('Freq. (Hz)');
ylabel('Amplitude (a.u.)');
set(gca,'fontsize',14);
title('FFT of EEG');

% axs(2) = subplot(313);
% Fs = 25;
% for ii = 7:9
%     theseData = data(type == ii);
%     t = linspace(0,numel(theseData)/Fs,numel(theseData));
%     plot(t,theseData - mean(theseData),'color',colors(ii-3,:));
%     hold on;
% end
% legend({'axy x','axy y','axy z'},'location','northwest');
% xlim([min(t) max(t)]);
% xlabel('Time (s)');
% ylabel('Amplitude (a.u.)');
% set(gca,'fontsize',14);
% grid on;
% set(gca,'XGrid','off');
% ylim([-0.5 0.5]*10^4);
% yticks(sort([0,[-0.5 0.5]*10^4]));
% title('Accelerometer');

Fs = 1/60;
yyaxis right;
theseData = data(type == 6);
t = linspace(0,numel(theseData)/Fs,numel(theseData));
plot(t,double(theseData) / 10^6,'r');
set(gca,'ycolor','r');
ylabel('Battery (V)');
ylim([2.3 3.3]);
yticks([2.4:0.1:3.0]);

linkaxes(axs,'x');


% A = textscan(fid,'%s %s');
% fclose(fid);
%
% A = [A{:}];
% B = cell2mat(A);
% C = hex2dec(B);
%
% data = size(C);
% type = size(C);
% mode = size(C);
% for ii = 1:numel(C)
%     data(ii) = bitand(uint32(C(ii)),0x00FFFFFF);
%     type(ii) = bitshift(bitand(uint32(C(ii)),0x0F000000),-24);
%     mode(ii) = bitshift(bitand(uint32(C(ii)),0xF0000000),-28);
% end