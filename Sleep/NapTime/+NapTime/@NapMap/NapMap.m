classdef NapMap
	properties (SetAccess = private)
		Length;
		Map;
	end
	
	methods
		function obj = NapMap(colorMapLength)
			obj.Length = colorMapLength;
			
			% Use the numeric ID of the map type as a unique identifier
			% because it's significantly faster to search than when using
			% the enumeration.
			obj.Map = repmat(NapTime.MapTypes.UnMapped.NumericID, 1, obj.Length);
		end
		
		mapSet = getMapSet(obj, startIndex, endIndex)
		obj = setMap(obj, startIndex, endIndex, mapType)
	end
end
