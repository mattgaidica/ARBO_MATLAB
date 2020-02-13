clc
% close all
f = 250;
% sdPath = '/Volumes/ARBO SAM';
sdPath = '/Users/matt/Desktop/HR';
files = dir(sdPath);
name = files(end).name;
disp(['Reading file: ',name]);
fileID = fopen(fullfile(sdPath,name));
A = fread(fileID,'int32','b');
t = linspace(0,numel(A)/f,numel(A));

figure('position',[0 0 900 600]);
subplot(211);
plot(t,A,'k');
xlabel('Time (s)');
subplot(212);
plot(t,A,'k');
xlabel('Time (s)');
xlim([0,5]);
title({name,[num2str(numel(A)*4),' bytes',', ',num2str(numel(A)),' 32-bit samples']});