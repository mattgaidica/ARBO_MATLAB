filename = '/Volumes/Seagate Expansion Drive/Gaidica/Database/0009/record/20210919/02/00.mp4';
v = VideoReader(filename);

vW = VideoWriter('~/Desktop/squirrelTest.mp4','MPEG-4');
vW.Quality = 100;
open(vW);
for ii = 1:v.NumFrames
    disp(ii);
    frame = read(v,ii);
    writeVideo(vW,frame);
end
close(vW);

%%
filename = '/Volumes/Seagate Expansion Drive/Gaidica/Database/0009/record/20210919/05/23.mp4';
vW = VideoWriter('~/Desktop/squirrelTest2.mp4','MPEG-4');
vW.Quality = 100;
open(vW);
for ii = 1:v.NumFrames
    disp(ii);
    frame = read(v,ii);
    writeVideo(vW,frame);
end
close(vW);