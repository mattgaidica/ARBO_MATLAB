file = '/Users/matt/Desktop/memory.dat';
fid = fopen(file);
A = textscan(fid,'%s %s');
fclose(fid);

A = [A{:}];
B = cell2mat(A);
C = hex2dec(B);

data = size(C);
type = size(C);
mode = size(C);
for ii = 1:numel(C)
    data(ii) = bitand(uint32(C(ii)),0x00FFFFFF);
    type(ii) = bitshift(bitand(uint32(C(ii)),0x0F000000),-24);
    mode(ii) = bitshift(bitand(uint32(C(ii)),0xF0000000),-28);
end