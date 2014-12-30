function [coeffs, f] = melfiltercoeff_old(nrOfTriangles,nrOfFreqPoints,fs,mel2hz, hz2mel)
% nrOfTriangles = 20;
f = linspace(0, fs/2, nrOfFreqPoints);
%voice frequency range
f_low= 300;
f_high=4000; 

%filter cutoff frequencies (Hz) for all filters, size 1x(M+2)
cutoffs = mel2hz( hz2mel(f_low)+(0:nrOfTriangles+1)*((hz2mel(f_high)-hz2mel(f_low))/(nrOfTriangles+1)) );
%%
% implements equation (6.140) in "Spoken Language Processing" [Huang] 
coeffs = zeros( nrOfTriangles, nrOfFreqPoints ); 
for i = 1:nrOfTriangles  
        fPos = f>=cutoffs(i)&f<=cutoffs(i+1); % rising slope vector: find cutoff frequency points
        coeffs(i,fPos) = (f(fPos)-cutoffs(i))/(cutoffs(i+1)-cutoffs(i));
        fPos = f>=cutoffs(i+1)&f<=cutoffs(i+2); % falling slope: find cutoff frequency points
        coeffs(i,fPos) = (cutoffs(i+2)-f(fPos))/(cutoffs(i+2)-cutoffs(i+1));
end