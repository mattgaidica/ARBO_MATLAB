Fs = 250;
recPath = '/Users/matt/Documents/MATLAB/ARBO/Bio-logging/ESLO/recordings/';
file = '';
if isempty(file)
    [file,path] = uigetfile(fullfile(recPath,'*.csv'),'Select a recording...');
end
if ~isempty(path)
    A = readmatrix(fullfile(path,file));
    A = reshape(A',1,[]);
    A(isnan(A)) = [];
    t = linspace(0,numel(A)/Fs,numel(A));

%     close all
    ff(1200,500);
    plot(t,A,'k');
    xlim([min(t) max(t)]);
    xlabel('Time (s)');
    ylabel('a.u.');
    set(gca,'fontsize',14);
    title(file,'textInterpreter','None');
end