function varargout = NapMapper(varargin)
% NAPMAPPER MATLAB code for NapMapper.fig
%      NAPMAPPER, by itself, creates a new NAPMAPPER or raises the existing
%      singleton*.
%
%      H = NAPMAPPER returns the handle to a new NAPMAPPER or the handle to
%      the existing singleton*.
%
%      NAPMAPPER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in NAPMAPPER.M with the given input arguments.
%
%      NAPMAPPER('Property','Value',...) creates a new NAPMAPPER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before NapMapper_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to NapMapper_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help NapMapper

% Last Modified by GUIDE v2.5 24-Feb-2013 21:00:49

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @NapMapper_OpeningFcn, ...
                   'gui_OutputFcn',  @NapMapper_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before NapMapper is made visible.
function NapMapper_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to NapMapper (see VARARGIN)

% Choose default command line output for NapMapper
handles.output = hObject;

% Set the axes labels.  Do this now so that upon load the labels are there.
% They actually get redrawn later via the channel plot.
xlabel(handles.axAD1, 'Time (s)');
xlabel(handles.axAD2, 'Time (s)');
ylabel(handles.axAD1, 'Voltage');
ylabel(handles.axAD2, 'Voltage');

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes NapMapper wait for user response (see UIRESUME)
% uiwait(handles.mainWindow);


% --- Outputs from this function are returned to the command line.
function varargout = NapMapper_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


function eFileName_Callback(hObject, eventdata, handles)
% hObject    handle to eFileName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of eFileName as text
%        str2double(get(hObject,'String')) returns contents of eFileName as a double


% --- Executes during object creation, after setting all properties.
function eFileName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eFileName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pbLoadFile.
function pbLoadFile_Callback(hObject, eventdata, handles)
% Select a PLX file to open.
[fileName, pathName] = uigetfile('*.nex', 'Select a NEX file');

% If the user didn't hit cancel attempt to load` the data.
if ~isequal(fileName, 0)
	% Display the filename.
	set(handles.eFileName, 'String', fullfile(pathName, fileName));
	drawnow;
	
	% Show a dialog box so the user knows we're loading a file and not just
	% hanging.
	h = NapTime.NapMapper.MakeMessageDialog(handles, ...
		'Please wait for file to load...');
	
	% Load the data file.
	nexFile = NapTime.NEXFile(fullfile(pathName, fileName));
	
	% Close the dialog box.
	close(h);
	
	% Construct the name of the napmap file that would be associated with
	% this nex file.
	[~, simpleFileName] = fileparts(fileName);
	napmapFileName = fullfile(pathName, [simpleFileName '-napmap.mat']);
	
	% Set the file info in the GUI.
	set(handles.eNexStartTime, 'String', nexFile.StartTime);
	set(handles.eNexEndTime, 'String', nexFile.EndTime);
	set(handles.eNexNumADChannels, 'String', nexFile.NumADChannels);
	
	% Create a list of channels.
	set(handles.pmAD1, 'String', nexFile.ADChannelNames);
	set(handles.pmAD2, 'String', nexFile.ADChannelNames);
	
	% Set the selected channels for each popup menu.
	set(handles.pmAD1, 'Value', 1);
	set(handles.pmAD2, 'Value', 2);
	
	% Store the NEX file data in our app so we can retrieve it from other
	% callback functions.
	setappdata(handles.mainWindow, 'nexFile', nexFile);
	
	% Load the previous napmap file if it exists.  In theory, the variable
	% in the napmat file will be named 'napMap'.
	if exist(napmapFileName, 'file')
		load(napmapFileName);
		
		% Update the filter GUI widgets.
		for i = 1:2
			filterName = sprintf('filter%d', i);
			cbName = sprintf('cbEnableFilter%d', i);
			
			% Set the enabled status.
			set(handles.(cbName), 'Value', guiInfo.(filterName).enabled);
			
			% Set the filter cutoffs.
			lowName = sprintf('eFilterLow%d', i);
			highName = sprintf('eFilterHigh%d', i);
			set(handles.(lowName), 'String', guiInfo.(filterName).lowCutoff);
			set(handles.(highName), 'String', guiInfo.(filterName).highCutoff);
		end
		
		% Set the last selected channels.
	else
		% Create a new NapMap for the data file and store it.  The NapMap keeps
		% track of sleep state tags associated with the data.
		napMap = NapTime.NapMap(nexFile.NumADDataPoints);
	end
	setappdata(handles.mainWindow, 'napMap', napMap);
	
	% Reset the slider value so that we start at the beginning of the file.
	set(handles.sSlider, 'Value', 0);
	
	% Reset the zoom sliders.
	set(handles.sZoom1, 'Value', 10);
	set(handles.sZoom2, 'Value', 10);
	
	% Update the slider step for the currently selected epoch value.
	NapTime.NapMapper.UpdateSliderStep(handles);
	
	% Update the filters.
	NapTime.NapMapper.UpdateFilter(handles);
	
	% Update the plots.
	NapTime.NapMapper.UpdateChannelPlot(handles, 1:2, true);

	% Enable the save button.
	set(handles.pbSaveNapMap, 'Enable', 'on');
