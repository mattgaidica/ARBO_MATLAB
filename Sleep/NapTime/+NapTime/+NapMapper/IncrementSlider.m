function IncrementSlider(handles, delay)
% IncrementSlider - Increments the slider and updates the displayed data.
%
% Syntax:
% IncrementSlider(handles, delay)
%
% Description:
% When a user presses a button to tag the currently displayed data, we want
% to increment to the next frame of data so that user doesn't have to click
% the slider arrows.  This function is a convenience function that
% implements that functionality for the various tag buttons on the main
% GUI.
%
% Input:
% handles (struct) - handles struct from the main GUI.
% delay (scalar) - Time in seconds to delay prior to updating the plots
%     with new data.  This exists to the user can visually see the tag made
%     prior to updating the plot.

narginchk(2, 2);

% Wait a short time so the user can visually review what they marked prior
% to moving to the next frame of data.
pause(delay);

% Update the slider to one step further.
sliderStep = get(handles.sSlider, 'SliderStep');
sliderValue = get(handles.sSlider, 'Value');
sliderValue = sliderValue + sliderStep(1);

% Cap the slider value if we've gone too far.
if sliderValue > 1
	sliderValue = 1;
end

% Update the slider object.
set(handles.sSlider, 'Value', sliderValue);

% Call the slider callback so that the plot gets updated with new data.
%sSlider_Callback(handles.sSlider, [], handles);
NapMapper('sSlider_Callback', handles.sSlider, [], handles);
