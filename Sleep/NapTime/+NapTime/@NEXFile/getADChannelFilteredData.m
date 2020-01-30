function data = getADChannelFilteredData(obj, channelNumber, timeRange)
% getADChannelFilteredData - Gets AD filtered data for a specific channel.
%
% Syntax:
% data = getADChannelFilteredData(obj, channelNumber)
% data = getADChannelFilteredData(obj, channelNumber, timeRange)
%
% Description:
% Using the object property ADChannelFilteredData can be slow if there are many
% channels and a lot of data due to the way property indexing works.  This
% function gets the data for a specific AD channel and is much faster.
%
% Input:
% channelNumber (scalar) - The channel number of the AD data to retrieve.
% timeRange (1x2) - Start and end time of the range of data to retrieve.
%     Defaults to the entire data set.
%
% Output:
% data (Mx1) - Vector of AD channel filtered data.

narginchk(2, 3);

% Time range defaults to the entire data set.
if nargin == 2
	timeRange = [obj.ADStartTime, obj.ADEndTime];
end

% Make sure the channel number is valid.
assert(channelNumber >= 1 && channelNumber <= obj.NumADChannels, ...
	'NEXFile:getADChannelFilteredData:InvalidChannelNumber', ...
	'Invalid channel number: %d', channelNumber);

% Convert the time range to data indices.
[indices, startCapped, endCapped] = obj.ADTimeToIndices(timeRange);

% % Throw an error if we asked for a time value outside the actual time range
% % of the data.
assert(startCapped == false && endCapped == false, ...
	'NEXFile:getADChannelFilteredData:InvalidTimeRange', ...
	'Time range specified false outside bounds of AD data.');

% Get the channel data.
data = obj.ADChannelFilteredData(indices(1):indices(2), channelNumber);
