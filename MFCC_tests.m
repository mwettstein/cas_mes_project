%------------------------------------------------------------------
%  __  __  ______  _____  _____   _______          _   
%  |  \/  ||  ____|/ ____|/ ____| |__   __|        | |  
%  | \  / || |__  | |    | |         | |  ___  ___ | |_ 
%  | |\/| ||  __| | |    | |         | | / _ \/ __|| __|
%  | |  | || |    | |____| |____     | ||  __/\__ \| |_ 
%  |_|  |_||_|     \_____|\_____|    |_| \___||___/ \__|
%
%-----------------------------------------------------------------
clear all; close all; clc; addpath('rsc', 'utilities'); superpack;

%% get the data 
% [y,Fs,nBits]=wavread('goodbye.wav');
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
for i=1:nrOfBlocks-2
    sampleMtx(:,i)= yf(i*sPerBlock-nrOfOverlaps:(i+1)*sPerBlock+nrOfOverlaps)';
end

%% windowing (weight every block with hamming window)
window=hamming(length(sampleMtx(:,1)));
sampleMtxW=diag(window)*sampleMtx;

%% plot windowed samples
figure(2)
clf;
[AX, H1, H2] = plotyy(1:length(sampleMtx(:,1)),sampleMtxW, 1:length(sampleMtx(:,1)), window);
set(get(AX(2),'Ylabel'),'String','Window Amplitude');
set(AX(2),'YLim', [-1 1]);
set(AX(2),'YTick', [-1:0.5:1]);
title('Windowed Samples');
xlabel('Time [s]');
ylabel('Sample Amplitude');

%% DFT for each block
nrOfPoints = 2^nextpow2(length(sampleMtxW(:,1)));
sampleMtxFFT=zeros(nrOfPoints/2+1,length(sampleMtxW(1,:)));
for i=1:length(sampleMtxW(1,:))
    fft_temp = 2*abs(fft(sampleMtxW(:,i), nrOfPoints)/nrOfPoints);
    sampleMtxFFT(:,i) = fft_temp(1:nrOfPoints/2+1);
end
nrOfPoints=nrOfPoints/2+1; % only one-sided spectrum is used

figure(3)
clf;
plot(linspace(0,Fs/2,nrOfPoints), sampleMtxFFT);
grid on;
title('Double sided spectras of input Samples');
xlabel('F');
ylabel('Amplitude');

%% Calculate Mel frequency filter coeffs
[coeffs, f]= melfiltercoeff(nrOfPoints,Fs,mel2hz,hz2mel);
figure(4)
clf;
plot(f,coeffs);
title('Mel filter coefficients');
xlabel('frequency [Hz]');
ylabel('Factor');
%% Filter 
sampleMtxFFTMel=coeffs() * sampleMtxFFT;
%%                        
nrOfMelCoeffs=14;  
MtxDCT=dctm(nrOfMelCoeffs,25);
temp =  MtxDCT * log(sampleMtxFFTMel);
result = temp(2:14,:);
%% Grid-plot of Mel coefficients (???)
[xq,yq] = meshgrid(0:0.1:13, 0:0.1:25);
result_ip = interp2(result,xq,yq);
% griddata(result);
figure(5)
clf;
gca = mesh(result_ip.');
colormap(jet);
% set(gca, 'LineStyle', 'none');
grid on;
title('Mel Coefficients');
axis tight;

%% Reserve
%mfccMtx=ones(length(sampleMtxW),length(sampleMtxW(1,:))) %preallocate MFCC Matrix
% for i=1:length(sampleMtxW(1,:))
%     mfccMtx(:,i)= rceps(sampleMtxW(:,i));
% end
