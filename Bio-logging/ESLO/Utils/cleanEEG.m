function dirtySignal = cleanEEG(dirtySignal)
alpha = 5*10^4;
outlierIds = abs(dirtySignal) > alpha;
dirtySignal(outlierIds) = NaN;
dirtySignal = inpaint_nans(double(dirtySignal));
dirtySignal = detrend(dirtySignal);