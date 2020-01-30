function TestBS

f = 'C:\Users\Chris\Documents\MATLAB\bsl visual test 11_13.nex';
o = NapTime.NEX.File(f);
w = [10 40] / 500;

tic;
[z,p,k] = ellip(4,1,60,w);
[sos,g] = zp2sos(z,p,k); 
d = dfilt.df2sos(sos,g);
toc;

x = o.ADChannels(2).Data;
y = o.ADChannels(2).filter(d);

plot(x);
hold on;
plot(y,'r');
