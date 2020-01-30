function UpdateFilter(handles, filterID)
% UpdateFilter - Updates the filters used for the data plots.
%
% Syntax:
% UpdateFilter(handles)
%
% Description:
% Updates the filters used when plotting the data in the NapMapper GUI.
% Creating the filters on the fly is a little too slow for quick and
% frequent plotting, so we put it here to minimize doing it, as opposed to
% doing this within the plotting function(s).
%
% Input:
% handles (struct) - handles struct from the NapMapper GUI.

narginchk(1, 2);

% Default is update both filters.
if nargin == 1
	filterID = 1:2;
end

% Make sure the filter IDs are within range.
assert(all(filterID >= 1 & filterID <= 2), 'NapMapper:UpdateFilter', ...
	'Invalid filter ID.');

% Get a handle to the NEX file.
nexFile = getappdata(handles.mainWindow, 'nexFile');

% Don't do anything if there is no nex file.
if isempty(nexFile)
	return;
end

% Get the current channel filters we have store so we can update them
% below.
channelFilters = getappdata(handles.mainWindow, 'channelFilters');

% Initialize the channel fiters to empty if they've never been created.
if isempty(channelFilters)
	channelFilters = cell(1, 2);
end

% Get the filter params.
for i = filterID
	% Get AD frequency/sample rate.
	sampleRate = nexFile.ADFrequency;
	
	% Grab the numbers from the GUI.
	lowFreq = str2double(get(handles.(sprintf('eFilterLow%d', i)), 'String'));
	highFreq = str2double(get(handles.(sprintf('eFilterHigh%d', i)), 'String'));
	
	% Create the filter for the channel.
	channelFilters{i} = NapTime.CreateBandpassFilter(lowFreq, highFreq, sampleRate);
end

% Store the channel filters.
setappdata(handles.mainWindow, 'channelFilters', channelFilters);
