%% creating arff file for mfcc_Dataset
home = pwd;
mfccdataset = 'mfcc_dataset';
classname = cell(1,2);
type{1} = 'percusion_all';
type{2} = 'strings_all';
extension = '_mfcc_feats.mat';

filename = [mfccdataset '.arff'];
fid = fopen(filename,'w');
n = 30;
fprintf(fid,['@RELATION feature_mfcc' '\n']);
fprintf(fid,'\n');
for j =1:n
    fprintf(fid,'@ATTRIBUTE %d\tNUMERIC\n', j); 
end
fprintf(fid,'\n');
fprintf(fid,'@ATTRIBUTE class \t\t {X1,X2} \n');
fprintf(fid,'@DATA\n');        
    
for i = 1:2
    
    X = load([type{i} extension]);
    data = X.featbundle;
    [n,m] = size(X.featbundle);
    %m = 2;
    %n = 10;
    for j = 1:m
        for k = 1:n
            fprintf(fid,['%e' ','],data(k,j));
        end
        fprintf(fid,['X' num2str(i) '\n']);
        %fprintf('\n');
    end
   
end
fclose(fid);