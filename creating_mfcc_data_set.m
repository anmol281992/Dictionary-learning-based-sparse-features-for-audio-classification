%% create MFCC for large scale data data set
clear all;
home = pwd;
cd dataset3
%%
win_size = 512;
hop_size = 256;
%nfft = win_size;
min_freq = 86;
max_freq = 16000;    % sometimes get warning in omp()...
num_mel_filts = 40;
n_dct = 15;
setname = 'strings_all'; %foldername in which your data set exist
setname = 'percussion_all';
cd(setname);
file = dir;
featbundle = [];
for i = 1:numel(file)
    %get all the data 
    Fname = file(i).name;
    if length(Fname) > 4
        if strcmp(Fname(end-3:end),'.aif')
            x = audioread(Fname);
            initdir = pwd;
            cd(home);
            Fname = [initdir '/' Fname];
            x = mean(x,2);
            [mfccs, fs_mfcc] = compute_mfccs_anm(Fname, win_size,hop_size,min_freq, max_freq,num_mel_filts,n_dct);
            mfccfeat = [mean(mfccs,2);var(mfccs,0,2)];
            featbundle = [featbundle mfccfeat];
            cd(initdir);
            
         end
    end
    
end
%%
cd(home);
%mkdir('mfcc_featureset')
savedfile = [setname '_mfcc_feats.mat'];
save(savedfile,'featbundle');
cd(home);

