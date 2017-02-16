function [ak, xTk] = codebook_update_column(Y,A,X,k)
%__________________________________________________________________________
%   Inputs
%   -----------------------------------------------------------------------
%   Y : n x m matrix    Input signal matrix
%   A : n x l matrix    Dictionary
%   X : l x m matrix    Sparse coefficient matrix
%   k : integer         Which dictionary element to update
%   
%   Outputs
%   -----------------------------------------------------------------------
%   ak : n x 1 vector   Updated dictionary element k
%   xTk : 1 x m vector  Updated coefficient vector for dictionary atom k
%                         (k-th row of X)
%__________________________________________________________________________

% length n   signals
% m          number of signals
% l          dictionary atoms

[n,m] = size(Y);
% [~,l] = size(A);
% [l,m] = size(X);

if ~any( X(k,:) )  % If the row is all zero, don't do anything!!
    ak = A(:,k);
    xTk = X(k,:);
    return
end

%--------------------------------------------------------------------------
% Compute the overall representation error matrix:
%   E = Y - sum_{j~=k} dj * x_T^j
E = Y - A*X + repmat( A(:,k), [1 m] ) .* repmat( X(k,:), [n 1] );

%--------------------------------------------------------------------------
% In the end, we output a new dictionary atom A(:,k). But the corresponding
% row X(k,:) in the coefficient matrix must also be updated because of
% their dependence on the dictionary atoms.
%
% The paper notes, naively using SVD to get the new atom and coefficients
% will not guarantee that the row of coefficients is sparse.
%
% Make a matrix operator OM that when right-multiplied, will transform the 
% matrix to keep only the columns which use the atom A(:,k). This will 
% force the new x_T to have the same support as the original x_T.
%
% Doing SVD on the transformed matrices ensures that the sparsity stays the
% same or decreases. This is only for the sake of 
%--------------------------------------------------------------------------

% % The k-th row of X indicates which signals use the dictionary atom A(:,k).
% om = find(X(k,:));   % ~= 0;                     
% num_nz = nnz(om);    % Number of times atom k is used.
% 
% OM = zeros(m, num_nz);  % The matrix which shrinks.  % Size:  m x num_nz
% OM( (0:m:((num_nz-1)*m)) + om ) = 1;  % Set index (om(i),i) to 1.
% 
% % for i = 1:num_nz
% %     OM(om(i),i) = 1;   
% % end
% 
% [U,S,V] = svd(E*OM);      % Perform SVD on the shrunken matrix.

%--------------------------------------------------------------------------

om = X(k,:) ~= 0;
[U,S,V] = svd( E(:,om) );  % Perform SVD on the shrunken matrix.
                                  % Keep only the columns which are used.   

%--------------------------------------------------------------------------
% Set the new dictionary atom to be the first column of U.
ak = U(:,1);     % Size:  n x 1   

% Set the coefficients to be the first column of V, times S(1,1).
%   But it is a row vector of length num_nz, so fix it.
%   xTk_t = S(1) * V(:,1);  % Size:  num_nz x 1
xTk = zeros(1,m);
xTk(om) = S(1,1) * V(:,1)';   % Fill in the indices which were nonzero before!
end