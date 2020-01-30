function data = getADChannelData(obj, channelNumber, timeRange)
% getADChannelData - Gets AD data for a specific channel.
%
% Syntax:
% data = getADChannelData(obj, channelNumber)
% data = getADChannelData(obj, channelNumber, timeRange)
%
% Description:
% Using the object property ADChannelData can be slow if there are many
% channels and a lot of data due to the way property indexing works.  This
% function gets the data for a specific AD channel and is much faster.
%
% Input:
% channelNumber (scalar) - The channel number of the AD data to retrieve.
% timeRange (1x2) - Start and end time of the range of data to retrieve.
%     Defaults to the entire data set.
%
% Output:
% data (Mx1) - Vector of AD channel data.

narginchk(2, 3);

% Time range defaults to the entire data set.
if nargin == 2
	timeRange = [obj.ADStartTime, obj.ADEndTime];
end

% Make sure the channel number is valid.
assert(channelNumber >= 1 && channelNumber <= obj.NumADChannels, ...
	'NEXFile:getADChannelData:InvalidChannelNumber', ...
	'Invalid channel number: %d', channelNumber);

% Convert the time range to data indices.
[indices, startCapped, endCapped] = obj.ADTimeToIndices(timeRange);

% % Throw an error if we asked for a time value outside the actual time range
% % of the data.
assert(startCapped == false && endCapped == false, ...
	'NEXFile:getADChannelData:InvalidTimeRange', ...
	'Time range specified false outside bounds of AD data.');

% Get the channel data.
data = obj.NEXData.contvars{channelNumber}.data(indices(1):indices(2));
