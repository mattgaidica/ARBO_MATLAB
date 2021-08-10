function vt100(data)
eraseLine = [27 uint8('[2K')];
escIdx = strfind(data,eraseLine);
lines = {};
iLine = 1;
for iEsc = 1:numel(escIdx)
    upToIdx = find(data(escIdx(iEsc)+1:end)==27,1) + escIdx(iEsc);
    if ~isempty(upToIdx)
        thisLine = char(data(escIdx(iEsc)+numel(eraseLine):upToIdx-1));
        if ~isempty(thisLine)
            lines{iLine} = thisLine;
            iLine = iLine + 1;
        end
    end
end
for iLine = 1:numel(lines)
    disp(lines{iLine});
end