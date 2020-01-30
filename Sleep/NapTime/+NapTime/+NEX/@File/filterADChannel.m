function obj = filterADChannel(obj, channelNumber, filterObj)
% filterADChannel - Filters an AD channel.
%
% Syntax:
% obj = filterADChannel(obj, filterObj)
%
% Description:
% Filters an AD channel using the specified dfilt filter object.  Can be
% run on one or many AD channels.
%
% Input:
% channelNumber (1xN) - The channel number(s) to filter.
% filterObj (dfilt) - The dfilt object that describes the filter.

narginchk(3, 3);
nargoutchk(1, 1);

% Make sure that our channel number(s) is in range.
assert(all(channelNumber >= 1 & channelNumber <= obj.NumADChannels), ...
	'Nex:File:filterADChannel', 'Invalid channel number.');

% Loop over all the channels specified.
for i = channelNumber
	obj.ADChannels(i) = obj.ADChannels(i).filter(filterObj);
end
