function NapFilter(nexFiles, lowCutoff, highCutoff)
% NAPFILTER - Filters a set of NEX files with a bandpass filter.

narginchk(3, 3);

% Check to see if the NEX file spec is a regular file or a directory.
if isdir(nexFiles)
	% Get a list of all NEX files in the directory.
	f = dir(fullfile(nexFiles, '*.nex'));
	
	% Format the list into a cell array of full path names.
	fileList = {};
	for i = 1:length(f)
		% Exclude already filtered files so we don't filter a filtered
		% file.
		if isempty(strfind(f(i).name, '-filtered-'))
			fileList{end+1} = fullfile(nexFiles, f(i).name); %#ok<AGROW>
		end
	end
	numFiles = length(fileList);
	
	assert(numFiles > 0, 'NapFilter:NoFiles', 'No NEX files found in directory: %s', ...
		nexFiles);
else
	% Check that the NEX file exists.
	assert(logical(exist(nexFiles, 'file')), 'NapFilter:FileNotFound', ...
		'Cannot find file: %s', nexFiles);
	
	% Format the single NEX file name into a cell array so that it looks
	% the same as the output from a directory listing of NEX files.
	fileList = {nexFiles};
	numFiles = 1;
end

% Iterate over the list of files to process.
for i = 1:numFiles
	fprintf('- Processing file: %s...', fileList{i});
	
	% Read the NEX file.
	nexData = NapTime.NEX.readNexFile(fileList{i});
	
	% Loop over the continuous channels to filter.
	for c = 1:length(nexData.contvars)
	%for c = 1:1
		% Create a bandpass filter.
		filterObj = NapTime.CreateBandpassFilter(lowCutoff, highCutoff, ...
			nexData.contvars{c}.ADFrequency);
		
		% Filter the data and overwrite the channel data.
		nexData.contvars{c}.data = filterObj.filter(nexData.contvars{c}.data);
	end
	
	% Write the new filtered file to disk with the same name but with
    % '-filtered' at the end.
    [p, f] = fileparts(fileList{i});
    if isempty(p)
        p = '.';
    end
    a = sprintf('-filtered-%g-%g.nex', lowCutoff, highCutoff);
	NapTime.NEX.writeNexFile(nexData, fullfile(p, [f a]));
	
	fprintf('Done\n');
end
