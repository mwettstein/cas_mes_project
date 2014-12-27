function [mfcc]=getMFCC(wavname,nrOfCoeffs,mode)

superpack;
%% get the data
if strcmp(mode,'wav')
    [y,Fs]=audioread([wavname '.wav']);
 %   if( max(abs(y))<=1 ), y = y * 2^15; end; 
elseif strcmp(mode,'vect')
    y=wavname(:,1);
    if length(wavname(1,:)) == 2
        Fs=wavname(1,2); %default
    else
        Fs=48000; %how to deal with different formates?
    end
    %plot(1/Fs*(1:length(y)),y)
    %sound(y,Fs);
else
    error('wrong mode selected')
end 

%% pre-emphasize filter (Highpass) -> spectrally flatten the speech signal
  B = [1 -0.97];
%  M = filter(B,1,M);
 yf = filter(B,1,y);
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
blockLength = 35e-3;  %to be adjusted
overlapLength = 10e-3;
speechLength = (length(yf)*1/Fs);  
nrOfBlocks = floor(speechLength/(blockLength-overlapLength));
samplesPerBlock =  floor(blockLength*Fs);
nrOfOverlaps = ceil(nrOfBlocks/(blockLength/overlapLength));
% sPerBlock=floor(length(yf)/nrOfBlocks);

sampleMtx = zeros(samplesPerBlock,nrOfBlocks);
for i=1:nrOfBlocks-1
    sampleMtx(:,i) = yf((i-1)*floor((blockLength-overlapLength)*Fs)+1:(i-1)*floor((blockLength-overlapLength)*Fs)+samplesPerBlock)';
end
% sampleMtx=M;
%% windowing (weight every block with hamming window)
window=hamming(length(sampleMtx(:,1)));
sampleMtxW=diag(window)*sampleMtx;

%% DFT for each block
% nrOfPoints = 2^nextpow2(length(sampleMtxW(:,1)));
% fft_temp = (abs(fft(sampleMtxW,nrOfPoints))).^2;
% sampleMtxFFT = fft_temp(1:nrOfPoints/2+1,:);
% nrOfPoints=nrOfPoints/2+1;
% for i = 1:length(sampleMtxW(1,:))
    sampleMtxFFT = fft(sampleMtxW);
% end
%% Calculate Mel frequency filter coeffs

% coeffs = melfiltercoeff(24, length(sampleMtxFFT)-1, Fs);
coeffs = melfiltercoeff_old(nrOfCoeffs, length(sampleMtxFFT)-1, Fs, mel2hz, hz2mel);
% plot(linspace(0, (Fs/2), length(coeffs)), coeffs'),
%% Filter Spectra with Filterbank
sampleMtxFFTMel=coeffs * abs(sampleMtxFFT(1:length(sampleMtxFFT)-1, :)).^2;

%% Take the Log
sampleMtxFFTMelLog=log(sampleMtxFFTMel);

%% DCT - Discrete Cosine Transform                       
%nrOfMelCoeffs=nrOfCoeffs;  
%MtxDCT=dctm(nrOfMelCoeffs,20);
%temp =  MtxDCT * (sampleMtxFFTMelLog);
mfcc= dct((sampleMtxFFTMelLog));
mfcc=mfcc(2:nrOfCoeffs,:);

