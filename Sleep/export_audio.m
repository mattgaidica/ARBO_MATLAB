% [sev,header] = read_tdt_sev('/Users/matt/Documents/Data/ChoiceTask/LFPs/R0088_20151030a-selected 3/R0088_20151030_R0088_20151030-1_data_ch17.sev');
targetFs = 44100;
snip = sev(1:round(15*header.Fs));
adata = normalize(snip)*2-1;
adata_interp = equalVectors(adata,1:round((targetFs/header.Fs)*numel(adata)));
audiowrite('test.mp4',normalize(adata_interp)*2-1,targetFs);