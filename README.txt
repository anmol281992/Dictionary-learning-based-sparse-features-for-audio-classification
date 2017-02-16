The main script is:
    main_5_10_learn_dictionary_train_features.m

It requires the audio files for class 1 or 2 to be in the folders:
    dataset3/strings_all
    dataset3/percussion_all
    You need to unzip dataset3.zip before running the code. In the github file I have not added the database due to lack of space.

We assume the audio files have an '.aiff' extension. Otherwise the functions have to be changed to check different file extensions.

-----
To run multiple trials, the main file is:
    main_5_10_loop.m
- Specify the number of iterations nIter.

To write the weka cli commands, use the main_5_11_write_weka.m script.
- Specify k_omp and nIter.


-----
To compute MFCC data for WEKA:
1) run 'creating_mfcc_data_set.m' twice to get features for both classes. (need to modify one line)
2) run 'feature_to_arff_mfcc.m' to get ARFF files.
3) Load data in weka explorer, standardize, use LibSVM, etc.