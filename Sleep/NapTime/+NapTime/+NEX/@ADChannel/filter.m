function obj = filter(obj, filterObj)
% filter - Filters the raw data.
%
% Syntax:
% obj = filter(obj, filterObj)
%
% Description:
% Filters the raw data of the AD channel using the filter specified via 
% the inputted filter object.  Raw data is not affected by this function.
% Use the FilteredData class property to access the filtered data.
%
% Input:
% filterObj (dfilt) - A dfilt filter object that will be used to process
%     the raw data.

narginchk(2, 2);
nargoutchk(1, 1);

obj.Filter = filterObj;
obj.FilteredData = filterObj.filter(obj.Data);
