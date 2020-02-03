function [A,t] = arbo_read32(filename,Fs)
A = fread(fopen(filename),'int32','b');
t = linspace(0,numel(A)/Fs,numel(A));