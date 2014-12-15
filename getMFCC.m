function [mfcc]=getMFCC(wavname,nrOfCoeffs,mode)

superpack;
%% get the data
if strcmp(mode,'wav')
    [y,Fs,nBits]=wavread([wavname '.wav']);
    if( max(abs(y))<=1 ), y = y * 2^15; end; 
elseif strcmp(mode,'vect')
    y=wavname(:,1);
    Fs=wavname(1,2); %default
else
    error('wrong mode selected')
end 

m = 100;
n = 256;
l = length(y);

nrOfFrames = floor((l - n) / m) + 1;

for i = 1:n
    for j = 1:nrOfFrames
        M(i, j) = y(((j - 1) * m) + i);
    end
end
%% pre-emphasize filter (Highpass) -> spectrally flatten the speech signal
 B = [1 -0.97];
 M = filter(B,1,M);
%% divide into overlapping blocks of ~20ms
% blockLength = 20e-3;  %to be adjusted
% speechLength = (length(yf)*1/Fs);  
% nrOfBlocks = floor(speechLength/blockLength);
% samplesPerBlock =  blockLength*Fs;
% nrOfOverlaps = ceil(nrOfBlocks/3);
% sPerBlock=floor(length(yf)/nrOfBlocks);
% 
% sampleMtx=zeros(sPerBlock+1+2*nrOfOverlaps,nrOfBlocks-1);
% for i=1:nrOfBlocks-2
%     sampleMtx(:,i)= yf(i*sPerBlock-nrOfOverlaps:(i+1)*sPerBlock+nrOfOverlaps)';
% end

%% alternative division into overlapping blocks
% blockLength = 25e-3;  %to be adjusted
% overlapLength = 10e-3;
% speechLength = (length(yf)*1/Fs);  
% nrOfBlocks = floor(speechLength/(blockLength-overlapLength));
% samplesPerBlock =  floor(blockLength*Fs);
% nrOfOverlaps = ceil(nrOfBlocks/(blockLength/overlapLength));
% % sPerBlock=floor(length(yf)/nrOfBlocks);
% 
% sampleMtx = zeros(samplesPerBlock,nrOfBlocks);
% for i=1:nrOfBlocks-1
%     sampleMtx(:,i) = yf((i-1)*floor((blockLength-overlapLength)*Fs)+1:(i-1)*floor((blockLength-overlapLength)*Fs)+samplesPerBlock)';
% end
 sampleMtx=M;
%% windowing (weight every block with hamming window)
window=hamming(length(sampleMtx(:,1)));
sampleMtxW=diag(window)*sampleMtx;

%% DFT for each block
% nrOfPoints = 2^nextpow2(length(sampleMtxW(:,1)));
% fft_temp = (abs(fft(sampleMtxW,nrOfPoints))).^2;
% sampleMtxFFT = fft_temp(1:nrOfPoints/2+1,:);
% nrOfPoints=nrOfPoints/2+1;
for i = 1:nrOfFrames
    sampleMtxFFT(:,i) = fft(sampleMtxW(:, i));
end
%% Calculate Mel frequency filter coeffs
n2 = 1 + floor(length(sampleMtxFFT(:,1)) / 2);
%[coeffs2, f]= melfiltercoeff(n2,Fs,mel2hz,hz2mel);
t = n / 2;
tmax = l / Fs;
coeffs = melfiltercoeff(20, n, Fs);
n2 = 1 + floor(n / 2);
%plot(linspace(0, (Fs/2), n/2+1), coeffs'),
%% Filter Spectra with Filterbank
sampleMtxFFTMel=coeffs * abs(sampleMtxFFT(1:n2, :)).^2;

%% Take the Log
sampleMtxFFTMelLog=log(sampleMtxFFTMel);

%% DCT - Discrete Cosine Transform                       
nrOfMelCoeffs=nrOfCoeffs;  
MtxDCT=dctm(nrOfMelCoeffs,20);
%temp =  MtxDCT * (sampleMtxFFTMelLog);
mfcc= dct((sampleMtxFFTMelLog));

%lifter = ceplifter( nrOfMelCoeffs-1, 22 );
%mfcc = diag( lifter ) * mfcc;
