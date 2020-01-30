function obj = setMap(obj, startIndex, endIndex, mapType)

narginchk(4, 4);

% Make sure the start and end indices are within range.
assert(startIndex >= 1 && endIndex <= obj.Length, 'NapMap:setMap:InvalidIndices', ...
	'Invalid indices, must be in the range [1,%d].', obj.Length);

% Make sure the map type is valid.
assert(isa(mapType, 'NapTime.MapTypes'), 'NapMap:setMap:InvalidMapType', ...
	'Invalid map type.');

% Set the map values.
obj.Map(startIndex:endIndex) = mapType.NumericID;
