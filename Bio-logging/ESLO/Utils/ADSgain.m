function uV = ADSgain(EEG,adsGain)
Vref = 1.5;
uV = EEG .* (Vref/adsGain)/(2^23-1) * 10^6;