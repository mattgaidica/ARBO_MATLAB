function intervals = NapMapToIntervals(napMapFile, outputFileName)
% NAPMAPTOINTERVALS  Pulls out the sleep state intervals from a NapMap file.
%
% Syntax:
% intervals = NAPMAPTOINTERVALS(napMapFile)
% intervals = NAPMAPTOINTERVALS(napMapFile, outputFileName)
%
% Description:
% Takes a NapMap .mat file or the data from a NapMap file and generates a
% list of all sleep state intervals defined by the NapMap.MapTypes
% enumeration.  The intervals are outputted in a struct with a field for
% each map type.  Each field contains a Nx2 matrix where each row is the
% start and stop time for the map type in seconds.  If an output file is
% specified, the data will be saved to an Excel spreadsheet where each map
% type will be in its own sheet.
%
% Input:
% napMapFile(1xN char|struct) - A NapMap filename or data extracted from a
%     NapMap file.
% outputFileName (1xN char) - The name of the output file.  If empty, i.e.
%     '', the output filename will be the same as the NapMap filename in
%     the case that that a filename was used as input for "napMapFile" and
%     will be saved to the same location as the NapMap file..  In
%     the case where "napMapFile" is a struct, the filename will simply be
%     'NapMapIntervals.xls', which will be saved to the current working
%     directory.
%
% Output:
% intervals (struct) - The interval data for each map type.

narginchk(1, 2);

if nargin == 2
	% Make sure the output filename is a string.
	assert(ischar(outputFileName), 'NapMapToIntervals:InvalidFileName', ...
		'Output filename must be a string.');
	
	% If the filename is empty, i.e. '', use the same name as the .mat
	% file or use 'NapMapIntervals.xls' if "napMapFile" isn't a filename.
	if isempty(outputFileName)
		if ischar(napMapFile)
			outputFileName = napMapFile;
		else
			outputFileName = 'NapMapIntervals';
		end
	end
	
	% Rebuild the output filename to get rid of any file suffixes and make
	% sure it's .xls.
	[p, f] = fileparts(outputFileName);
	if isempty(p)
		p = '.';
	end
	outputFileName = fullfile(p, [f '.xls']);
end

% Load the napmap file if passed as a filename.
if ischar(napMapFile)
	napMapFile = load(napMapFile);
end

% Get all the mapped segments.
mapSet = napMapFile.napMap.getMapSet(1, napMapFile.napMap.Length);

% The time offset should be the same for both stored channels.  Pull out
% the offset from the first channel.
timeOffset = napMapFile.channelInfo(1).timestamps(1);

% The same goes for the channel frequency.
channelFreq = napMapFile.channelInfo(1).ADFrequency;

% Get a list of all the map types.
mapTypes = enumeration('NapTime.MapTypes');
numMapTypes = length(mapTypes);

% Aggregate the interval times for each map type.
for i = 1:numMapTypes
	% Find all matching map types.
	l = [mapSet.mapType] == mapTypes(i);
	
	% Pull out the subset of this particular map type.
	S = mapSet(l);
	numSegments = length(S);
	
	% Create a subfield for 'intervals' for this map type
	% and pre-allocate memory to store the interval info.
	intervals.(mapTypes(i).char) = zeros(numSegments, 2);
	
	% Loop over all the segments and record the intervals.
	for j = 1:numSegments
		% Convert the napmap index values into time values
		% (in seconds) and add the time offset.
		intervals.(mapTypes(i).char)(j,:) = ...
			([S(j).start, S(j).end] - 1) / channelFreq + timeOffset;
	end
	
	% Write the interval times for this map type to disk if flagged.
	if nargin == 2
		if ~isempty(intervals.(mapTypes(i).char))
			xlswrite(outputFileName, intervals.(mapTypes(i).char), (mapTypes(i).char));
		end
	end
end
