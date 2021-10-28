inputA = -90;
f = int32(4*1000);
pa = int32(inputA*1000);
t1 = int32(1000*pa / (360*f))
if (t1 < 0)
    t1 = int32(t1 + 1000000/f)
end

f = (4*1000);
pa = (inputA*1000);
t2 = (1000*pa / (360*f))
if (t2 < 0)
    t2 = (t2 + 1000000/f)
end