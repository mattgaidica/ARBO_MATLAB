function [indices, startCapped, endCapped] = timeToIndices(obj, timeRange)
% timeToIndices - Converts a time range into data indices.
%
% Syntax:
% [indices, startCapped, endCapped] = timeToIndices(obj, timeRange)
%
% Description:
% The data for the ADChannel is stored in a vector.  This function is a
% convenience function that allows you to extract the start and end indices
% of the data vector that map to a specific time range.
%
% Input:
% obj (ADChannel) - The ADChannel object.
% timeRange (1x2) - The start and end times in seconds.
%
% Output:
% indices (1x2) - The indices corresponding to the time range.
% startCapped (logical) - True if the start time was less than the first
%     data point's time.
% endCapped (logical) - True if the end time exceeded the time of the last
%     data point.

narginchk(2, 2);

% Cap the ends if we exceed the actual time range of the data.
if timeRange(1) < obj.StartTime
	timeRange(1) = obj.StartTime;
	startCapped = true;
else
	startCapped = false;
end
if timeRange(2) > obj.EndTime
	timeRange(2) = obj.EndTime;
	endCapped = true;
else
	endCapped = false;
end

% Map the time range into data indices.  We do this by converting seconds
% into milliseconds, rounding to an integer and adding 1 since MATLAB uses
% 1 based indexing.
indices = round((timeRange - obj.StartTime) * obj.Frequency) + 1;
