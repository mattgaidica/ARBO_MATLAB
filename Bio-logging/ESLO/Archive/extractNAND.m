% typedef enum { // 4bits, 0-15 (16 options)
% 	Type_AbsoluteTime,
% 	Type_RelativeTime,
% 	Type_EEG1,
% 	Type_EEG2,
% 	Type_EEG3,
% 	Type_EEG4,
% 	Type_BatteryVoltage,
% 	Type_AxyXlx,
% 	Type_AxyXly,
% 	Type_AxyXlz,
% 	Type_AxyMgx,
% 	Type_AxyMgy,
% 	Type_AxyMgz,
% 	Type_Temperature,
% 	Type_Error, // needed?
% 	Type_Version
% } ESLO_Type;
function [type,data,labels] = extractNAND(fname,isDat)
% note: type is 0-indexed, labels in MATLAB will be 1-indexed
labels(:,2) = ["AbsoluteTime";"Relative Time";"EEG1";"EEG2";"EEG3";"EEG4";"BatteryVoltage";...
    "XlX";"XlY";"XlZ";"MgX";"MgY";"MgZ";"Temperature";"Error";"Version"];
labels(:,1) = 0:size(labels,1)-1;

fid = fopen(fname);
A = fread(fid,inf);
fclose(fid);

data = int32(zeros(1,0));
type = uint8(zeros(1,0));

sampleCount = 1;
esloVersion = NaN;
% mode is 0
for ii = 1:4:numel(A)
    if isDat
        thisType = uint8(A(ii)); % v1
    else
        thisType = uint8(A(ii+3)); % v2
    end
    
    if thisType == 0xFF % break w/out valid header
        break;
    end
    
    if isDat
        thisData = uint32(0);
        thisData = bitor(thisData, uint32(A(ii+3))); % v1
        thisData = bitor(thisData, bitshift(uint32(A(ii+2)),8)); % v1
        thisData = bitor(thisData, bitshift(uint32(A(ii+1)),16)); % v1
    else
        thisData = uint32(0);
        thisData = bitor(thisData, uint32(A(ii))); % v2
        thisData = bitor(thisData, bitshift(uint32(A(ii+1)),8)); % v2
        thisData = bitor(thisData, bitshift(uint32(A(ii+2)),16)); % v2
    end
    
    if (bitget(thisData,24) == 1) % apply sign
        thisData = bitor(thisData,0xFF000000);
    end
    thisData = typecast(thisData,'int32');
    
    if thisType == 0x0F
        if ii == 1
            esloVersion = thisData;
        else
            if thisData ~= esloVersion
                break; % no longer from same session
            end
        end
    end
    
    type(sampleCount) = thisType;
    data(sampleCount) = thisData;
    sampleCount = sampleCount + 1;
end
end

function data = gainEEG(data,nGain)
eachBit = (3/nGain) / 16777215; % 24-bits
end

