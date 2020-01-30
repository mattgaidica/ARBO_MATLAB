function dialogHandle = MakeMessageDialog(handles, dialogMessage)

% Get the position and size of the main window.
mainRect = get(handles.mainWindow, 'OuterPosition');

% Show the dialog box.
dialogHandle = dialog('WindowStyle', 'modal');
hPos = [mean(mainRect([1 3])) mean(mainRect([2 4]))];
set(dialogHandle, 'Position', [hPos 200 100]);
uicontrol(dialogHandle, 'Style', 'text',...
	'String', dialogMessage, ...
	'Position', [0 50 200 20]);
drawnow;
