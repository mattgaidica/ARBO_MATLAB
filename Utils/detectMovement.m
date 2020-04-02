filename = '/Users/matt/Desktop/Screen Recording 2020-04-01 at 10.07.34 PM.mov';
% filename = '/Users/matt/Desktop/Screen Recording 2020-04-01 at 10.53.19 PM.mov';
v = VideoReader(filename);

% % % % if false
% % % %     rows = 5;
% % % %     cols = 6;
% % % %     nFrames = rows*cols;
% % % %     useFrames = round(linspace(1,v.NumFrames,nFrames));
% % % %     backgroundFrames = zeros(v.Height,v.Width,3,nFrames,'uint8');
% % % %     for ii = 1:nFrames
% % % %         backgroundFrames(:,:,:,ii) = read(v,useFrames(ii));
% % % %     end
% % % %     close all
% % % %     h = figure2;
% % % %     montage(backgroundFrames,'size',[rows cols]);
% % % %     [xs,ys] = ginput;
% % % %     useCols = fix((xs./max(xlim))*cols + 1);
% % % %     useRows = fix((ys./max(ylim))*rows + 1);
% % % %     close(h);
% % % %     selectedIds = [];
% % % %     for ii = 1:numel(useCols)
% % % %         selectedIds(ii) = prc(cols,[useRows(ii),useCols(ii)]);
% % % %     end
% % % %     background = uint8(squeeze(mean(backgroundFrames(:,:,:,selectedIds),4)));
% % % % end

v.CurrentTime = 0;
alpha = 0.5;
close all
figure2;
fracArr = [];
nFrac = 0;
nMod = 0.5;
useFrames = round(linspace(1,v.NumFrames,round(v.NumFrames*nMod)));
for ii = 1:numel(useFrames)
    frame = read(v,useFrames(ii));
% %     background = (1-alpha) * frame + alpha * background;
    differenceImage = frame - background;
    grayImage = rgb2gray(differenceImage); % Convert to gray level
    thresholdLevel = graythresh(grayImage); % Get threshold.
    binaryImage = im2bw(grayImage, thresholdLevel); % Do the binarization
    
    subplot(131);
    imshow(frame);
    subplot(132);
    imshow(grayImage);
    subplot(133);
    fracArr(ii) = sum(differenceImage(:))/(numel(differenceImage)*255);
    plot(fracArr);
    xlim([1,numel(useFrames)]);
    ylim([0 0.4]);
    drawnow;
end