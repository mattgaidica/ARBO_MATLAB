impath = '/Users/matt/Downloads/UV_TIFF';

if do
    images = {};
    for ii = 1:12
        imfile = sprintf("AURA_UVI_CLIM_M_2010-%02d.PNG",ii);
        IM = imread(fullfile(impath,imfile));
        images{ii} = IM;
    end
    do = false;
end

close all
h = ff(600,800);
subplot(211);
% montage(images,'Size',[3,4]);
imshow(images{6});
title('Select region...');
set(gca,'fontsize',14);
[xs,ys] = ginput(2);
xs = round(xs);
ys = round(ys);
hold on;
plot(xs(1),ys(1),'kx','markersize',25);
plot(xs(2),ys(2),'rx','markersize',25);

subplot(212);
colors = {"k","r"};
for jj = 1:2
    vals = [];
    for ii = 1:12
        vals(ii) = images{ii}(ys(jj),xs(jj));
    end
    plot(vals,'-','linewidth',3,'color',colors{jj});
    hold on;
end

title('UV Index');
ylabel('UV (a.u.)');
xlim([1 12]);
xticks(1:12);
xlabel('Month');
set(gca,'fontsize',14);
grid on;