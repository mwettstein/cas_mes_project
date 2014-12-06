% Süper-Pack
hz2mel = @(hz)(1127*log(1+hz/700)); % converts Hz to mel 
mel2hz = @(mel)(700*exp(mel/1127)-700); % converts mel to Hz