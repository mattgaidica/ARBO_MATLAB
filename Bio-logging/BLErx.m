portname = '/dev/tty.usbmodemL5001NUI1';
baud = 115200;
intS = 2;
% out1 = instrfind('Type', 'serial')
% 
% s = serialport(portname,baud);
% 
% data = read(s, s.NumBytesAvailable, "uint8");

if ~exist('s')
    s = serialport(portname,baud);
end

hWaitbar = waitbar(0, 'Iteration 1', 'Name', 'ESLO','CreateCancelBtn','delete(gcbf)');
set(hWaitbar,'Position',[500,500,360,78]);
flush(s);
h = ff(1200,400);
pause(intS);
ii = 0;
while(true)
    ii = ii + 1;
    data = read(s, s.NumBytesAvailable, "uint8");

    idx = [];
    for iData = 1:numel(data)-3
        if data(iData) == 1 && data(iData+1) == 2 && data(iData+2) == 3
            idx(numel(idx)+1) = iData;
        end
    end

    int32Data = [];
    for iidx = 1:numel(idx)
        dataStart = idx(iidx) + 4;
        dataEnd = dataStart + 24 - 1;
        if dataEnd <= numel(data)
            re_data = reshape(data(dataStart:dataEnd),[3,8])';
            for iRow = 1:6
                t = swapbytes(typecast(uint8([0x00 re_data(iRow,:)]),'int32'));
                if bitand(t,typecast(0x00800000,'int32')) > 0
                    t = bitor(t,typecast(0xFF000000,'int32'));
                end
                int32Data(numel(int32Data)+1) = t;
            end
        end
    end
    figure(h);
    plot(int32Data,'k');
    xlim([1 numel(int32Data)]);
    title(ii);
    drawnow;
    
    pause(intS);
    
    if ~ishandle(hWaitbar)
        close(h)
        break;
    else
        waitbar(ii,hWaitbar, ['Iteration ' num2str(ii)]);
    end
end