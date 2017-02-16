function [X_max_feats,X_avg_feats] = ...
    compute_features_test(folderpath, savefilename, ...
        win_size, hop_size, nfft, min_freq, max_freq, num_mel_filts, ...
        IdxTrain, nTest, A1, A2, k_omp)

%__________________________________________________________________________

home = pwd;

%__________________________________________________________________________
% Nagivate to folder.
cd(folderpath)

% List which files in the folder are .aif files.
Files = dir;
IsAIFF = zeros(1,numel(Files));
for i = 1:numel(Files)
    Fname = Files(i).name;
    if length(Fname) > 4
    if strcmp(Fname(end-3:end),'.aif')
        IsAIFF(i) = 1;
    end
    end    
end

% Use logical indexing to remove used training signals from the list. 
% Select another set from the remaining list to use for testing.
Idx2remove = ~IsAIFF;         % 1 if file is not AIFF
Idx2remove(IdxTrain) = 1;  % Set those already picked to 1.
Idx_remaining = 1:numel(Files);
Idx_remaining(Idx2remove) = [];

Chosen4Test = randperm(length(Idx_remaining),nTest);
IdxTest = Idx_remaining(Chosen4Test);

%__________________________________________________________________________
% Preallocate matrix to store the pooled features.

X_max_pool = zeros( 2*size(A1,2), nTest );
X_avg_pool = X_max_pool;

% Read each .aif file, compute its pooled and store it.
for i = 1:nTest
    Fname = Files(IdxTest(i)).name;
    [X,fs] = audioread(Fname); % Read audio file.

    X = X(1:min(end,fs),:);    % Keep only up to the first second.
    X = mean(X,2);             % Average across channels.

    [S,F,~] = spectrogram(X,win_size,hop_size,nfft,fs);
    S = abs(S);                % Use absolute value of spectrogram.
    S = S(:,5:min(154,end));   % Cut off a few columns from the ends.
    
    cd(home) % Go back to folder to use the functions
    
    % Convert to mel-spectrogram
    melFB = make_melFB(min_freq, max_freq, num_mel_filts, F);
    Ymel = melFB * S;
    
    % Run omp on this data, using two dictionaries. Concatenate coeffs.
    % Xi is  L x N
    % X  is 2L x N
    X1 = omp(Ymel, A1, k_omp);
    X2 = omp(Ymel, A2, k_omp);
    X = [X1; X2];
    
    % max/avg pooling across signals, per signal, per class
    X_max_pool(:,i) = max(abs(X),[],2);
    X_avg_pool(:,i) = mean(X,2);
    
    cd(folderpath)  % Return to data folder for next loop
end
    
cd(home)  % Save data in home directory
save([savefilename '_test_feat' '_' 'clean' '.mat'],'X_max_pool','X_avg_pool')