filename = '/Users/matt/Documents/MATLAB/ARBO/HRV/XX11_300s.arbo';
Fs = 250;
[A,t] = arbo_read32(filename,Fs);
% ff; plot(t,A,'k');
xs = 1.0e+04 * [0.9748, 4.2062];
A = A(xs(1):xs(2)); % figure this out!
t = t(xs(1):xs(2));

[qrs_amp_raw,qrs_i_raw,delay] = pan_tompkin(A,Fs,1);
qrs_t = qrs_i_raw / Fs;
RR = diff(qrs_t);
RR = HRV.RRfilter(RR);
rr = HRV.rrx(RR);

v = VideoWriter('geometricHR.avi','Motion JPEG AVI');
v.Quality = 95;
v.FrameRate = 10;
open(v);

close all
h = ff(650,600);
nLast = 10;
colors = flip(parula(nLast));
grays = gray(numel(rr)+100);
grays = flip(grays(1:numel(rr)-2,:));
for jRR = 1:numel(rr)-2
    for iRR = 1:jRR
        lw = 9/(jRR - iRR+1);
        ms = lw*3 + 1.5;
        if jRR - iRR < nLast % do color
            cc = colors(jRR - iRR+1,:);
        else
            cc = grays(jRR - iRR+1,:);
        end
        plot([rr(iRR),rr(iRR+1)],[rr(iRR+1),rr(iRR+2)],'color',cc,'lineWidth',lw);
        hold on;
        plot(rr(iRR),rr(iRR+1),'marker','o',...
            'MarkerEdgeColor','none','MarkerFaceColor',cc,...
            'MarkerSize',ms);
        plot(rr(iRR+1),rr(iRR+2),'marker','o',...
            'MarkerEdgeColor','none','MarkerFaceColor',cc,...
            'MarkerSize',ms);
        xlim([-.1,.1]);
        ylim(xlim);
    end
    set(gca,'color','k');
    set(gcf,'color','k');
    set(gca,'fontSize',14);
    xlabel('rr_i');
    ylabel('rr_{i+1}');
    c = colorbar;
    c.YTickLabel = {'rr-10','rr-9','rr-8','rr-7','rr-6','rr-5','rr-4','rr-3','rr-2','rr-1','rr'};
    drawnow;
    frame = getframe(gcf);
    writeVideo(v,frame);
    hold off;
end
close(v);

cff(900,500);
plot(t,A);
xlabel('time (s)');
ylabel('A');
hold on;
plot(qrs_t,A(qrs_i_raw),'ro');

title(['R-Rs @ ',num2str(HRV.HR(RR)),' bpm']);