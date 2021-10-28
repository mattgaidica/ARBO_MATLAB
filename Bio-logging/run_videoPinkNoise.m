videoFile = '/Users/matt/Downloads/pinkNoiseVideo.m4v';
audioFile = '/Users/matt/Downloads/pinkNoiseVideo.mp3';
v = VideoReader(videoFile);
[y,Fs] = audioread(audioFile);
xs = [30986.8421052632;118881.578947368;207302.631578947;310460.526315790];
xs = round(xs * (v.NumFrames / size(y,1)));

for ii = 1:numel(xs)
    figure;
    imshow(read(v,xs(ii)));
end