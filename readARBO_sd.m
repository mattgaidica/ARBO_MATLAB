clc
sdPath = '/Volumes/ARBO/ARBO.TXT';
fileID = fopen(sdPath);
A = fread(fileID,'uint32');
figure;
plot(A(2:end));