%% k-svd
function[D,X]= KSVD(Y,D,X)
[n,m] = size(D);
for k = 1:m
    
    EK = Y - D*X + D(:,k)*X(k,:);
    L = find(not(X(k,:) == 0));
    
%     XKR = X(k,L);
    EKR = EK(:,L);
%     YR = Y(:,L);
    
    [U,S,V] = svd(EKR);
    
    D(:,k) = U(:,1);
    XKR = (V(:,1)'*S(1,1));
    X(k,L) = XKR;
    %if k == 415
     %   r = 1;
    %end
    
    
    
end
end