end


% --- Executes on selection change in pmAD1.
function pmAD1_Callback(hObject, eventdata, handles)
%NapTime.NapMapper.UpdateFilter(handles, 1);
NapTime.NapMapper.UpdateChannelPlot(handles, 1);


% --- Executes during object creation, after setting all properties.
function pmAD1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pmAD1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in pmAD2.
function pmAD2_Callback(hObject, eventdata, handles)
%NapTime.NapMapper.UpdateFilter(handles, 2);
NapTime.NapMapper.UpdateChannelPlot(handles, 2);


% --- Executes during object creation, after setting all properties.
function pmAD2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pmAD2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function sSlider_Callback(hObject, eventdata, handles)
NapTime.NapMapper.UpdateChannelPlot(handles, 1:2);


% --- Executes during object creation, after setting all properties.
function sSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on selection change in pmEpoch.
function pmEpoch_Callback(hObject, eventdata, handles)
NapTime.NapMapper.UpdateSliderStep(handles);
NapTime.NapMapper.UpdateChannelPlot(handles, 1:2);


% --- Executes during object creation, after setting all properties.
function pmEpoch_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pmEpoch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pbWake.
function pbWake_Callback(hObject, eventdata, handles)
NapTime.NapMapper.UpdateNapMap(handles, NapTime.MapTypes.Wake);
NapTime.NapMapper.IncrementSlider(handles, .25);


% --- Executes on button press in pbQuietWake.
function pbQuietWake_Callback(hObject, eventdata, handles)
NapTime.NapMapper.UpdateNapMap(handles, NapTime.MapTypes.QuietWake);
NapTime.NapMapper.IncrementSlider(handles, .25);


% --- Executes on button press in pbSlowWave.
function pbSlowWave_Callback(hObject, eventdata, handles)
NapTime.NapMapper.UpdateNapMap(handles, NapTime.MapTypes.SlowWave);
NapTime.NapMapper.IncrementSlider(handles, .25);


% --- Executes on button press in pbQuietSleep.
function pbQuietSleep_Callback(hObject, eventdata, handles)
NapTime.NapMapper.UpdateNapMap(handles, NapTime.MapTypes.QuietSleep);
NapTime.NapMapper.IncrementSlider(handles, .25);


% --- Executes on button press in pbREM.
function pbREM_Callback(hObject, eventdata, handles)
NapTime.NapMapper.UpdateNapMap(handles, NapTime.MapTypes.REM);
NapTime.NapMapper.IncrementSlider(handles, .25);


% --- Executes on button press in pbNoise.
function pbNoise_Callback(hObject, eventdata, handles)
NapTime.NapMapper.UpdateNapMap(handles, NapTime.MapTypes.Noise);
NapTime.NapMapper.IncrementSlider(handles, .25);


% --- Executes during object creation, after setting all properties.
function pbWake_CreateFcn(hObject, eventdata, handles)
set(hObject, 'BackgroundColor', double(NapTime.MapTypes.ActiveWake.RGB)/255);


% --- Executes during object creation, after setting all properties.
function pbQuietWake_CreateFcn(hObject, eventdata, handles)
set(hObject, 'BackgroundColor', double(NapTime.MapTypes.QuietWake.RGB)/255);


% --- Executes during object creation, after setting all properties.
function pbQuietSleep_CreateFcn(hObject, eventdata, handles)
set(hObject, 'BackgroundColor', double(NapTime.MapTypes.QuietSleep.RGB)/255);


% --- Executes during object creation, after setting all properties.
function pbSlowWave_CreateFcn(hObject, eventdata, handles)
set(hObject, 'BackgroundColor', double(NapTime.MapTypes.SlowWave.RGB)/255);


% --- Executes during object creation, after setting all properties.
function pbREM_CreateFcn(hObject, eventdata, handles)
set(hObject, 'BackgroundColor', double(NapTime.MapTypes.REM.RGB)/255);


