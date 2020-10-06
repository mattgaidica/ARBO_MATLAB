[y,fs] = audioread('pinkyRec_smallSpeaker.m4a');
[~,freqVec,~,psd] = spectrogram(y,round(0.05*fs),[],[],fs);
meanPSD = mean(psd,2);

% figure;
semilogx(freqVec,db(meanPSD,"power"))
xlabel('Frequency (Hz)')
ylabel('PSD (dB/Hz)')
title('Power Spectral Density of Pink Noise (Averaged)')
grid on
hold on
% % figure;
% % histogram(y,"Normalization","probability","EdgeColor","none")
% % xlabel("Amplitude")
% % ylabel("Probability")
% % title("Relative Probability of Pink Noise Amplitude")
% % grid on