function filterADChannelData(obj, channelNumber, filterObj)

narginchk(2, 2);

% Store a reference to the filter we used on the data.
obj.Filter = filterObj;

if ~isempty(filterObj)
	% Filter the data.
	obj.ADChannelFilteredData = filterObj.filter(obj.ADChannelData);
end
