classdef File
	properties (SetAccess = protected)
		% These variables are the file meta data.
		Version
		Frequency
		Comment
		StartTime
		EndTime
		
		NumADChannels
		ADChannels
	end
	
	methods
		function obj = File(fileName)
			narginchk(1, 1);
			
			% Make sure the file exists.
			assert(logical(exist(fileName, 'file')), 'NEX.File:FileNotFound', ...
				'Cannot find file: %s', fileName);
			
			% Read the nex file.
			nexData = NapTime.NEX.File.read(fileName);
			
			% Store some metadata.
			obj.Version = nexData.version;
			obj.Comment = nexData.comment;
			obj.Frequency = nexData.freq;
			obj.StartTime = nexData.tbeg;
			obj.EndTime = nexData.tend;
						
			% These files can be big so we trash the stuff we don't care
			% about before we start doing some memory operations below.
			nexData = nexData.contvars;
			
			% Stick the data into AD channel objects.  We use a
			% temporary variable to create the channel object array due to
			% the way MATLAB will initialize the ADChannels property to a
			% double value, which causes a syntax error when we try to
			% reference it like it's an object.
			for i = 1:length(nexData)
				% 				% The timestamp value can in theory by an array, but the
				% 				% way the lab for this project generates it, it always
				% 				% comes out to a scalar.  For a sanity check, we'll enforce
				% 				% this to be the case.
				% 				assert(isscalar(nexData{i}.timestamps), 'NEX:File:InvalidValue', ...
				% 					'Timestamp value in unexpected format.');
				
				ad(i) = NapTime.NEX.ADChannel(nexData{i}.data, nexData{i}.name, ...
					nexData{i}.ADFrequency, nexData{i}.fragmentStarts, ...
					nexData{i}.timestamps); %#ok<AGROW>
				% 				ad(i) = NapTime.NEX.ADChannel(nexData{i}.data, nexData{i}.name, ...
				% 					nexData{i}.ADFrequency, 0); %#ok<AGROW>
			end
			
			obj.ADChannels = ad;
		end
		
		obj = filterADChannel(obj, channelID, filterObj)
	end
	
	% Get/Set functions
	methods
		function val = get.NumADChannels(obj)
			val = length(obj.ADChannels);
		end
	end
	
	methods (Static = true)
		nexData = read(fileName)
	end
end
