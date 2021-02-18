function [type,data] = extractNAND(fname)
    if strcmp(fname,'')
        fname = '/Users/matt/ti/workspaces/ESLO_dev/NAND_CC2652RB_LAUNCHXL/memory.dat';
    end
    fid = fopen(fname);
    A = fread(fid,inf);
    fclose(fid);

    data = int32(zeros(1,0));
    type = uint8(zeros(1,0));

    sampleCount = 1;
    esloVersion = NaN;
    % mode is 0
    for ii = 1:4:numel(A)
        thisType = uint8(A(ii+3)); % v2
        
        if thisType == 0xFF % break w/out valid header
            break;
        end
        
        thisData = uint32(0);
        thisData = bitor(thisData, uint32(A(ii))); % v2
        thisData = bitor(thisData, bitshift(uint32(A(ii+1)),8)); % v2
        thisData = bitor(thisData, bitshift(uint32(A(ii+2)),16)); % v2
        
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

