clc
% close all
f = 250;
sdPath = '/Volumes/ARBO';
files = dir(sdPath);
name = files(end).name;
disp(['Reading file: ',name]);
% fileID = fopen(fullfile(sdPath,name));
A = readmatrix(fullfile(sdPath,name));
t = linspace(0,numel(A)/f,numel(A));
figure;
plot(t,A);
xlabel('Time (s)');