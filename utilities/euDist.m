%% euDist Function
% euDist Pairwise Euclidean distances between columns of two matrices 
% 
% Input: 
% x, y: Two matrices whose each column is an a vector data. 
% 
% Output: 
% d: Element d(i,j) will be the Euclidean distance between two 
% column vectors X(:,i) and Y(:,j) 
% 
% Note: 
% The Euclidean distance D between two vectors X and Y is: 
% D = sum((x-y).^2).^0.5 

function d = euDist(x, y) 
[M, N] = size(x); 
[M2, P] = size(y); 
if (M ~= M2) 
error('Matrix dimensions do not match.') 
end 
d = zeros(N, P);
for ii=1:N 
    for jj=1:P 
        d(ii,jj) = wDistance(x(:,ii),y(:,jj),2); 
    end 
end
end
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------

%% wDistance function
% x and y are input 1D vectors 
% out is the measured distance 
% Euclidean distance 

function [out] = wDistance(x,y,mode) 
if mode == 0 
out = sum((x-y).^2).^0.5; 
end 
% Distance sum | x -y | 
if mode == 1 
out = sum(abs(x-y)); 
end 
% Weighted distance 
if mode == 2 
w = zeros(size(x));
w(1) = 0.20; 
w(2) = 0.90; 
w(3) = 0.95; 
w(4) = 0.90; 
w(5) = 0.70; 
w(6) = 0.90; 
w(7) = 1.00; 
w(8) = 1.00; 
w(9) = 1.00; 
w(10) = 0.95; 
w(11:13) = 0.30; 
out = sum(abs(x-y).*w); 
%out = sum(w.*(x-y).^2).^0.5; 
end
end