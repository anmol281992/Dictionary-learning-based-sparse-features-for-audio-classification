%% Set Parameters (dictionary size)
clc;

win_size = 512;
hop_size = 256;
nfft = win_size;
min_freq = 86;
max_freq = 16000;    % sometimes get warning in omp()...
num_mel_filts = 40;

nTrain = 80;  % How many training signals
nTest = 30;    % How many testing signals

dictionarySize = 40;

nIterations = 20;
k_omp = 1;

nIter = 2;

home = pwd;

% Pick two classes to test.
k1 = 1;     % Class 1 is strings
k2 = 2;     % Class 2 is percussion

for iter = 1:nIter
savefilenames = cell(1,2);
savefilenames{1} = [num2str(iter) 'data_strings'];
savefilenames{2} = [num2str(iter) 'data_percussion'];

folderpaths = cell(1,2);
folderpaths{1} = [home '\dataset3\strings_all'];
folderpaths{2} = [home '\dataset3\percussion_all'];

% Learn Dictionary (clean) class 1
        learn_dictionary(folderpaths{k1}, savefilenames{k1}, ...
        win_size, hop_size, nfft, min_freq, max_freq, num_mel_filts, ...
        nTrain, dictionarySize, k_omp, nIterations);
disp('class 1 clean done')

% Learn Dictionary (clean) class 2
        learn_dictionary(folderpaths{k2}, savefilenames{k2}, ...
        win_size, hop_size, nfft, min_freq, max_freq, num_mel_filts, ...
        nTrain, dictionarySize, k_omp, nIterations);
disp('class 2 clean done')


% Compute clean  training features

% Compute clean features
DATA1 = load([savefilenames{k1} '_clean.mat'],'IdxTrain','A');
DATA2 = load([savefilenames{k2} '_clean.mat'],'IdxTrain','A');
IdxTrain = cell(1,2);
IdxTrain{1} = DATA1.IdxTrain;
IdxTrain{2} = DATA2.IdxTrain;
A1 = DATA1.A;
A2 = DATA2.A;

tic
% Class 1
compute_features_train(folderpaths{k1}, savefilenames{k1}, ...
    win_size, hop_size, nfft, min_freq, max_freq, num_mel_filts, ...
    IdxTrain{1}, A1, A2, k_omp);
% Class 2
compute_features_train(folderpaths{k2}, savefilenames{k2}, ...
    win_size, hop_size, nfft, min_freq, max_freq, num_mel_filts, ...
    IdxTrain{2}, A1, A2, k_omp);
toc

disp('computing clean training features done')

% Compute clean / noisy testing features

IdxTrain = cell(1,2);

% Compute clean features
DATA1 = load([savefilenames{k1} '_clean.mat'],'IdxTrain','A');
DATA2 = load([savefilenames{k2} '_clean.mat'],'IdxTrain','A');
IdxTrain{1} = DATA1.IdxTrain;
IdxTrain{2} = DATA2.IdxTrain;
A1 = DATA1.A;
A2 = DATA2.A;

tic
% Class 1
compute_features_test(folderpaths{k1}, savefilenames{k1}, ...
        win_size, hop_size, nfft, min_freq, max_freq, num_mel_filts, ...
        IdxTrain{1}, nTest, A1, A2, k_omp);
% Class 2
compute_features_test(folderpaths{k2}, savefilenames{k2}, ...
        win_size, hop_size, nfft, min_freq, max_freq, num_mel_filts, ...
        IdxTrain{2}, nTest, A1, A2, k_omp);
toc

disp('computing clean testing features done')

% Write features to ARFF

whichSet = cell(1,2);
whichSet{1} = 'train';
whichSet{2} = 'test';

feature_name = cell(1,2);
feature_name{1} = 'X_max_pool';
feature_name{2} = 'X_avg_pool';


for k = 1:2  % which set (train or test)
for j = 1:2  % which feature to write (max or avg)
    
    file2load1 = [savefilenames{k1} '_' whichSet{k} '_feat_clean.mat'];
    file2load2 = [savefilenames{k2} '_' whichSet{k} '_feat_clean.mat'];
    
    X1_feat = load(file2load1, feature_name{j});
    X2_feat = load(file2load2, feature_name{j});

    X1_feat = getfield(X1_feat, feature_name{j});
    X2_feat = getfield(X2_feat, feature_name{j});

    arff_filename = ...
    [num2str(iter) 'k_omp' num2str(k_omp) '_features' '_' whichSet{k} '_' feature_name{j} '_clean']

    features_to_arff(arff_filename,X1_feat,X2_feat)

end
end

% %% Write Weka CLI commands
% In another file
end
load handel
sound(y,Fs)