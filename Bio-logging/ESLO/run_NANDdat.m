fname = '/Users/matt/ti/workspaces/ESLO_dev/NAND_CC2652RB_LAUNCHXL/memory.dat';
[type,data] = extractNAND(fname);

Fs = 250;
nGain = 12;
eachBit = (3*nGain) / 16777215 / 1000; % 24-bits, mV

theseData = data(type==2);
t = linspace(0,numel(theseData)/Fs,numel(theseData));

close all
ff(1200,800);
subplot(211);
plot(t,double(theseData) * eachBit);
ylabel('mV');

theseData = data(type==4);
t = linspace(0,numel(theseData)/Fs,numel(theseData));
yyaxis right;
plot(t(1:end-1),diff(data(type==4)));
ylim([-1 4]);

subplot(212);
plot(type);