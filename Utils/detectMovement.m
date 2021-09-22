% filename = '/Users/matt/Desktop/Squirrel_sleep_trim.mp4';
filename = '/Volumes/Seagate Expansion Drive/Gaidica/Database/0009/record/20210919/04/19.mp4';
v = VideoReader(filename);
vW = VideoWriter('~/Desktop/squirrelDetect_night.mp4','MPEG-4');
vW.Quality = 95;
vw.FrameRate = 120;

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
rows = 4;
cols = 6;
nBuffer = 5;
replayRate = 1;
useFrames = round(linspace(1,v.NumFrames,round(v.NumFrames/replayRate)));
fracArr = NaN(size(useFrames));
se = strel('disk',2);
fontsize = 14;
% use rect
frame = read(v,useFrames(1));
imshow(frame);
roi = drawrectangle; %roi.Position = [x,y,width,height]
pos = round(roi.Position);
useX = pos(1):pos(1)+pos(3)-1;
useY = pos(2):pos(2)+pos(4)-1;
close all;

t = linspace(0,v.Duration/60,numel(useFrames));
backgroundArr = zeros(numel(useY),numel(useX),3,nBuffer,'uint8');
open(vW);
ff(1400,600);
for ii = 1:numel(useFrames)
    orig_frame = read(v,useFrames(ii));
    frame = orig_frame(useY,useX,:); % use rect
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
    
    subplot(rows,cols,13:24);
    fracArr(ii) = sum(binaryOpen(:))/numel(binaryOpen);
    plot(t,fracArr,'k');
%     hold on;
%     ln = plot([ii-nBuffer ii],[0 0],'k-','linewidth',5);
    xlim([min(t) max(t)]);
    ylim([0 0.1]);
    title('Quantified Movement');
    ylabel('Fraction of Change');
    xlabel('Time (min)');
    set(gca,'fontsize',fontsize);
%     legend(ln,'background buffer');
%     legend boxoff;
    hold off;
    
    drawnow;
    A = getframe(gcf);
    writeVideo(vW,A);
end
close(vW);
close all;