function features_to_arff(savefilename,X1_feat,X2_feat)


%  savefilename : do not include .arff extension! already included.
%__________________________________________________________________________

num_features = size(X1_feat,1);

X = cell(1,2);
X{1} = X1_feat;
X{2} = X2_feat;

%__________________________________________________________________________
% Create ARFF file to record the features.
fid = fopen([savefilename '.arff'],'w');

% Name
fprintf(fid,['@RELATION ' 'features' '\n']);
fprintf(fid,'\n');

% List the attributes as numbers. (numbers 1..dictionarySize)
for i = 1:num_features
    fprintf(fid,'@ATTRIBUTE %d\tNUMERIC\n', i);
end
fprintf(fid,'\n');

fprintf(fid,'@ATTRIBUTE class \t\t {X1,X2} \n');

% Record the data.
fprintf(fid,'@DATA\n');

for class_num = 1:2

    Z = X{class_num};
    
                     % Normalize to l2-norm = 1.
    % Z = Z ./ repmat( sqrt(sum(Z.^2, 1)) , [num_features 1]); 
            % Z = normc(Z)  % normalizes the columns...
            
                     % Standardize the columns to zero mean, unit variance.
%     Z = zscore(Z,[],2);
                               
    num_signals = size(Z,2);
    for i = 1:num_signals
        for k = 1:num_features
            fprintf(fid,'%e,',Z(k,i));
        end
        fprintf(fid,['X' num2str(class_num)]);
        fprintf(fid,'\n');
    end

end
fclose(fid);