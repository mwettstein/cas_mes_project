function [coeffs] = melfiltercoeff(nrOfTriangles, nrOfPoints,fs)

%

f_low = 700 / fs;
fn2 = floor(nrOfPoints/2);

lr = log(1 + 0.5/f_low) / (nrOfTriangles+1);

% convert to fft bin numbers with 0 for DC term
bl = nrOfPoints * (f_low * (exp([0 1 nrOfTriangles nrOfTriangles+1] * lr) - 1));

b1 = floor(bl(1)) + 1;
b2 = ceil(bl(2));
b3 = floor(bl(3));
b4 = min(fn2, ceil(bl(4))) - 1;

pf = log(1 + (b1:b4)/nrOfPoints/f_low) / lr;
fp = floor(pf);
pm = pf - fp;

r = [fp(b2:b4) 1+fp(1:b3)];
c = [b2:b4 1:b3] + 1;
v = 2 * [1-pm(b2:b4) pm(1:b3)];

coeffs = sparse(r, c, v, nrOfTriangles, 1+fn2);