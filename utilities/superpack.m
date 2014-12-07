% Süper-Pack
hz2mel = @(hz)(1127*log(1+hz/700)); % converts Hz to mel 
mel2hz = @(mel)(700*exp(mel/1127)-700); % converts mel to Hz
dctm = @( N, M )( sqrt(2.0/M) * cos(repmat([0:N-1].',1,M).* repmat(pi*([1:M]-0.5)/M,N,1)));% DCT Matrix Eq. 5.14