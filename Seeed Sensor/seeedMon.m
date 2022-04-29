function data = seeedMon(varargin)
data = [];
ports = serialportlist("available");
if numel(varargin) > 0
    s = serialport(ports(varargin{1}),9600);
%     for ii = 1:100
        data = read(s,200,"uint8");
%     end
else % list them
    clc;
    for iPort = 1:numel(ports)
        if contains(ports(iPort),"cu.")
            fprintf("%i: %s \n",iPort,ports(iPort));
        end
    end
end

%%
payload = [0x53,0x59,0x01,0x01,0x00,0x01,0x0f,1,0x54,0x43];
write(s,payload,"uint8");
data = read(s,10,"uint8");