function FixCodes(fileName)
% FixCodes - Fixes new Nex files to have the old marker codes.
%
%

% Check the number of inputs.
narginchk(1, 1);

% Make sure the nex file exists.
assert(logical(exist(fileName, 'file')), 'Cannot find file: %s', fileName);

% Read the data file.
nexData = readNexFile(fileName);

% Convert the list marker codes into a vector.
markerValues = cellfun(@(x) abs(str2double(x)), nexData.markers{1}.values{1}.strings);
numValues = length(markerValues);

% This is our value map.
mapVals(150) = 105;
mapVals(158) = 97;
mapVals(156) = 99;
mapVals(154) = 101;
mapVals(152) = 103;
mapVals(199) = 56;
mapVals(207) = 48;
mapVals(205) = 50;
mapVals(203) = 52;
mapVals(201) = 54;

mapVals(151) = 104;
mapVals(153) = 102;
mapVals(155) = 100;
mapVals(157) = 98;
mapVals(200) = 55;
mapVals(202) = 53;
mapVals(204) = 51;
mapVals(206) = 49;


mapVals(32617) = 105;
mapVals(32609) = 97;
mapVals(32611) = 99;
mapVals(32613) = 101;
mapVals(32615) = 103;
mapVals(32568) = 56;
mapVals(32560) = 48;
mapVals(32562) = 50;
mapVals(32564) = 52;
mapVals(32566) = 54;
% Index out our new marker values.
newMarkerValues = mapVals(markerValues);

% Turn the values into a cell array of strings to stick back into the nex
% data structure.
nexData.markers{1}.values{1}.strings = cell(numValues, 1);
for i = 1:numValues
    nexData.markers{1}.values{1}.strings{i} = num2str(newMarkerValues(i));
end

% Save the data file.
[filePath, fileName] = fileparts(fileName);
if isempty(filePath)
    filePath = sprintf('.%s', filesep);
end
newFileName = fullfile(filePath, [fileName '-fixed.nex']);
writeNexFile(nexData, newFileName);
