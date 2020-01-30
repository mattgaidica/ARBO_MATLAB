function UpdateChannelPlot(handles, axesID, isDirty)
% UpdateChannelPlot - Updates NapMapper GUI channel plot.
%
% Syntax:
% UpdateChannelPlot(handles, axesID)
%
% Description:
% Takes information from the current state of several GUI elements to
% update the channel plot for a particular set of axes.  The idea is that
% this will be the focal point for rendering the data set on the axes given
% any combination of channel selection, epoch size, and slider position.
%
% Inputs:
% handles (struct) - The handles struct from the main GUI code.
% axesID (scalar|1x2) - The integer indices of the plots we're updating.
%     Currently, can contain 1 and/or 2.
% isDirty (logical) - If true, reset some persistent function variables
%     that keep track of currently plotted data.  This let's us force the
%     function to regenerate the current data set, including its filter
%     state.  Default: false

persistent channelData isFiltered lastChannelNumber

narginchk(2, 3);

if nargin == 2
	isDirty = false;
end

% Reset some persisent variables if asked to so do.  This let's us reset
% variables at NapMapper's startup.
if isDirty
	channelData = [];
	isFiltered = [];
	lastChannelNumber = [];
end

% Make sure the size of axesID is 1 or 2.
assert(any(length(axesID) == [1 2]), 'UpdateChannelPlot:InvalidValue', ...
	'axesID can only contain 1 or 2 values.');

% Get the nex file data and color map.
nexFile = getappdata(handles.mainWindow, 'nexFile');
napMap = getappdata(handles.mainWindow, 'napMap');
channelFilters = getappdata(handles.mainWindow, 'channelFilters');

% If no nex file is loaded, we don't update anything.
if isempty(nexFile)
	return;
end

% Get the current value of the slider.
sliderVal = get(handles.sSlider, 'Value');

% Get the current epoch time value.
s = cellstr(get(handles.pmEpoch, 'String'));
v = get(handles.pmEpoch, 'Value');
epochVal = str2double(s{v});

for i = 1:length(axesID)
	% Get the selected channel number.
	chanName = sprintf('pmAD%d', axesID(i));
	chanID = get(handles.(chanName), 'Value');
	
	% Initialize persistent variables that haven't been defined.
	if isempty(channelData) || ~isfield(channelData, chanName)
		lastChannelNumber.(chanName) = -1;
		isFiltered.(chanName) = false;
	end
	
	% Determine whether we should plot filtered data.
	cbName = sprintf('cbEnableFilter%d', axesID(i));
	showFilteredData = get(handles.(cbName), 'Value');
	
	% If we've selected new data, we need to load it into the function's
	% memory.  We also load if the last time we called this function the
	% data was filtered, but now we want to show the unfiltered data.
	if (lastChannelNumber.(chanName) ~= chanID) || ...
			(isFiltered.(chanName) && ~showFilteredData)
		fprintf('- Loading channel data: %d\n', chanID);
		
		% Load the data into persistent memory.
		channelData.(chanName) = nexFile.getADChannelData(chanID);
	end
	
	% If our channel data changed and filtering is toggled, filter the
	% data.
	if showFilteredData && (~isFiltered.(chanName) || ...
		(lastChannelNumber.(chanName) ~= chanID))
		fprintf('- Filtering channel: %d\n', chanID);
		
		% Filter the data.
		channelData.(chanName) = channelFilters{axesID(i)}.filter(channelData.(chanName));
	end
	
	% Store the selected channel number.
	lastChannelNumber.(chanName) = chanID;
	
	% Store the filtered state.
	isFiltered.(chanName) = showFilteredData;
	
	% Get the zoom slider value and convert it to an axes range.
	zoomID = sprintf('sZoom%d', axesID(i));
	zoomVal = 10 / get(handles.(zoomID), 'Value');
	
	% Get the axes handle and set it to be the target axes.
	axesName = sprintf('axAD%d', axesID(i));
	axesHandle = handles.(axesName);
	axes(axesHandle); %#ok<LAXES>
	
	% Determine the time window that we want to view in the plot.
	startTime = sliderVal * (nexFile.EndTime - 0.5);
	endTime = startTime + epochVal;
	timeRange = [startTime, endTime];

	% Map the time range into data indices.
	[timeIndices, startCapped, endCapped] = nexFile.ADTimeToIndices(timeRange);
	
	% Make a copy of the time range before we modify it below for plotting
	% purposes.  We'll use these values to set the x-axis domain after we've
	% plotted the data.  This way we can decouple the axis x-range and the
	% plotting x-axis data.
	xAxisDomain = timeRange;
	
	% If we had to cap the AD time when getting the data indices, we want
	% to reflect that in the time range we'll use when generating the
	% x-axis time points to plot the data.
	if startCapped
		timeRange(1) = nexFile.ADStartTime;
	end
	if endCapped
		timeRange(2) = nexFile.ADEndTime;
	end
	
	% Create a linear set of time values within the time range.
	x = linspace(timeRange(1), timeRange(2), diff(timeIndices) + 1);
	
	% Grab our data set we're plotting.
	y = channelData.(chanName)(timeIndices(1):timeIndices(2));
	
	% Plot the data.
	if ~isempty(napMap)
		% Get the color map values for our time range.
		mapSet = napMap.getMapSet(timeIndices(1), timeIndices(2));
		
		% Do a separate plot for each map set value.
		for mi = 1:length(mapSet)
			xi = (mapSet(mi).start : mapSet(mi).end) - timeIndices(1) + 1;
			
			plot(x(xi), y(xi), 'Color', ...
				double(mapSet(mi).mapType.RGB)/255, 'LineWidth', 2.0);
			hold on;
		end
		hold off;
	else
		plot(x, y);
	end
	
	% Set the x-axis domain to be the desired time span requested when the
	% function was called.
	xlim(xAxisDomain);
	
	% Set the x-axis tick marks to be 11 ticks linearly spaced between the
	% start and end of the domain.  We choose 11 simply because the tick values
	% will generally work out to more round numbers assuming our epoch size is
	% an integer value.
	set(gca, 'XTick', linspace(xAxisDomain(1), xAxisDomain(2), 11));
	
	% Set the y-axis range.
	ylim([-zoomVal zoomVal]);
	
	% Set the y-axis tick spacing.
	y = ylim;
	set(gca, 'YTick', linspace(y(1), y(2), 5));
	
	% Format the tick labels so they're not super long.
	yTick = get(gca, 'YTick');
	set(gca, 'YTickLabel', arrayfun(@(x) sprintf('%.1f', x), yTick, 'UniformOutput', false));
	xTick = get(gca, 'XTick');
	set(gca, 'XTickLabel', arrayfun(@(x) sprintf('%.3f', x), xTick, 'UniformOutput', false));
	
	% Set the axis labels.
	xlabel('Time (s)');
	ylabel('Voltage');
end
