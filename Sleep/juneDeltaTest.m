filePath = '/Users/matt/Documents/Data/ChoiceTask/LFPs/LFPfiles/R0088_20151030_R0088_20151030-1_data_ch44.sev';
[sev,header] = read_tdt_sev(filePath);
secOfRecording = 10;
raw_data = sev(1:round(secOfRecording*header.Fs));
delta_data = eegfilt(raw_data,round(header.Fs),1,4);
t = linspace(0,secOfRecording,numel(raw_data));

close all
ff(900,600);
plot(t,raw_data,'k');
xlabel('time (s)');
hold on;
plot(t,delta_data,'r','lineWidth',2);
plot(t,(abs(delta_data).^2),'b','lineWidth',2);