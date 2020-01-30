function plot(obj, timeRange, axesHandle, yRange, napMap, useFilteredData)

if ~exist('timeRange', 'var') || isempty(timeRange)
	% Set the time range to be the entire data set.
	timeRange = [obj.StartTime obj.EndTime];
end

% Set the target axes if specified.
if exist('axesHandle', 'var') && ~isempty(axesHandle)
	axes(axesHandle);
end

if ~exist('useFilteredData', 'var')
	useFilteredData = false;
end

% If no y range was specified, we'll let the plot command automatically
% take care of it.
if ~exist('yRange', 'var') || isempty(yRange)
	yRange = 'auto';
end

if ~exist('napMap', 'var')
	napMap = [];
end

% Map the time range into data indices.  We do this by converting seconds
% into milliseconds, rounding to an integer and adding 1 since MATLAB uses
% 1 based indexing.
timeIndices = round((timeRange - obj.StartTime) * obj.Frequency) + 1;

% Make a copy of the time range before we modify it below for plotting
% purposes.  We'll use these value to set the x-axis domain after we've
% plotted the data.
xAxisDomain = timeRange;

% Create the set of indices we'll use to plot the data subset we want.  If
% our times fall outside the range of data indices, we'll cap them to the
% data index end points, i.e. 1 and the length of the data.
if timeIndices(1) < 1
	timeIndices(1) = 1;
	timeRange(1) = obj.StartTime;
end
if timeIndices(2) > obj.NumDataPoints
	timeIndices(2) = obj.NumDataPoints;
	timeRange(2) = (timeIndices(2) - 1) / obj.Frequency + obj.StartTime;
end

% Create a linear set of time values within the time range.
x = linspace(timeRange(1), timeRange(2), diff(timeIndices) + 1);

% Plot the data.
if ~isempty(napMap)
	% Get the color map values for our time range.
	mapSet = napMap.getMapSet(timeIndices(1), timeIndices(2));
	
	% Do a separate plot for each map set value.
	for i = 1:length(mapSet)
		xi = (mapSet(i).start : mapSet(i).end) - timeIndices(1) + 1;

		if useFilteredData
			y = obj.FilteredData(mapSet(i).start : mapSet(i).end);
		else
			y = obj.Data(mapSet(i).start : mapSet(i).end);
		end
	
		plot(x(xi), y, 'Color', double(mapSet(i).mapType.RGB)/255, 'LineWidth', 2.0);
		hold on;
	end
	hold off;
else
	if  useFilteredData
		y = obj.FilteredData(timeIndices(1):timeIndices(2));
	else
		y = obj.Data(timeIndices(1):timeIndices(2));
	end
	
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
ylim(yRange);

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