% --- Executes during object creation, after setting all properties.
function pbNoise_CreateFcn(hObject, eventdata, handles)
set(hObject, 'BackgroundColor', double(NapTime.MapTypes.Noise.RGB)/255);



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double


% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pbSaveNapMap.
function pbSaveNapMap_Callback(hObject, eventdata, handles)
% Get the nap map.
napMap = getappdata(handles.mainWindow, 'napMap'); %#ok<NASGU>

% Get the GUI and program settings.
guiInfo = NapTime.NapMapper.GetGUISettings(handles);

% Get the NEX file name from the filename text box.
fileName = get(handles.eFileName, 'String');

% Get the simple file name and its path.
[filePath, simpleFileName] = fileparts(fileName);
if isempty(filePath)
	filePath = sprintf('.%s', filesep);
end

% We'll store the ADChannel data we analyzed so we can easily process the
% data later without having to load the entire NEX file.
nexFile = getappdata(handles.mainWindow, 'nexFile');
for i = 1:2
	channelIndex = guiInfo.(sprintf('channel%d', i)).index;
	channelInfo(i) = nexFile.ADChannels{channelIndex}; %#ok<AGROW,NASGU>
end

% Save the nap map to a mat file with the same name as the file name except
% it will have '-napmap' appended to it.
saveFileName = fullfile(filePath, [simpleFileName '-napmap.mat']);
save(saveFileName, 'napMap', 'guiInfo', 'channelInfo');



function eNexStartTime_Callback(hObject, eventdata, handles)
% hObject    handle to eNexStartTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of eNexStartTime as text
%        str2double(get(hObject,'String')) returns contents of eNexStartTime as a double


% --- Executes during object creation, after setting all properties.
function eNexStartTime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eNexStartTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function eNexEndTime_Callback(hObject, eventdata, handles)
% hObject    handle to eNexEndTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of eNexEndTime as text
%        str2double(get(hObject,'String')) returns contents of eNexEndTime as a double


% --- Executes during object creation, after setting all properties.
function eNexEndTime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eNexEndTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function eNexNumADChannels_Callback(hObject, eventdata, handles)
% hObject    handle to eNexNumADChannels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of eNexNumADChannels as text
%        str2double(get(hObject,'String')) returns contents of eNexNumADChannels as a double


% --- Executes during object creation, after setting all properties.
function eNexNumADChannels_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eNexNumADChannels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function sZoom1_Callback(hObject, eventdata, handles)
NapTime.NapMapper.UpdateChannelPlot(handles, 1);


% --- Executes during object creation, after setting all properties.
function sZoom1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sZoom1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function sZoom2_Callback(hObject, eventdata, handles)
NapTime.NapMapper.UpdateChannelPlot(handles, 2);


% --- Executes during object creation, after setting all properties.
function sZoom2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sZoom2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on key press with focus on pbWake and none of its controls.
function pbWake_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to pbWake (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)



function eFilterLow1_Callback(hObject, eventdata, handles)
NapTime.NapMapper.UpdateFilter(handles, 1);
NapTime.NapMapper.UpdateChannelPlot(handles, 1, true);


% --- Executes during object creation, after setting all properties.
function eFilterLow1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eFilterLow1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function eFilterHigh1_Callback(hObject, eventdata, handles)
NapTime.NapMapper.UpdateFilter(handles, 1);
NapTime.NapMapper.UpdateChannelPlot(handles, 1, true);


% --- Executes during object creation, after setting all properties.
function eFilterHigh1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eFilterHigh1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in cbEnableFilter1.
function cbEnableFilter1_Callback(hObject, eventdata, handles)
NapTime.NapMapper.UpdateFilter(handles, 1);
NapTime.NapMapper.UpdateChannelPlot(handles, 1);


function eFilterLow2_Callback(hObject, eventdata, handles)
NapTime.NapMapper.UpdateFilter(handles, 2);
NapTime.NapMapper.UpdateChannelPlot(handles, 2, true);


% --- Executes during object creation, after setting all properties.
function eFilterLow2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eFilterLow2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function eFilterHigh2_Callback(hObject, eventdata, handles)
% Update the filters and replot the channel data.
NapTime.NapMapper.UpdateFilter(handles, 2);
NapTime.NapMapper.UpdateChannelPlot(handles, 2, true);


% --- Executes during object creation, after setting all properties.
function eFilterHigh2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eFilterHigh2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in cbEnableFilter2.
function cbEnableFilter2_Callback(hObject, eventdata, handles)
NapTime.NapMapper.UpdateFilter(handles, 2);
NapTime.NapMapper.UpdateChannelPlot(handles, 2);
