% square wave (23.arbo)
% filePath = '/Users/matt/Documents/MATLAB/ARBO/Bio-logging/00000023.arbo';
doDebug = false;
filePath = '/Volumes/ARBO/00000003.arbo';
fileID = fopen(filePath);
A = fread(fileID,'uint32','b');
Fs = 250;

if doDebug
    headerCodes = [];
    for ii = 1:numel(A)
        headerCodes(ii) = bitshift(bitand(A(ii),0xFF000000),-24);
    end
    figure;plot(unwrap(headerCodes)); % should be straight
end

dataStruct = cell(7,1);
for ii = 1:numel(A)
    headerCode = bitshift(bitand(A(ii),0xFF000000),-24);
    data = bitand(A(ii),0x00FFFFFF);
%     if ismember(headerCode,1:4)
        % convert 2's compliment
        if bitget(bitand(data,0x00800000),24)
            data = bitor(data,0xFF000000);
        end
%     end
    % just use int32(data)?
    dataStruct{headerCode} = [dataStruct{headerCode} typecast(data,'int32')];
end

close all
colors = lines(numel(dataStruct));
ff(1000,800);
for headerCode = 1:size(dataStruct,1)
    subplot(size(dataStruct,1),1,headerCode);
    if ~isempty(dataStruct{headerCode})
        dl = size(dataStruct{headerCode},2);
        t = linspace(0,dl/Fs,dl);
        plot(t,dataStruct{headerCode},'color',colors(headerCode,:));
        xlabel('Time (s)');
        xlim([0 max(t)]);
    end
%     ylim([-4*10e3 4*10e3]);
end