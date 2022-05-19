function data = seeedMon(varargin)
data = [];
ports = serialportlist("available");
if numel(varargin) > 0
    s = serialport(ports(varargin{1}),115200);
%     for ii = 1:100
        data = read(s,30,"uint8");
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
