clc
close all
sdPath = '/Volumes/ARBO';
files = dir(sdPath);
name = files(end).name;
disp(['Reading file: ',name]);
fileID = fopen(fullfile(sdPath,name));
A = fread(fileID,'int32','b');
figure;
plot(A(2:end));
title(name);