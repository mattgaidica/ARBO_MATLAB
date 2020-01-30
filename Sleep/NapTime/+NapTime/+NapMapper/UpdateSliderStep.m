function UpdateSliderStep(handles)
% UpdateSliderStep - Updates the NapMapper slider step size.
%
% Syntax:
% UpdateSliderStep(handles)
%
% Description:
% Takes values from the GUI, namely the epoch size, and changes the
% slider's step size so that clicking on the arrows increments/decrements
% the time window of the plot integer multiples of the epoch size.
%
% Input:
% handles (struct) - The handles struct from the NapMapper GUI.

narginchk(1, 1);

% Get the nex file data.
nexFile = getappdata(handles.mainWindow, 'nexFile');

% Don't update anything if there is no nex file loaded.
if isempty(nexFile)
	return;
end

% Get the current epoch time value.
s = cellstr(get(handles.pmEpoch, 'String'));
v = get(handles.pmEpoch, 'Value');
epochVal = str2double(s{v});

% Set the slider step based on the current epoch.  Ideally, we want each
% arrow click on the slider to increment exactly one epoch size, and each
% bar click to increment 5 times the epoch size.  We max out the slider
% value to map to the end of the recording time minus half a second.
m = epochVal / (nexFile.EndTime - 0.5);
sliderStep = [m 5*m];
set(handles.sSlider, 'SliderStep', sliderStep);
