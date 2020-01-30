function filterObj = CreateBandpassFilter(lowCutoff, highCutoff, sampleRate)
% CreateBandpassFilter - Creates a bandpass filter.
%
% Syntax:
% filterObj = CreateBandpassFilter(lowCutoff, highCutoff, sampleRate)
%
% Description:
% Creates a 4th order elliptical bandpass filter to filter the NEX data.
% Inputs are expected to be in Hz, not normalized Nyquist values.
%
% Input:
% lowCutoff (scalar) - Low cutoff frequency. (Hz)
% highCutoff (scalar) - High cutoff frequency. (Hz)
% sampleRate (scalar) - The sample rate of the the data to be filtered.
%
% Output:
% filterObj (dfilt) - The resulting dfilt object.  See MATLAB help for more
%     info.

narginchk(3, 3);

% Convert the cutoff frequencies into normalized values.
lowCutoff = lowCutoff / (sampleRate / 2);
highCutoff = highCutoff / (sampleRate / 2);

% Create a 4th order elliptical filter.
[z,p,k] = ellip(4, 1, 60, [lowCutoff highCutoff]);
[sos,g] = zp2sos(z, p, k); 
filterObj = dfilt.df2sos(sos, g);
