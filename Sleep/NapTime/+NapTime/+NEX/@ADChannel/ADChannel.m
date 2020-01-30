classdef ADChannel
	% ADChannel - Class to represent an AD channel from a NEX file.
	
	properties (SetAccess = private)
		Data
		FilteredData
		Filter
		ChannelName
		Frequency
		NumDataPoints
		StartTime
		EndTime
		TimeStamps
		FragmentStarts
	end
	
	methods
		function obj = ADChannel(data, channelName, frequency, fragmentStarts, timeStamps)
			obj.Data = data;
			obj.ChannelName = channelName;
			obj.Frequency = frequency;
			obj.NumDataPoints = length(data);
			obj.TimeStamps = timeStamps;
			obj.FragmentStarts = fragmentStarts;
			obj.StartTime = 0;
			obj.EndTime = obj.StartTime + (obj.NumDataPoints - 1) / frequency;
		end
		
		plot(obj, timeRange, axesHandle, yRange, napMap, useFilteredData)
		[indices, startCapped, endCapped] = timeToIndices(obj, timeRange)
		obj = filter(obj, filterObj)
	end
end
