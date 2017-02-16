function [X_max_feats,X_avg_feats] = ...
    compute_features_train(folderpath, savefilename, ...
        win_size, hop_size, nfft, min_freq, max_freq, num_mel_filts, ...
        IdxTrain, A1, A2, k_omp)

%__________________________________________________________________________

home = pwd;

%__________________________________________________________________________
% Nagivate to folder.
cd(folderpath)
Files = dir;

% Preallocate matrix to store the pooled features.
X_max_pool = zeros( 2*size(A1,2), numel(IdxTrain) );
X_avg_pool = X_max_pool;

for i = 1:numel(IdxTrain)
    Fname = Files(IdxTrain(i)).name;
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

cd(home)
save([savefilename '_train_feat' '_' 'clean' '.mat'],'X_max_pool','X_avg_pool')