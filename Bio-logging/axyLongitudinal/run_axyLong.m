% three signals were individually smoothed using running means over 1 s. Then for each channel,
% the speciﬁc values for the smoothed data for any particular time interval were subtracted from the
% corresponding unsmoothed data for that time interval to produce a value for g resulting primarily
% from the dynamic acceleration (the static acceleration resulting from body angle with respect to
% gravity having been removed). Derived values were then converted into absolute positive units and
% the resultant values from all three channels then added to each other to give an overall value for
% the triaxial dynamic acceleration - Wilson et al. (2006)

if ~exist('axydata','var')
    axydata = AX3_readFile('/Users/matt/Documents/MATLAB/ARBO/Bio-logging/axyLongitudinal/longitudinal_data.cwa');
    % compute ODA
    axyx = axydata.ACC(:,2) - smoothdata(axydata.ACC(:,2),'movmean',100); %1s smooth
    axyy = axydata.ACC(:,3) - smoothdata(axydata.ACC(:,3),'movmean',100);
    axyz = axydata.ACC(:,4) - smoothdata(axydata.ACC(:,4),'movmean',100);
    ODBA = abs(axyx) + abs(axyy) + abs(axyz);
    ODBA = equalVectors(ODBA,numel(ODBA)/100/60); % to minutes
    timeSec = 1:numel(ODBA); % minutes
    light = normalize(equalVectors(axydata.LIGHT(:,2),timeSec),'range'); % make minutes
end

W = zeros(size(ODBA));
for ii = 1:n
    W = W + smoothdata(ODBA,'loess',1440/ii);
end
W_z = normalize(W,'zscore');
W_bin = zeros(numel(ODBA),1);
W_bin(W_z > 0) = 1;

% Sadeh alg
sadehScore = zeros(size(ODBA));
ODBA_saleh = ODBA*10;
for ii = 6:numel(ODBA_saleh)-6
    std_pastFive = 0.065 * std(ODBA_saleh(ii-5:ii-1));
    std_futrFive = 0.056 * std(ODBA_saleh(ii+1:ii+6));
    cnt_futrOne = 0.073 * ODBA_saleh(ii);
    cnt_all = 1.08 * sum(ODBA_saleh(ii-5:ii+6));
    sadehScore(ii) = 7.601 - std_pastFive - cnt_all - cnt_futrOne;
end
sadehScore = normalize(-sadehScore);
sadeh_bin = zeros(numel(ODBA),1);
sadeh_bin(sadehScore > 0) = 1;

colors = lines(5);

close all
ff(1200,700);
for ii = 1:2
    subplot(2,1,ii);
    plot(sadehScore,'color',colors(3,:),'linewidth',1);
    hold on;
    plot(sadeh_bin+6,'color',colors(3,:),'linewidth',1);
    
    plot(W_z,'color',colors(1,:),'linewidth',1);
    plot(W_bin+6,'color',colors(1,:),'linewidth',1);
    plot(xlim,[0 0],'k:');
    
    yyaxis right;
    plot(ODBA,'color',colors(5,:));
    set(gca,'ycolor',colors(5,:));
    ylabel('ODBA');
    yticks([]);
    
    legend({'Sadeh','asleep/awake','Homeograph','asleep/awake'},'location','eastoutside');
    xlim([1 numel(ODBA)]);
    set(gca,'fontsize',16);
    title('Sadeh vs. Homeograph');
end
xlim([numel(ODBA)-3000 numel(ODBA)]);
title('Zoomed in');

close all
ff(1200,800);

subplot(211);
plot(ODBA,'color',colors(5,:),'linewidth',1);
xlim([1 numel(ODBA)]);
ylabel('ODBA');

yyaxis right;
plot(light,'k-');
ylim([0 5]);
set(gca,'ycolor','k');
ylabel('Light');
yticks([]);
legend({'ODBA','Light'});

set(gca,'fontsize',16);
xlabel('Time (s)');
title('Checking ODBA and Light are similar (both proxies for daytime)');


subplot(212);
plot(ODBA,'color',colors(5,:),'linewidth',1);
xlim([1 numel(ODBA)]);
ylabel('ODBA');

yyaxis right;
plot(W_z,'color',colors(1,:),'linewidth',1.5);
set(gca,'ycolor',colors(1,:));
ylabel('W_z');
hold on;
plot(xlim,[0 0],'k:');
plot(W_bin,'k-','linewidth',1);

set(gca,'fontsize',16);
xlabel('Time (s)');
legend({'ODBA','Homeograph','Asleep/Awake'});
title('Applying sleep-wake algorithm to ODBA');
