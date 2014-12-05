%------------------------------------------------------------------
%  __  __  ______  _____  _____   _______          _   
%  |  \/  ||  ____|/ ____|/ ____| |__   __|        | |  
%  | \  / || |__  | |    | |         | |  ___  ___ | |_ 
%  | |\/| ||  __| | |    | |         | | / _ \/ __|| __|
%  | |  | || |    | |____| |____     | ||  __/\__ \| |_ 
%  |_|  |_||_|     \_____|\_____|    |_| \___||___/ \__|
%
%-----------------------------------------------------------------
clear all; close all; clc; addpath('rsc', 'utilities');

%% get the data 
[y,Fs,nBits]=wavread('goodbye.wav');
easy_fft(y,Fs);
sound(y,Fs);

%% pre-emphasize filter (Highpass) -> spectrally flatten the speech signal
 B = [1 -0.95];
 yf = filter(B,1,y);

%% divide into overlapping blocks of ~20ms
blockLength = 20e-3;  %to be adjusted
speechLength = (length(yf)*1/Fs);  
nrOfBlocks = floor(speechLength/blockLength);
samplesPerBlock =  blockLength*Fs;
nrOfOverlaps = ceil(nrOfBlocks/3);
sPerBlock=floor(length(y)/nrOfBlocks);

sampleMtx=zeros(sPerBlock+1+2*nrOfOverlaps,nrOfBlocks-1);
for i=1:nrOfBlocks-1
    sampleMtx(:,i)= yf(i*sPerBlock-nrOfOverlaps:(i+1)*sPerBlock+nrOfOverlaps)';
end

%% windowing (wight every block with hamming window)
window=hamming(length(sampleMtx(:,1)));
sampleMtxW =diag(window)*sampleMtx;

%% calculate  Mel Frequency Cepstrum Coefficients 
% rceps = real(ifft(log(abs(fft(x)))));
%mfccMtx=ones(length(sampleMtxW),length(sampleMtxW(1,:))) %preallocate MFCC Matrix
for i=1:length(sampleMtxW(1,:))
    mfccMtx(:,i)= rceps(sampleMtxW(:,i));
end
