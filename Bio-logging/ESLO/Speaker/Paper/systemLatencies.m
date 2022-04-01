clc
datFile = 'swaAlgo_2-5Hz.dat';
Compute = readtable(datFile,'Format','%q');
Compute.latency = hex2dec(Compute.latency) / 1000; % to ms
fprintf('compute latency 2.5Hz: %1.2f ± %1.2f ms\n',mean(Compute.latency),std(Compute.latency));

datFile = 'swaAlgo_1-0Hz.dat';
Compute = readtable(datFile,'Format','%q');
Compute.latency = hex2dec(Compute.latency) / 1000; % to ms
fprintf('compute latency 1Hz: %1.2f ± %1.2f ms\n',mean(Compute.latency),std(Compute.latency));

datFile = 'wirelessLatency.dat';
Compute = readtable(datFile,'Format','%q');
Compute.latency = hex2dec(Compute.latency) / 1000; % to ms
fprintf('wireless latency: %1.2f ± %1.2f ms\n',mean(Compute.latency),std(Compute.latency));