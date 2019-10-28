% https://www.mathworks.com/help/matlab/ref/serialport.html
while(true)
    ports = seriallist;
    c = clock;
    clc;
    disp(num2str(c(end)));
    for ii = 1:numel(ports)
        disp(ports(ii));
    end
end