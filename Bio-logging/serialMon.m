function serialMon(varargin)
ports = serialportlist("available");
if numel(varargin) > 0
    s = serialport(ports(varargin{1}),9600);
    figure;
    for ii=1:100
        data = read(s,50,"int32");
        plot(data);
        drawnow;
    end
else % list them
    clc;
    for iPort = 1:numel(ports)
        if contains(ports(iPort),"cu.")
            fprintf("%i: %s \n",iPort,ports(iPort));
        end
    end
end

% while(true)
%     ports = serialportlist;
%     c = clock;
%     clc;
%     disp(num2str(c(end)));
%     for ii = 1:numel(ports)
%         disp(ports(ii));
%     end
% end