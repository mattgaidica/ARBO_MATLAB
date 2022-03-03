function dt = wyzeDt(fp)

[path,fp_min] = fileparts(fp);
fp_min = str2double(fp_min);
parts = strsplit(path,filesep);
fp_hour = str2double(parts{end});
dt = datetime(str2double(parts{end-1}(1:4)),str2double(parts{end-1}(5:6)),str2double(parts{end-1}(7:8)),...
    fp_hour,fp_min,0);