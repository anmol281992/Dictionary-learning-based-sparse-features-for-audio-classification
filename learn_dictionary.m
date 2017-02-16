function [IdxTrain,A,Cost_func_OMP,Cost_func_KSVD] = ...
    learn_dictionary(folderpath, savefilename, ...
        win_size, hop_size, nfft, min_freq, max_freq, num_mel_filts, ...
        nTrain, dictionarySize, k_omp, nIterations)
%__________________________________________________________________________
%   Inputs
%   -----------------------------------------------------------------------
%   folderpath     : string    What folder holds the data
%   savefilename   : string    Saves output data in .mat file w/ this name
%   win_size       : integer   ]>
%   hop_size       : integer   ]
%   nfft           : integer   ] Spectrogram / mel-filterbank parameters
%   min_freq       : integer   ]
%   max_freq       : integer   ]
%   num_mel_filts  : integer   ]>
%   
%   nTrain         : integer   Number of signals to use for training
%   dictionarySize : integer   Number of dictionary elements
%   k_omp          : integer   Max number of coeff to find using OMP
%   nIterations    : integer   Number of iterations to run learning loop
% 
%   Outputs
%   -----------------------------------------------------------------------
%   IdxTrain       : 1 x nTrain vector 
%     >> list of which signals in the folder were used
%   A              : num_mel_filts x dictionarySize matrix 
%     >> The dictionary.
%   Cost_func_OMP  : 1 x nIterations vector
%   Cost_func_KSVD : 1 x nIterations vector
%     >> Cost function history.
%__________________________________________________________________________

home = pwd;

%__________________________________________________________________________
% Nagivate to folder and select which files to use for training/testing.
% Save which signals were picked for dictionary learning.
cd(folderpath)

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

% Use number indexing to select a subset of the AIFF files for training.
IdxAIFF_all = find(IsAIFF);   % Find index of all .aif's in the list.
IdxAIFF_remaining = IdxAIFF_all; % List of those indices not chosen yet.
                              % Random permutation of this list of indices.
Chosen4Train = randperm(length(IdxAIFF_remaining),nTrain);
                              % Pick the chosen ones from the list.
IdxTrain = IdxAIFF_remaining(Chosen4Train);

%__________________________________________________________________________
% Prepare the signals and initialize the dictionary.   

% Read each .aif file, compute its spectrogram and store it.
Specs = cell(1,nTrain);
for i = 1:nTrain
    Fname = Files(IdxTrain(i)).name;
    [X,fs] = audioread(Fname); % Read audio file.

    X = X(1:min(end,fs),:);    % Keep only up to the first second.
    X = mean(X,2);             % Average across channels.

    [S,F,~] = spectrogram(X,win_size,hop_size,nfft,fs);
    S = abs(S);                % Use absolute value of spectrogram.
                               % Cut off a few columns from the ends.
    Specs{i} = S(:,5:min(154,end));    
end

% Concatenate all the spectrograms into one matrix Y.
m = 0;                           % Count how many columns in total
for i = 1:length(Specs)
    m = m + size(Specs{i},2);
end
Y = zeros(size(Specs{1},1),m);   % Initialize an empty matrix.
j = 1;                           % Store each spectrogram in Y.
for i = 1:length(Specs)
    c = size(Specs{i},2);
    Y(:,j:(j+c-1)) = Specs{i};
    j = j + c;
end

% Convert Y to mel-spectrogram.
cd(home)    % Go back home to use functions.
melFB = make_melFB(min_freq, max_freq, num_mel_filts, F);  % Make the FB.
Ymel = melFB * Y;     % Multiply to convert spec to mel-spec.

%__________________________________________________________________________
% Initalize a dictionary matrix A.
Y = Ymel;
[n,~] = size(Y);
A = rand(n,dictionarySize);             % Initialize with random elements.
A = A ./ repmat( sqrt(sum(A.^2, 1)) , [n 1]);  % Normalize to l2-norm = 1.

%__________________________________________________________________________
% Run Dictionary learning (OMP/KSVD)
Cost_func_OMP = zeros(1,nIterations);
Cost_func_KSVD = zeros(1,nIterations);

disp('Beginning OMP/KSVD...')

for i = 1:nIterations

    tic
    X = omp(Y,A,k_omp);
    toc

    disp(i)
    Cost_func_OMP(i) =  sum(sum( (Y - A*X).^2 ));
    disp(['Cost_func_before_KSVD = ' num2str(Cost_func_OMP(i))])

    tic
    for k = 1:dictionarySize
        [A(:,k), X(k,:)] = codebook_update_column(Y,A,X,k);
    end
    toc

    Cost_func_KSVD(i) = sum(sum( (Y - A*X).^2 ));
    disp(['Cost_func_after_KSVD = ' num2str(Cost_func_KSVD(i))])

end

%__________________________________________________________________________
% Save IdxTrain and Dictionary A after everything is done -----------------
save([savefilename '_clean' '.mat'],'IdxTrain','A','Cost_func_OMP','Cost_func_KSVD')



end  % end function








