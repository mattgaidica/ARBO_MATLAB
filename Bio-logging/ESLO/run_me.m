fname = '/Volumes/LEXAR633X/ESLORB2.TXT';
[type,data,labels] = extractSD(fname);

close all
ff(1000,600);
plot(data(type==4));