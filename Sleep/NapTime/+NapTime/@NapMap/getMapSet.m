function mapSet = getMapSet(obj, startIndex, endIndex)

narginchk(3, 3);

% Make sure the start and end indices are within range.
assert(startIndex >= 1 && endIndex <= obj.Length, 'NapMap:getMapSet:InvalidIndices', ...
	'Invalid indices, must be in the range [1,%d].', obj.Length);

mapSubset = obj.Map(startIndex:endIndex);

% Find the changes between map subsets, i.e. where the map values change.
% This will give us the different sections of color within the subset.
c = find(diff(double(mapSubset)) ~= 0) + 1;

% The one thing the sectioning above doesn't achieve is to find boundary
% markers for the beginning and end of the subset + 1.  We manually add them
% here.  In case there was a change at the end index prior to manually
% adding it, we take the unique set of boundary markers to eliminate
% duplicates.
c = unique([1, c, length(mapSubset)+1]);

% Get a list of our map types.
e = enumeration('NapTime.MapTypes');

% Iterate over all boundary markers except the last one.  A section is
% defined as a given marker up to the next marker minus 1.
mapSet = repmat(struct('start', -1, 'end', -1, 'mapType', -1), 1, length(c)-1);
for i = 1:(length(c)-1)
	mapSet(i).start = c(i) + startIndex - 1;
	mapSet(i).end = c(i+1) + startIndex - 2;
	mapSet(i).mapType = e([e.NumericID] == mapSubset(c(i)));
end
