function guiInfo = GetGUISettings(handles)
% GetGUISettings - Gets the current GUI parameters as a struct.
%
% Syntax:
% guiInfo = GetGUISettings(handles)
%
% Description:
% Returns a struct containing values for various GUI widgets and internal
% settings variables.  This function is mainly used to aggregate data to be
% saved to a file.
%
% Input:
% handles (struct) - The handles struct from the GUI.
%
% Output:
% guiInfo (struct) - Struct containing the data from the various settings
%     and GUI widgets.

narginchk(1, 1);

channelFilters = getappdata(handles.mainWindow, 'channelFilters');

% Get the epoch info.
s = cellstr(get(handles.pmEpoch, 'String'));
v = get(handles.pmEpoch, 'Value');
guiInfo.epochSize = str2double(s{v});

% Get the channel selections.
for i = 1:2
	chanPM = sprintf('pmAD%d', i);
	chanName = sprintf('channel%d', i);
	
	% Store the channel name and index into the ADChannels property of the
	% Nex file.
	s = cellstr(get(handles.(chanPM), 'String'));
	v = get(handles.(chanPM), 'Value');
	guiInfo.(chanName).name = s{v};
	guiInfo.(chanName).index = v;
end

% Get the info for the 2 filters.
for i = 1:2
	filtName = sprintf('filter%d', i);
	
	% Enabled status.
	w = sprintf('cbEnableFilter%d', i);
	guiInfo.(filtName).enabled = get(handles.(w), 'Value');
	
	% Filter settings.
	w = sprintf('eFilterLow%d', i);
	guiInfo.(filtName).lowCutoff = str2double(get(handles.(w), 'String'));
	w = sprintf('eFilterHigh%d', i);
	guiInfo.(filtName).highCutoff = str2double(get(handles.(w), 'String'));
	
	% Now for the actual filters themselves.
	if isempty(channelFilters) || isempty(channelFilters{i})
		guiInfo.(filtName).filter = [];
	else
		guiInfo.(filtName).filter = channelFilters{i};
	end
end
