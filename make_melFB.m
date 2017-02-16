function melFB = make_melFB(min_freq, max_freq, num_mel_filts, freqBins)

%   Inputs
%   ----------
%   min_freq : float
%       minimum frequency in Mel filterbank (Hz)
%   max_freq : float
%       maximum frequency in Mel filterbank (Hz)
%   num_mel_filts: int
%       number of Mel filters
%   freqBins : NF x 1
%       vector containing the frequency of each bin in the FFT
%       (same as the F from spectrogram function)
%
%   Returns
%   -------
%   melFB : num_mel_filts x length(freqBins)
%       Mel filterbank matrix (to left-multiply with spectrogram)
%__________________________________________________________________________

% Generate center frequencies of the mel FB in Hz. First, convert the input
% min and max frequencies from Hz to mel. In mel, the center frequencies
% are equally spaced, so it is easier to calculate them.
min_freq_mel = hz2mel(min_freq);
max_freq_mel = hz2mel(max_freq);
% [Note]:
% The width of each window depends on adjacent center frequencies. But the
% width of the first and last windows need a center frequency beyond the 
% min and max input frequencies. To get them, we can extrapolate backward 
% and forward in mel.
melval = zeros(1,num_mel_filts+2);
melval(2:(end-1)) = linspace(min_freq_mel, max_freq_mel, num_mel_filts);

d_melval = melval(3) - melval(2);  % The spacing in mel
       % = (max_freq_mel-min_freq_mel) / (num_mel_filts-1)
melval(1) = melval(2) - d_melval;        % Extrapolate backward
melval(end) = melval(end-1) + d_melval;  % Extrapolate forward

hzval = mel2hz(melval); % Convert center freqs back to Hz

% From the lecture slides: the mel FB can be a matrix with size:
%   numRows : num_mel_filts
%   numCols : the number of frequency bins of the spectrogram
melFB = zeros(num_mel_filts, length(freqBins));

% For each center frequency of the mel FB, find the frequency (Hz) in the F
% vector closest to it, and its index. Return the vector of indices.
% 
% Use: [nearest_indices] = find_nearest(reference, target)
%   reference : R x 1  ( F vector )
%   target : 1 x T     ( center freqs )
Idx_hzval = find_nearest(freqBins(:),hzval);

% Create a triangle window centered at each center frequency, and descends
% to zero at the adjacent center frequencies.
%   Idx_hz(i-1) = 0
%   Idx_hz(i) = 1
%   Idx_hz(i+1) = 0
for i = 2:(length(Idx_hzval)-1)
    % Indices 2:(end-1) of the vector 'hzval' are the center frequencies of
    % the triangle windows that we want. The two frequencies at the ends
    % are only used to construct the first and last windows.
    
    % Store the lowest mel-frequency on the first row; highest on the last.
    row = i - 1;
    
    % Set diagonal lines to be the sides of the triangular window.
    melFB(row, Idx_hzval(i-1):Idx_hzval(i)) = ...
                            linspace(0,1,Idx_hzval(i)-Idx_hzval(i-1)+1);
    melFB(row, Idx_hzval(i):Idx_hzval(i+1)) = ...
                            linspace(1,0,Idx_hzval(i+1)-Idx_hzval(i)+1);
    
    % Normalize the area of each filter
    filterArea = 0.5*(hzval(i+1)-hzval(i-1));  % 0.5 * base * height
    melFB(row,:) = melFB(row,:) / filterArea;
end

end