function [tempF,tempC] = convertTemp(data)

% Float(pointer.load(fromByteOffset:4, as: Int32.self)) / 1000000
tempC = cast(data,'double') / 1000000;
tempF = tempC * 1.8 + 32;