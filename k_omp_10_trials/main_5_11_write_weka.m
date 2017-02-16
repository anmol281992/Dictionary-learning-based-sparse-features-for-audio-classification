k_omp = 10;

% Write Weka CLI commands
fid = fopen('weka_test.txt','w');

whichSet = cell(1,2);
whichSet{1} = 'train';
whichSet{2} = 'test';

feature_name = cell(1,2);
feature_name{1} = 'X_max_pool';
feature_name{2} = 'X_avg_pool';

for iter = 1:1
for j = 1:2           % for each feature name

trainFilename = [pwd '\' num2str(iter) 'features_train_' feature_name{j} '_clean.arff'];
testFilename = [pwd '\' num2str(iter) 'features_test_' feature_name{j} '_clean.arff'];
    
fprintf(fid,'\n');
fprintf(fid,[feature_name{j}]);
fprintf(fid,'\n');
% fprintf(fid,'%s','java weka.classifiers.functions.LibSVM -S 0 -K 2 -D 3 -G 0.0 -R 0.0 -N 0.5 -M 40.0 -C 1.0 -E 0.001 -P 0.1 -model "C:\\Program Files\\Weka-3-8" -seed 1');


% radial basis kernel
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
end
fclose(fid);

disp('wrote cli commands done')