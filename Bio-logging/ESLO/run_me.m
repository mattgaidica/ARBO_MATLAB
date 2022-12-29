if do
    fname = '/Volumes/LEXAR633X/ESLORB2.TXT';
    [type,data,labels] = extractSD(fname);
%     do = 0;
end

SDreport(type,labels);
axyFs = 1;

x = data(type==7);
y = data(type==8);
z = data(type==9);
OA = axyOA(x,y,z,axyFs);

allTempLocs = find(type==13);
allTemp = data(type==13);
allxLocs = find(type==7);
temp = [];
for ii = 1:numel(allxLocs)
    nearestId = find(allTempLocs < allxLocs(ii),1,'last');
    fprintf("xid: %i, nearesttemp: %i\n",ii,nearestId);
    shiftdata = data(allTempLocs(nearestId));
    temp(ii) = double(shiftdata)/1000000;
end

t = linspace(0,numel(OA)/60,numel(OA));
close all
ff(1200,400);
plot(t,OA,'k-','linewidth',2);
ylabel('ODBA');
yyaxis right;
plot(t,temp,'r-','linewidth',0.5);
ylabel('Temp (C)');
set(gca,'ycolor','r');
hold on;
plot(t,smoothdata(temp,'gaussian',60),'r--','linewidth',1);
xlabel('Time (min)');
xlim([min(t) max(t)]);
grid on;
set(gca,'fontsize',14);
%%
close all
shiftdata = bitshift(data(type==13),8);
temp = double(shiftdata)/1000000;
ff(1200,400);
plot(temp,'r-','linewidth',0.5);
ylabel('Temp (C)');
set(gca,'ycolor','r');
hold on;
plot(smoothdata(temp,'gaussian',60),'r--','linewidth',1);
xlabel('Time (s)');
grid on;
set(gca,'fontsize',14);