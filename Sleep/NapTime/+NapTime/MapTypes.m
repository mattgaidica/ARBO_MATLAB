classdef MapTypes
	properties
		RGB
		NumericID
	end
	
	enumeration
		UnMapped ([0 0 0], 1)
		ActiveWake ([65 199 74], 2)
		QuietWake ([213 144 101], 3)
		QuietSleep ([101 158 213], 4)
		REM ([238 105 158], 5)
		SlowWave ([101 158 213], 6)
		Noise ([200 200 200], 7)
		Wake ([65 199 74], 8)
	end
	
	methods
		function obj = MapTypes(RGB, numericID)
			obj.RGB = uint8(RGB);
			obj.NumericID = uint8(numericID);
		end
	end
end
