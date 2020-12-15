% data
% [2,1,6...] flags
% [(153),MFG_DATA=255,eegAdvCount,iEEG,data...] (153)=ndata
clc
disp('To record, press Left button, then Right button...');

portname = '/dev/tty.usbmodemL5001NUI1';
baud = 115200;
eegHeader = [2,1,6];
eegDataBit = 7;
eegDataLength = 157; % total packet length
Fs = 250;
showSec = 4;
useFilter = false;
EEG_N_SAMPLE = 50; % from simple_broadcaster, simple_central

doSave = true;
savePath = '/Users/matt/Documents/MATLAB/ARBO/Bio-logging/ESLO/recordings';
fileIsOpen = false;
countSplitFile = Fs * 60;
dataCount = 0;

if exist('s','var')
    try
        flush(s);
    catch ME
        delete(s);
        s = serialport(portname,baud);
    end
else
    s = serialport(portname,baud);
end

close all;
try
    close(hWaitbar);
catch ME
end

flush(s);
ii = 0;
data = [];
compile_iAdv = [];
dispBuffer = NaN(Fs * showSec,1);
needPlot = true;
while(true)
    pause(0.5);
    if s.NumBytesAvailable > 1
        ii = ii + 1;
        data = [data read(s, s.NumBytesAvailable, "uint8")]; % rolling buffer
        
        idx = strfind(data,[2,1,6]);
        
        if isempty(idx)
            pause(0.1);
            % give buffer time to recieve
            if s.NumBytesAvailable == 0
                clc;
                vt100(data);
            end
            continue;
        end
        
        compile_iAdv = [compile_iAdv data(idx+5)];
        
        int32Data = [];
        for iidx = 1:numel(idx)
            dataStart = idx(iidx) + eegDataBit;
            dataEnd = dataStart + eegDataLength - eegDataBit - 1;
            if dataEnd <= numel(data)
                iEEG = data(dataStart - 1);
                re_data = reshape(data(dataStart:dataEnd),[3,(dataEnd-dataStart+1)/3])';
                nanRows = 0;
                if iEEG ~= EEG_N_SAMPLE-1
                    nanRows = iEEG + 1;
                end
                for iRow = 1:size(re_data,1)
                    t = NaN;
                    if iRow > nanRows
                        t = swapbytes(typecast(uint8([0x00 re_data(iRow,:)]),'int32'));
                        if bitand(t,typecast(0x00800000,'int32')) > 0
                            t = bitor(t,typecast(0xFF000000,'int32'));
                        end
                    end
                    int32Data(numel(int32Data)+1) = t;
                end
            end
        end
        
        if numel(int32Data) > numel(dispBuffer)
            int32Data = int32Data(end-numel(dispBuffer)+1:end);
        end
        
        % maintain end of buffer
        if dataEnd == numel(data)
            data = [];
        else
            data = data(dataEnd+1:end);
        end
        
        dispBuffer = circshift(dispBuffer,-numel(int32Data));
        dispBuffer(end-numel(int32Data)+1:end) = int32Data';
        
        if needPlot
            h = ff(1300,400);
            hWaitbar = waitbar(0, 'Iteration 1', 'Name', 'ESLO','CreateCancelBtn','delete(gcbf)');
            set(hWaitbar,'Position',[0,0,360,78]);
            needPlot = false;
        end
        
        if (~fileIsOpen || dataCount > countSplitFile) && doSave
            dt = datestr(now,'yyyymmdd-HHMMSS');
            saveFile = fullfile(savePath,[dt,'.csv']);
            dataCount = 0;
            fileIsOpen = true;
        end
        
        if doSave
            writematrix(int32Data,saveFile,'WriteMode','append');
            dataCount = dataCount + numel(int32Data);
        end
        
        t = linspace(0,numel(dispBuffer)/Fs,numel(dispBuffer));
        figure(h);
        if useFilter
            sData = smoothdata(dispBuffer,'gaussian',10);
        else
            sData = dispBuffer;
        end
        plot(t,sData,'k');
        xlim([min(t) max(t)]);
        xticks(min(t):max(t));
        if ~any(isnan(dispBuffer))
            ylim([min(sData)-std(dispBuffer) max(sData)+std(dispBuffer)]);
        end
        xlabel('Time (s)');
        ylabel('a.u.');
        set(gca,'fontsize',14);
        title(ii);
        drawnow;
    end
    
    if exist('hWaitbar','var')
        if ~ishandle(hWaitbar)
            if ~needPlot
                close(h)
                break;
            end
        else
            if fileIsOpen
                waitbar(dataCount/countSplitFile,hWaitbar,...
                    sprintf("Writing %s (ii=%i)",dt,ii),'textInterpreter','None');
            else
                waitbar(ii,hWaitbar,sprintf("Not writing (ii=%i)",ii));
            end
        end
    end
end