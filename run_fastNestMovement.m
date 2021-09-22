rootPath = '/Volumes/Seagate Expansion Drive/Gaidica/Database/0009/record';
files = dir2(rootPath,'*.mp4','-r');
startName = '20210917/09/17.mp4';
endName = '20210919/10/29.mp4';

startId = find(strcmp({files(:).name},startName));
endId = find(strcmp({files(:).name},endName));
if do
    diffArr = [];%zeros(1,numel(startId:endId));
    doPos = true;
    diffCount = 0;
    for ii = startId:endId
        disp(ii);
        if files(ii).bytes < 1000
            disp('skipping...');
            continue;
        end
        filename = fullfile(rootPath,files(ii).name);
        v = VideoReader(filename);
        if doPos
            imshow(read(v,1));
            roi = drawrectangle;
            pos = round(roi.Position);
            useX = pos(1):pos(1)+pos(3)-1;
            useY = pos(2):pos(2)+pos(4)-1;
            close all;
            doPos = false;
        end

        diffCount = diffCount + 1;
        frame1 = double(im2gray(read(v,1)));
        frame2 = double(im2gray(read(v,v.NumFrames)));
        diffIm = frame1(useY,useX) - frame2(useY,useX);
        diffArr(diffCount) = mean(mean(abs(diffIm)));
    end
end
%%
t = {files(startId:endId).date};
figure;
plot(diffArr);
hold on;
isDark = zeros(1,numel(t));
isDark(hour(t) > 18 | hour(t) < 7 | (hour(t)==7 & minute(t)<30)) = 1;
onLocs = find(diff(isDark) == 1);
offLocs = find(diff(isDark) == -1);
for ii = 1:numel(onLocs)
    yLoc =  max(ylim)-max(ylim)*0.1;
    lns(3) = plot([onLocs(ii),offLocs(ii)],[yLoc yLoc],'-','linewidth',15,'color',[0 0 0 0.5]);
    xline(onLocs(ii),'k--');
    xline(offLocs(ii),'k--');
end

%%
close all
[P,F] = pspectrum(diffArr,1/60);
figure;
plot(F,smoothdata(P,'movmean',50),'k-');
set(gca,'yscale','log')