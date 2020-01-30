function ProcessNapMap(data)

if ischar(data)
	data = load(data);
end

% Get the map set.
mapSet = data.napMap.getMapSet(1, data.napMap.Length);

% Pull out the channel data.
emg = data.channelInfo(1).data;
eeg = data.channelInfo(2).data;

% Iterate over each chunk of the map.
index = 1;
for i = 1:length(mapSet)
	% Pull out one big chunk of data.
	emgData = emg(mapSet(i).start:mapSet(i).end);
	eegData = eeg(mapSet(i).start:mapSet(i).end);
	
	% The chunk may be bigger than the epoch size, so we need to subdivide
	% it into epoch sized pieces.  If the epoch size information isn't
	% there, we will assume its the default (10 seconds).
	if isfield(data, 'epochSize')
		% The GUI stores the epoch size in seconds.  We convert that value
		% into milliseconds.
		epochSize = data.epochSize * 1000;
	else
		epochSize = 10000;
	end
	numChunks = length(emgData) / epochSize;
	
	for j = 1:numChunks
		% These are the start and end indices for this epoch piece.
		s = (j-1)*epochSize + 1;
		e = s + epochSize - 1;
		
		% Dereference the epoch data piece.
		emgd = emgData(s:e);
		eegd = eegData(s:e);
		
		% Integral in the time domain of the EMG signal.
		absData = abs(emgd) .^ 2;
		emgPower(index) = sum(absData / epochSize);
		
		% Power in frequency domain of the EEG signal.		
		[Pxx, F] = pwelch(eegd, epochSize, 0, epochSize, 1000);
		
		% Get the indices for our different bands.
		di = F >= 0.4 & F < 4;		% delta
		ti = F >= 4 & F < 10;		% theta
		si = F >= 10 & F < 15;		% sigma
		bi = F >= 15 & F <= 20;		% beta
		
		% Calculate the power for each band.
		deltaPower(index) = sum(Pxx(di))/10000*2; %#ok<*AGROW>
		thetaPower(index) = sum(Pxx(ti))/10000*2;
		sigmaPower(index) = sum(Pxx(si))/10000*2;
		betaPower(index) = sum(Pxx(bi))/10000*2;
		
		stPower(index) = abs(sigmaPower(index) * thetaPower(index));
		dtRatio(index) = abs(deltaPower(index) / thetaPower(index));
		stRatio(index) = abs(sigmaPower(index) / thetaPower(index));
		
		% Store the type of data point this is so when we plot it later we
		% know how to classify it.
		dataPointType(index) = mapSet(i).mapType; %#ok<AGROW>
		
		index = index + 1;
	end
end

f = NapMapAnalysisPlot;
handles = guidata(f);

% Loop over the different map types (sleep states) and plot them.
e = enumeration('NapTime.MapTypes');
for i = 1:length(e)
	mapType = e(i);
	
	l = dataPointType == mapType;
	
	if any(l)
% 		figure(f);
% 		axes(handles.axesDTRvsSTP); %#ok<*LAXES>
% 		hold on;
% 		scatter(dtRatio(l), stPower(l), 10, mapType.RGB/255);
		NapMapAnalysisPlot('updateAxes', handles.axes1, dtRatio(l), stPower(l), 10, mapType.RGB/255);
		NapMapAnalysisPlot('updateAxes', handles.axes2, emgPower(l), dtRatio(l), 10, mapType.RGB/255);
		NapMapAnalysisPlot('updateAxes', handles.axes3, thetaPower(l), deltaPower(l), 10, mapType.RGB/255);
		NapMapAnalysisPlot('updateAxes', handles.axes4, thetaPower(l), sigmaPower(l), 10, mapType.RGB/255);
% 		figure(f);
% 		axes(handles.axesDTRvsEMGP);
% 		hold on;
% 		scatter(dtRatio(l), emgPower(l), 10, mapType.RGB/255);
	end
end
