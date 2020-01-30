classdef NEXFile < handle
	properties (SetAccess = private)
		NEXData
		FileName
	end
	
	properties (Dependent = true)
		Version
		Frequency
		Comment
		StartTime
		EndTime
		
		ADChannels
		ADChannelData
		ADChannelNames
		NumADDataPoints
		NumADChannels
		ADStartTime
		ADEndTime
		ADFrequency
	end
	
	methods
		function obj = NEXFile(fileName)
			narginchk(1, 1);
			
			% Make sure the file exists.
			assert(logical(exist(fileName, 'file')), 'NEXFile:FileNotFound', ...
				'Cannot find NEX file: %s', fileName);
			
			% Store the filename.
			obj.FileName = fileName;
			
			obj.NEXData = NapTime.NEXFile.read(fileName);
			
			% Make sure all the AD channels have the same number of data
			% points.  While not required for NEX files, the experiments
			% this class is used for needs that to be true.
			for i = 1:obj.NumADChannels
				assert(length(obj.NEXData.contvars{i}.data) == obj.NumADDataPoints, ...
					'NEXFile:InvalidNumADDataPoints', ...
					'Number of data points in AD channels must all be the same.');
				
				% For a sanity check, make sure that all the AD channel start
				% times and recording frequencies are the same.
				assert(obj.NEXData.contvars{1}.timestamps(1) == obj.NEXData.contvars{i}.timestamps(1), ...
					'NEXFile:InvalidTimestamp', 'AD channel start times do not match.');
				
				assert(obj.NEXData.contvars{1}.ADFrequency == obj.NEXData.contvars{i}.ADFrequency, ...
					'NEXFile:InvalidFrequency', 'AD channel frequencies do not match.');
			end
		end
		
		[indices, startCapped, endCapped] = ADTimeToIndices(obj, timeRange)
		data = getADChannelData(obj, channelNumber, timeRange)
	end
	
	methods
		function val = get.ADEndTime(obj)
			if obj.NumADChannels > 0
				val = (obj.NumADDataPoints - 1) / obj.ADFrequency + obj.ADStartTime;
			else
				val = 0;
			end
		end
		
		function val = get.ADFrequency(obj)
			if obj.NumADChannels > 0
				val = obj.NEXData.contvars{1}.ADFrequency;
			else
				val = 0;
			end
		end
		
		function val = get.ADStartTime(obj)
			if obj.NumADChannels > 0
				val = obj.NEXData.contvars{1}.timestamps(1);
			else
				val = 0;
			end
		end
		
		function val = get.ADChannelNames(obj)
			val = cell(1, obj.NumADChannels);
			
			for i = 1:obj.NumADChannels
				val{i} = obj.NEXData.contvars{i}.name;
			end
		end

		function val = get.ADChannelData(obj)
			val = zeros(obj.NumADDataPoints, obj.NumADChannels);
			
			for iChannel = 1:obj.NumADChannels
				val(:,iChannel) = obj.NEXData.contvars{iChannel}.data;
			end
		end
		
		function val = get.NumADDataPoints(obj)
			if isfield(obj.NEXData, 'contvars')
				val = length(obj.NEXData.contvars{1}.data);
			else
				val = 0;
			end
		end
		
		function val = get.Version(obj)
			val = obj.NEXData.version;
		end
		
		function val = get.Frequency(obj)
			val = obj.NEXData.freq;
		end
		
		function val = get.Comment(obj)
			val = obj.NEXData.comment;
		end
		
		function val = get.StartTime(obj)
			val = obj.NEXData.tbeg;
		end
		
		function val = get.EndTime(obj)
			val = obj.NEXData.tend;
		end
		
		function data = get.ADChannels(obj)
			data = obj.NEXData.contvars;
		end
		
		function val = get.NumADChannels(obj)
			if isfield(obj.NEXData, 'contvars')
				val = length(obj.NEXData.contvars);
			else
				val = 0;
			end
		end
	end
	
	methods (Static = true)
		nexData = read(fileName)
	end
end
