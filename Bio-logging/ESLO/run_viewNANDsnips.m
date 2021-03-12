useSamples = 10000;
useType = 5;

close all;
ff(1200,600);

for iType = 2:5
    subplot(2,2,iType-1);
    theseData = find(type==iType);
    nSamples = min([numel(theseData),useSamples]);
    plot(data(theseData(1:nSamples)));
    title(sprintf('EEG CH%i',iType-1));
end

ff(1200,600);
subplot(211);
for iType = 7:9
    theseData = find(type==iType);
    nSamples = min([numel(theseData),useSamples]);
    plot(data(theseData(1:nSamples)));
    hold on
    title(sprintf('XL XYZ'));
end

subplot(212);
for iType = 10:12
    theseData = find(type==iType);
    nSamples = min([numel(theseData),useSamples]);
    plot(data(theseData(1:nSamples)));
    hold on
    title(sprintf('MG XYZ'));
end

%%
clc
for iType = 0:12
    fprintf('%s: %i samples\n',labels(iType+1,2),sum(type==iType));
end