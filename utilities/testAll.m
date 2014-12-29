%--------------------------------------------------------------------------
%
%  Test Ruotine
%
%
%
%
%--------------------------------------------------------------------------

%%Administrative tasks
clear all;close all;clc
addpath('../rsc', '../utilities', '../');
superpack;

nrOfMfccCoeffs = 64;

AudioProcessingSteps = figure();
totFigures = 4;
tempFigutes = 1;
%%Read or create test file
[y,Fs]=audioread(['mm1' '.wav']);
lenY = length(y);
ywhite = wgn(lenY,1,1);
subplot(totFigures,2,tempFigutes);
plot(y)
subplot(totFigures,2,tempFigutes+1);
plot(abs(fft(ywhite)))
tempFigutes = tempFigutes + 2;

%% pre-emphasize filter (Highpass) -> spectrally flatten the speech signal
B = [1 -0.97];
yf = filter(B,1,y);
yfwhite = filter(B,1,ywhite);
subplot(totFigures,2,tempFigutes);
plot(yf)
subplot(totFigures,2,tempFigutes+1);
plot(abs(fft(yfwhite)))
tempFigutes = tempFigutes + 2;

%% alternative division into overlapping blocks
blockLength = 35e-3;  %to be adjusted
overlapLength = 10e-3;
speechLength = (lenY*1/Fs);  
nrOfBlocks = floor(speechLength/(blockLength-overlapLength));
samplesPerBlock =  floor(blockLength*Fs);
nrOfOverlaps = ceil(nrOfBlocks/(blockLength/overlapLength));
sPerBlock=floor(lenY/nrOfBlocks);
 
sampleMtx = zeros(samplesPerBlock,nrOfBlocks);
sampleMtxWhite = zeros(samplesPerBlock,nrOfBlocks);
for i=1:nrOfBlocks-1
    sampleMtx(:,i) = yf((i-1)*floor((blockLength-overlapLength)*Fs)+1:(i-1)*floor((blockLength-overlapLength)*Fs)+samplesPerBlock)';
    sampleMtxWhite(:,i) = yfwhite((i-1)*floor((blockLength-overlapLength)*Fs)+1:(i-1)*floor((blockLength-overlapLength)*Fs)+samplesPerBlock)';
end

subplot(totFigures,2,tempFigutes);
plot(sampleMtx)
subplot(totFigures,2,tempFigutes+1);
plot(abs(fft(sampleMtxWhite)))
tempFigutes = tempFigutes + 2;

%% windowing (weight every block with hamming window)
window=hamming(length(sampleMtx(:,1)));
sampleMtxW=diag(window)*sampleMtx;
sampleMtxWwhite=diag(window)*sampleMtxWhite;

subplot(totFigures,2,tempFigutes);
plot(sampleMtxWwhite)
subplot(totFigures,2,tempFigutes+1);
plot(abs(fft(sampleMtxWwhite)))
tempFigutes = tempFigutes + 2;


%% DFT for each block
sampleMtxFFT = fft(sampleMtxW,2^nextpow2(length(sampleMtxW(:,1))));
nrOfTriangles = length(sampleMtxFFT) - 1;
%% Calculate Mel frequency filter coeffs
%coeffs = melfiltercoeff_old(nrOfCoeffs, length(sampleMtxFFT)-1, Fs, mel2hz, hz2mel);
f = linspace(0, Fs/2,nrOfTriangles);
%voice frequency range
f_low= 300;
f_high=4000; 
%filter cutoff frequencies (Hz) for all filters, size 1x(M+2)
cutoffs = mel2hz( hz2mel(f_low)+(0:length(sampleMtxFFT))*((hz2mel(f_high)-hz2mel(f_low))/(length(sampleMtxFFT))) );

%% implements equation (6.140) in "Spoken Language Processing" [Huang] 
coeffs = zeros(nrOfTriangles, length(sampleMtxFFT)-1 ); 
for i = 1:nrOfTriangles  
        fPos = f>=cutoffs(i)&f<=cutoffs(i+1); % rising slope vector: find cutoff frequency points
        coeffs(i,fPos) = (f(fPos)-cutoffs(i))/(cutoffs(i+1)-cutoffs(i));
        fPos = f>=cutoffs(i+1)&f<=cutoffs(i+2); % falling slope: find cutoff frequency points
        coeffs(i,fPos) = (cutoffs(i+2)-f(fPos))/(cutoffs(i+2)-cutoffs(i+1));
end
% plot(linspace(0, (Fs/2), length(coeffs)), coeffs'),

% %% Filter Spectra with Filterbank
% sampleMtxFFTMel=coeffs * abs(sampleMtxFFT(1:length(sampleMtxFFT)-1, :)).^2;
% 
% %% Take the Log
% sampleMtxFFTMelLog=log(sampleMtxFFTMel);
% 
% %% DCT - Discrete Cosine Transform                       
% %nrOfMelCoeffs=nrOfCoeffs;  
% %MtxDCT=dctm(nrOfMelCoeffs,20);
% %temp =  MtxDCT * (sampleMtxFFTMelLog);
% mfcc= dct((sampleMtxFFTMelLog));
% mfcc=mfcc(2:nrOfCoeffs,:);