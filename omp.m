function X = omp(Y,A,s)
%__________________________________________________________________________
%   Inputs
%   -----------------------------------------------------------------------
%   Y : n x m matrix    Input signal matrix
%   A : n x l matrix    Dictionary
%   s : integer         How many non-zero coefficients to find.
%                       - will find min(s,n) coefficients.
%   
%   Outputs
%   -----------------------------------------------------------------------
%   X : l x m matrix    sparse coefficient matrix
%__________________________________________________________________________

[n,m] = size(Y);
[~,l] = size(A);
X = zeros(l,m);       % Initialize coefficient matrix X.

maxIt = min(s,n);     % Stop after finding s coefficients, or n loops.

Rf = zeros(n,maxIt);  % Matrices holding the selected bases and residuals.
Bases = zeros(n,maxIt);

for i = 1:m      % Compute, for each signal (column) in the matrix
    
    f = Y(:,i);  % The signal
    Rf0 = f;     % Initialize the residual as f
    
    
%-- Pick the first basis vector -----------------------------------------
    
    % Pick the dictionary atom that maximizes the absolute value of the
    % dot product with the residual Rf. Call it chosen_atom.
    dotProds = Rf0.' * A;
    [~, idx_max] = max( abs(dotProds) );
    chosen_atom = A(:,idx_max);
    
    Bases(:,1) = chosen_atom;         % Store the first basis vector.
    X(idx_max,i) = dotProds(idx_max); % Update the coefficient vector.
    
    % Build the current orthogonal projection operator matrix:
    %   P = A * inv(A' * A) * A.'
    %   where the orthogonal bases are stored on the columns of A.
    P = Bases(:,1) *((Bases(:,1)' * Bases(:,1)) \ Bases(:,1)');
    
    % Compute the next residual:    Rf(n+1) = Rf(n) - proj_V(n)(Rf(n))
    %                        or:    Rf(n) = f - proj_V(n)(f)
    % Rf(:,1) = Rf0 - dotProds(idx_max) * chosen_atom / ...
    %                                    (chosen_atom.' * chosen_atom);
    Rf(:,1) = f - P * f;
    
%-- Pick the other basis vectors ----------------------------------------
    
    for j = 2:maxIt
        
        % Pick the dictionary atom that maximizes the absolute value of the
        % dot product with the residual Rf. Call it chosen_atom.
        dotProds = Rf(:,j-1).' * A;
        [~, idx_max] = max( abs(dotProds) );
        chosen_atom = A(:,idx_max);
        
        % Compute the next basis vector using Gram Schmidt:
        %   v = u - proj_V(u)
        % The projection operator onto the previous set of bases was
        % computed in the previous loop.
        new_basis = chosen_atom - P * chosen_atom;
        
        Bases(:,j) = new_basis;           % Store the next basis vector.
        X(idx_max,i) = dotProds(idx_max); % Update the coefficient vector
        
        % Build the current orthogonal projection operator matrix:
        %   P = A * inv(A' * A) * A.'
        % P = Bases(:,1:j) *((Bases(:,1:j)' * Bases(:,1:j)) \ Bases(:,1:j)');
        
        % Break out of the loop if the new basis is not orthogonal...
        MTX = Bases(:,1:j)' * Bases(:,1:j);
        if MTX(end) < 1e-9
            X(idx_max,i) = 0;
            break            
        end
        P = Bases(:,1:j) *(MTX \ Bases(:,1:j)');
        
        % Compute the next residual:    Rf(n+1) = Rf(n) - proj_V(n)(Rf(n))
        %                        or:    Rf(n) = f - proj_V(n)(f)
        Rf(:,j) = f - P * f;
        % Rf(:,j) = Rf(:,j-1) - P * Rf(:,j-1);
        % Rf(:,j) = (eye(size(P))-P) * Rf(:,j-1);
        
    end
    
end
% Bases' * Bases
% surf(Rf)