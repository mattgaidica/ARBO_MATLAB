function s = plotAccel()

doPlot = true;
doVideo = false;

listing = dir('/Volumes/ARBO');
filename = fullfile(listing(end).folder,listing(end).name);
disp(['Reading ',filename]);
s = tdfread(filename,',');

datafields = fieldnames(s);
dataLabels = {'ACCEL','GYRO','MAG'};
close all;

if doPlot
    rows = 3;
    cols = 1;
    ff(1200,800);
    iData = 0;
    for ii = 1:3
        subplot(rows,cols,ii);
        for jj = 1:3
            iData = iData + 1;
            plot(getfield(s,datafields{iData}));
            hold on;
        end
        title(dataLabels{ii});
    end
end

if doVideo
    rows = 1;
    cols = 3;
    h = ff(1100,400);
    az = -60;
    el = 20;
    colors = lines(3);
    fieldsMat = [1:3;4:6;7:9];
    savePath  = '/Users/matt/Documents/Data/ARBO';
    v = VideoWriter(fullfile(savePath,'3D_9axis.avi'),'Motion JPEG AVI');
    v.Quality = 90;
    v.FrameRate = 60;
    open(v);
    for iData = 1:numel(getfield(s,datafields{1}))
        for iPlot = 1:3
            subplot(rows,cols,iPlot);
            xs = normalize(getfield(s,datafields{fieldsMat(iPlot,1)}));
            x = xs(iData);
            ys = normalize(getfield(s,datafields{fieldsMat(iPlot,2)}));
            y = ys(iData);
            zs = normalize(getfield(s,datafields{fieldsMat(iPlot,3)}));
            z = zs(iData);
            plot3(x,y,z,'.','color',colors(iPlot,:),'linewidth',1);
            xlabel('X');
            ylabel('Y');
            zlabel('Z');
            xlim([0 1]);
            ylim([0 1]);
            zlim([0 1]);
            xticks(xlim);
            yticks(ylim);
            zticks(zlim);
            hold on;
            grid on;
            az = az + 0.015;
            el = el + 0.005;
            view(az,el);
            title(dataLabels{iPlot});
            drawnow;
        end
        disp(['Writing frame ',num2str(iData)]);
        frame = getframe(gcf);
        writeVideo(v,frame);
        %     pause(0.1);
    end
    close(v);
    close(h);
end