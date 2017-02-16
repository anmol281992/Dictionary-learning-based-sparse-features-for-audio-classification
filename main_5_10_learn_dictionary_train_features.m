%% Set Parameters (dictionary size)
clc; clear;
home = pwd;

win_size = 512;
hop_size = 256;
nfft = win_size;
min_freq = 86;
max_freq = 16000;
num_mel_filts = 40;

nTrain = 80;  % How many training signals
nTest = 30;    % How many testing signals

dictionarySize = 40;  % Dictionary size

nIterations = 20;
k_omp = 1;

% Pick two classes to test.
k1 = 1;     % Class 1 is strings
k2 = 2;     % Class 2 is percussion

savefilenames = cell(1,2);
savefilenames{1} = 'data_strings';
savefilenames{2} = 'data_percussion';

folderpaths = cell(1,2);
folderpaths{1} = [home '/dataset3/strings_all'];
folderpaths{2} = [home '/dataset3/precussions_all'];


%% Learn Dictionary (clean) class 1
        learn_dictionary(folderpaths{k1}, savefilenames{k1}, ...
        win_size, hop_size, nfft, min_freq, max_freq, num_mel_filts, ...
        nTrain, dictionarySize, k_omp, nIterations);
disp('class 1 clean done')

%% Learn Dictionary (clean) class 2
        learn_dictionary(folderpaths{k2}, savefilenames{k2}, ...
        win_size, hop_size, nfft, min_freq, max_freq, num_mel_filts, ...
        nTrain, dictionarySize, k_omp, nIterations);
disp('class 2 clean done')


%% Compute clean  training features

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

%% Compute clean / noisy testing features

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
compute_features_test(folderpaths{k1}, savefilenames{k1}, ...
        win_size, hop_size, nfft, min_freq, max_freq, num_mel_filts, ...
        IdxTrain{1}, nTest, A1, A2, k_omp);
% Class 2
compute_features_test(folderpaths{k2}, savefilenames{k2}, ...
        win_size, hop_size, nfft, min_freq, max_freq, num_mel_filts, ...
        IdxTrain{2}, nTest, A1, A2, k_omp);
toc

disp('computing clean testing features done')

%% Write features to ARFF

whichSet = cell(1,2);
whichSet{1} = 'train';
whichSet{2} = 'test';

feature_name = cell(1,2);
feature_name{1} = 'X_max_pool';
feature_name{2} = 'X_avg_pool';


for k = 1:2  % which set (train or test)
for j = 1:2  % which feature to write (max or avg)
    
    % Load a {feature} from the {train/test} set of both classes
    file2load1 = [savefilenames{k1} '_' whichSet{k} '_feat_clean.mat'];
    file2load2 = [savefilenames{k2} '_' whichSet{k} '_feat_clean.mat'];
    
    X1_feat = load(file2load1, feature_name{j});
    X2_feat = load(file2load2, feature_name{j});

    X1_feat = getfield(X1_feat, feature_name{j});
    X2_feat = getfield(X2_feat, feature_name{j});

    arff_filename = ...
              ['features' '_' whichSet{k} '_' feature_name{j} '_clean']

    features_to_arff(arff_filename,X1_feat,X2_feat)

end
end

%% Write Weka CLI commands
fid = fopen('weka_test.txt','w');

% features_[train]_[X_max_pool].arff
%          [test]  [X_avg_pool] 

whichSet = cell(1,2);
whichSet{1} = 'train';
whichSet{2} = 'test';

feature_name = cell(1,2);
feature_name{1} = 'X_max_pool';
feature_name{2} = 'X_avg_pool';


for j = 1:2           % for each feature name

trainFilename = [pwd '\features_train_' feature_name{j} '_clean.arff'];
testFilename = [pwd '\features_test_' feature_name{j} '_clean.arff'];
    
fprintf(fid,'\n');
fprintf(fid,feature_name{j});
fprintf(fid,'\n');

% polynomial kernel
fprintf(fid,'radial basis kernel\n');
fprintf(fid,'java %s','weka.classifiers.meta.FilteredClassifier');
fprintf(fid,' -t "%s"', trainFilename);
fprintf(fid,' -T "%s"', testFilename);
fprintf(fid,' -F "%s', 'weka.filters.MultiFilter -F \"weka.filters.unsupervised.attribute.Normalize -S 1.0 -T 0.0\" -F \"weka.filters.unsupervised.attribute.Standardize \"" -W weka.classifiers.functions.LibSVM -- -S 0 -K 2 -D 3 -G 0.0 -R 0.0 -N 0.5 -M 40.0 -C 1.0 -E 0.001 -P 0.1 -model "C:\\Program Files\\Weka-3-8" -seed 1');

% polynomial kernel
fprintf(fid,'\npolynomial kernel\n');
fprintf(fid,'java %s','weka.classifiers.meta.FilteredClassifier');
fprintf(fid,' -t "%s"', trainFilename);
fprintf(fid,' -T "%s"', testFilename);
fprintf(fid,' -F "%s', 'weka.filters.MultiFilter -F \"weka.filters.unsupervised.attribute.Normalize -S 1.0 -T 0.0\" -F \"weka.filters.unsupervised.attribute.Standardize \"" -W weka.classifiers.functions.LibSVM -- -S 0 -K 1 -D 3 -G 0.0 -R 0.0 -N 0.5 -M 40.0 -C 1.0 -E 0.001 -P 0.1 -model "C:\\Program Files\\Weka-3-8" -seed 1');

% linear kernel
fprintf(fid,'\nlinear kernel\n');
fprintf(fid,'java %s','weka.classifiers.meta.FilteredClassifier');
fprintf(fid,' -t "%s"', trainFilename);
fprintf(fid,' -T "%s"', testFilename);
fprintf(fid,' -F "%s', 'weka.filters.MultiFilter -F \"weka.filters.unsupervised.attribute.Normalize -S 1.0 -T 0.0\" -F \"weka.filters.unsupervised.attribute.Standardize \"" -W weka.classifiers.functions.LibSVM -- -S 0 -K 0 -D 3 -G 0.0 -R 0.0 -N 0.5 -M 40.0 -C 1.0 -E 0.001 -P 0.1 -model "C:\\Program Files\\Weka-3-8" -seed 1');


fprintf(fid,'\n\n');

end

fclose(fid);

disp('wrote cli commands done')

load handel
sound(y,Fs)