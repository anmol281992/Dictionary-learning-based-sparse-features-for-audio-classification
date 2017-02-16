% Anmol Monga : N18513543
function [mfccs, fs_mfcc] = compute_mfccs_anm(filepath, win_size, hop_size, ...
min_freq, max_freq, num_mel_filts, n_dct)
% Compute MFCCs from audio file.
%
% Parameters
% ----------
% filepath : string
% path to .wav file
% win size : int
% spectrogram window size (samples)
% hop size : int
% spectrogram hop size (samples)
% min freq : float
% minimum frequency in Mel filterbank (Hz)
% max freq : float
% maximum frequency in Mel filterbank (Hz)
% num mel filts: int
% number of Mel filters
% n dct: int
% number of DCT coefficients
%
% Returns
% -------
% mfccs : n dct-1 x NT array
% MFCC matrix (NT is number spectrogram frames)
% fs mfcc : int
% sample rate of MFCC matrix (samples/sec)
win = hamming(win_size);
[y,fs] = audioread(filepath);
y = mean(y,2);
Nfft = 4*win_size;
[z,f,t] = spectrogram(y,win,(win_size - hop_size),Nfft,fs);
f = (f/max(f))*fs/2;
minfreq = hz2mel(min_freq);
maxfreq = hz2mel(max_freq);
num = num_mel_filts + 2;
v = minfreq:((maxfreq - minfreq)/num):maxfreq ;
hzv = mel2hz(v);
reference = f;
target = hzv;
nearestindices = find_nearest(reference, target);
hzv = reference(nearestindices);
%filtbank = zeros(length(f));
k = 1;
for i = 2:(length(nearestindices)-1)
    L = zeros(1,length(f));
    height = 2/(f(nearestindices(i+1))-f(nearestindices(i-1)));
    L(nearestindices(i-1):nearestindices(i)) = (height*(f(nearestindices(i-1):nearestindices(i))-f(nearestindices(i-1))))/(f(nearestindices(i))-f(nearestindices(i-1)));
    L(nearestindices(i)+1:nearestindices(i+1)) = (-height * (f((nearestindices(i)+1):(nearestindices(i+1)))-f(nearestindices(i))))/(f(nearestindices(i+1))-f(nearestindices(i)))+ height; 
    filtbank(k,:) = L;
    k = k+1;
end

%Z(1:nearestindices(1)-1,:) = 0;
%Z((nearestindices(end)+1):end,:)= 0;
zmelspect = filtbank * abs(z);
zmelspectdb = 10*log10((zmelspect));
mfcc = dct(zmelspectdb);
mfccs = mfcc(2:(n_dct+1),:);
[n,m] = size(mfccs);
% type of normalization 
mfccs = mfccs./repmat(sum(mfccs,2),[1 m]); % across time
%mfccs = mfccs./repmat(sum(mfccs,1),[n_dct 1]); % across quefrequency
fs_mfcc = fs/hop_size ;
end