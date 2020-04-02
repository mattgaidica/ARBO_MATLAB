filename = '/Users/matt/Desktop/Screen Recording 2020-04-01 at 10.07.34 PM.mov'; % forest
% filename = '/Users/matt/Desktop/leapingSquirrel.mov'; % leap
% filename = '/Users/matt/Desktop/Screen Recording 2020-04-02 at 12.31.11 AM.mov';
% filename = '/Users/matt/Desktop/Screen Recording 2020-04-01 at 10.53.19 PM.mov';
v = VideoReader(filename);
vW = VideoWriter('~/Desktop/squirrelDetect.mp4','MPEG-4');
vW.Quality = 95;

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

close all
ff(1400,600);
rows = 4;
cols = 6;
nBuffer = 15;
backgroundArr = zeros(v.Height,v.Width,3,nBuffer,'uint8');
replayRate = 4;
useFrames = round(linspace(1,v.NumFrames,round(v.NumFrames/replayRate)));
fracArr = NaN(size(useFrames));
se = strel('disk',2);
fontsize = 14;
open(vW);
for ii = 1:numel(useFrames)
    frame = read(v,useFrames(ii));
    frameHSV = rgb2hsv(frame);
    if ii <= nBuffer
        backgroundArr(:,:,:,ii) = frame;
        continue;
    else
        backgroundArr = circshift(backgroundArr,-1,4);
        backgroundArr(:,:,:,end) = frame;
    end
    background = uint8(squeeze(mean(backgroundArr,4)));
    differenceImage = frame - background;
    differenceImageHSV = frameHSV - rgb2hsv(background);
    grayImage = rgb2gray(differenceImage.^2); % Convert to gray level
    thresholdLevel = graythresh(grayImage); % Get threshold.
    binaryImage = im2bw(grayImage, sqrt(thresholdLevel)); % Do the binarization
    binaryOpen = imopen(binaryImage,se);
    
    subplot(rows,cols,[1 2 7 8]);
    imshow(frame);
    title('Original');
    set(gca,'fontsize',fontsize);

    subplot(rows,cols,[3 4 9 10]);
    imshow(differenceImage.^2);
    title('RGB Difference');
    set(gca,'fontsize',fontsize);
    
    subplot(rows,cols,[5 6 11 12]);
    imshow(binaryOpen);
    title('Binarized');
    set(gca,'fontsize',fontsize);
    
    subplot(rows,cols,[13:24]);
    fracArr(ii) = sqrt(sum(binaryOpen(:))/numel(binaryOpen));
    plot(fracArr,'k');
    hold on;
    ln = plot([ii-nBuffer ii],[0 0],'k-','linewidth',5);
    xlim([1,numel(useFrames)]);
    ylim([0 0.7]);
    title('Quantified Movement');
    ylabel('fraction of change');
    xlabel('frame');
    set(gca,'fontsize',fontsize);
    legend(ln,'background buffer');
    legend boxoff;
    hold off;
    
    drawnow;
    A = getframe(gcf);
    writeVideo(vW,A);
end
close(vW);