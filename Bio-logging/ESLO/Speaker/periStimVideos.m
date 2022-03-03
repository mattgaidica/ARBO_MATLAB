usePath = '/Users/matt/Dropbox (University of Michigan)/Biologging/Database/R0004/SWA Trials/20220303';
trialsPath = '/Users/matt/Dropbox (University of Michigan)/Biologging/Database/R0004/SWA Trials/Trials';
if ~isdir(trialsPath)
    mkdir(trialsPath)
end

files = dir2(usePath,'-r');
[path,name,ext] = fileparts({files.name});
elimIds = find(contains(name,'.') | strcmp(name,'') | [files.isdir]);
files(elimIds) = [];

%% select LED location
startSearch = 52; % set to 1 unless known video
pos = [0,0,0,0];
for startFile = startSearch:numel(files)
    v = VideoReader(fullfile(usePath,files(startFile).name));
    frame = readFrame(v);

    close all;
    imshow(frame);
    r1 = drawrectangle('Label','Indicator','Color',[0 0 0]);
    pos = round(r1.Position);
    if pos(3) > 0
        break;
    end
end
close all;

%%
clc
minPeak = 20; % Z-score intensity
minDist = 100; % frames, ~5s
grabSec = 5;
Trials = table;
trialCount = 0;
for iFile = 52%startFile:numel(files)
    fp = fullfile(usePath,files(iFile).name);
    v = VideoReader(fp);
    stimGreen = [];
    stimRed = [];
    fCount = 0;
    fprintf('---Finding stim %s\n',files(iFile).name);
    while hasFrame(v)
        fCount = fCount + 1;
        frame = readFrame(v);
        i_frame = imcrop(frame,pos);
        BW = createGreenMask(i_frame);
        stimGreen(fCount) = sum(BW,'all');
        BW = createRedMask(i_frame);
        stimRed(fCount) = sum(BW,'all');
    end
    locsGreen = peakseek(normalize(stimGreen),minDist,minPeak);
    locsRed = peakseek(normalize(stimRed),minDist,minPeak);
    frameWindow = round(grabSec/2 * v.FrameRate);

    allLocs = [locsGreen locsRed];
    [allLocs,k] = sort(allLocs);
    isSham = ones(size(allLocs));
    isSham(1:numel(locsGreen)) = 0;
    isSham = isSham(k);
    fprintf('Extracting %i trials\n',numel(allLocs));
    warning ('off','all');
    for iLoc = 1:numel(allLocs)
        trialCount = trialCount + 1;
        trialStr = sprintf('%05d',trialCount);
        fprintf('Trial %s\n',trialStr);
        Trials.isSham(trialCount) = isSham(iLoc);

        Trials.datetime(trialCount) = wyzeDt(fp) + seconds(allLocs(iLoc)/v.FrameRate);
        useFrames = [max([1,allLocs(iLoc)-frameWindow]),min([v.NumFrames,allLocs(iLoc)+frameWindow])];
        frames = read(v,useFrames);
        
        writeFile = fullfile(trialsPath,sprintf('%s_isSham%i_%s.mp4',trialStr,isSham(iLoc),...
            datestr(Trials.datetime(trialCount),'yyyymmdd-HHMMSS')));
        Trials.file(trialCount) = {writeFile};
        vW = VideoWriter(writeFile,'MPEG-4');
        vW.Quality = 95;
        open(vW);
        writeVideo(vW,frames);
        close(vW);
    end
    warning ('on','all');
    fprintf('\n');
end
if ~isempty(Trials)
    writetable(Trials,fullfile(trialsPath,'Trials.csv'));
    disp('Wrote Trials, done.');
else
    disp('No Trials');
end
chime;