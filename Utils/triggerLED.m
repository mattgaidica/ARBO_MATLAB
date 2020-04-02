filename = '/Users/matt/Desktop/2000_0907_001218_090.MP4';
v = VideoReader(filename);
% while hasFrame(v)
    frame = readFrame(v);
% end

% close all
fig = figure;
imshow(frame);
h = imrect;
pos = round(h.getPosition());

iFrame = 0;
nMod = 10;
loopCount = 0;
HSV_ = [];
tic;
while hasFrame(v)
    loopCount = loopCount + 1;
    frame = readFrame(v);
    if mod(loopCount,nMod) ~= 0
        continue;
    end
    iFrame = iFrame + 1;
    HSV = rgb2hsv(frame);
    HSV_sub = HSV(pos(2):pos(2)+pos(4)-1,pos(1):pos(1)+pos(3)-1,:);
    imshow(HSV_sub);
    HSV_(iFrame,:,:) = reshape(HSV_sub,[pos(3)*pos(4),3]);
    disp(loopCount);
end
toc

close all
std_H = std(HSV_(:,:,1));
std_S = std(HSV_(:,:,2));
std_V = std(HSV_(:,:,3));

[v,k] = sort(std_S.*std_V);
% k(end) is the best pixel!
figure;
plot(HSV_(:,k(end),3));

figure;
subplot(131);
imagesc(HSV_(:,k,1)');
subplot(132);
imagesc(HSV_(:,k,2)');
subplot(133);
imagesc(HSV_(:,k,3)');

figure;
scatter(std_H,std_V,'filled','r');
xlabel('hue');
ylabel('value');
hold on;
% zlabel('val');

ff(1200,600);
subplot(131);
imagesc(squeeze(HSV_(:,:,1))');
title('hue');
subplot(132);
imagesc(squeeze(HSV_(:,:,2))');
title('saturation');
subplot(133);
imagesc(squeeze(HSV_(:,:,3))');
title('value');