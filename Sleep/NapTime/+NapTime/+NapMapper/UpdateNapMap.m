function UpdateNapMap(handles, mapType)
% UpdateNapMap - Updates the color map for a section of NapMapper data.
%
% Syntax:
% UpdateNapMap(handles, mapType)
%
% Description:
% Data in NapMapper can be tagged with several different labels.  When data
% is tagged with a particular label, the color of the plot of that set of
% data changes.  This function provides a common location for all the
% labels to update color map used to track the data color.
%
% Input:
% handles (struct) - handles struct from the NapMapper GUI.
% mapType (NapTime.MapType) - MapType to tag the plotted data.

% Get the nex file and colormap.
napMap = getappdata(handles.mainWindow, 'napMap');
nexFile = getappdata(handles.mainWindow, 'nexFile');

% Don't do anything if a nex file hasn't been loaded.
if isempty(nexFile)
	return;
end

% Get the time range of one of the plots.  All plots should be the same.
timeRange = get(handles.axAD1, 'XLim');

% The plot axes can possibly have a max domain value larger than the end
% time of the AD data.  If this is the case, we set our end of our desired
% time range to be the end time of the last data point.
if timeRange(2) > nexFile.ADEndTime
	timeRange(2) = nexFile.ADEndTime;
end

% Convert the time range of interest into data indices.
timeIndices = nexFile.ADTimeToIndices(timeRange);

% Update the color map with the new RGB value associated with the time
% range.
napMap = napMap.setMap(timeIndices(1), timeIndices(2), mapType);

% Store the colormap so that the UpdateChannelPlot function will see the
% updated colormap.
setappdata(handles.mainWindow, 'napMap', napMap);

NapTime.NapMapper.UpdateChannelPlot(handles, 1:2);
