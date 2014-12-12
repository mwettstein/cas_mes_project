%------------------------------------------------------------------
%   __  __  ______  _____  _____   _______          _   
%  |  \/  ||  ____|/ ____|/ ____| |__   __|        | |  
%  | \  / || |__  | |    | |         | |  ___  ___ | |_ 
%  | |\/| ||  __| | |    | |         | | / _ \/ __|| __|
%  | |  | || |    | |____| |____     | ||  __/\__ \| |_ 
%  |_|  |_||_|     \_____|\_____|    |_| \___||___/ \__|
%
%-----------------------------------------------------------------

clear all; 
close all; clc; addpath('rsc', 'utilities'); superpack;
set(0,'DefaultAxesLineStyleOrder','-|-.|--|:')
%% get the data
% wavename = 'mw3';
wavename = 'fp1';
% wavename = 'yo_this_stuff_is_fresh';
[y,Fs,nBits]=wavread([wavename '.wav']);
%easy_fft(y,Fs);
sound(y,Fs);
if( max(abs(y))<=1 ), y = y * 2^15; end;
figure('units','normalized','outerposition',[0 0 1 1], 'PaperPositionMode', 'auto', ... 
              'color', 'w', 'PaperOrientation', 'landscape', 'Visible', 'on' ); 
clf;
subplot(4,2,1)
plot((1:length(y))*1/Fs,y)
xlabel( 'Time [s]' ); 
ylabel( 'Amplitude' ); 
title('Original audio sample waveform');
axis tight;

%% pre-emphasize filter (Highpass) -> spectrally flatten the speech signal
 B = [1 -0.97];
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

%% plot spectrogram
subplot(4,2,3)
spectrogram(y, 256, 250, 256, Fs/1000, 'yaxis');
axis tight;
xlabel('Time [s]');
ylabel('Frequency [kHz]');
title('Spectrogram');

%% plot windowed samples
subplot(4,2,5)
[AX, H1, H2] = plotyy(1:length(sampleMtx(:,1)),sampleMtxW, 1:length(sampleMtx(:,1)), window);
set(get(AX(2),'Ylabel'),'String','Window Amplitude');
set(AX(2),'YLim', [-1 1]);
set(AX(2),'YTick', [-1:0.5:1]);
axis tight;
xlim1 = get(AX(1),'XLim');
set(AX(2),'XLim', xlim1); 
title('Windowed Samples');
xlabel('Time [ms]');
ylabel('sample Amplitude');

%% DFT for each block
nrOfPoints = 2^nextpow2(length(sampleMtxW(:,1)));
% sampleMtxFFT=zeros(nrOfPoints/2+1,length(sampleMtxW(1,:)));
% for i=1:length(sampleMtxW(1,:))
%     fft_temp = abs(fft(sampleMtxW(:,i), nrOfPoints)/nrOfPoints);
%     sampleMtxFFT(:,i) = fft_temp(1:nrOfPoints/2+1);
% end
% nrOfPoints=nrOfPoints/2+1; % only one-sided spectrum is used
fft_temp = abs(fft(sampleMtxW,nrOfPoints));
sampleMtxFFT = fft_temp(1:nrOfPoints/2+1,:);
nrOfPoints=nrOfPoints/2+1;

subplot(4,2,7)
plot(linspace(0,Fs/2,nrOfPoints)/1000, sampleMtxFFT);%linspace(0,Fs/2,nrOfPoints),
grid on;
title('Single sided spectra of input Samples');
xt = get(gca,'XTick');
xlabel('Frequency [kHz]');
ylabel('Amplitude');


%% Calculate Mel frequency filter coeffs
[coeffs, f]= melfiltercoeff(nrOfPoints,Fs,mel2hz,hz2mel);
subplot(4,2,2)
plot(f/1000,coeffs);
title('Mel scaled triangle filterbank');
xlabel('Frequency [kHz]');
ylabel('Factor');

%% Filter Spectra with Filterbank
sampleMtxFFTMel=coeffs * sampleMtxFFT;
subplot(4,2,4)
plot(sampleMtxFFTMel);
xlabel( '"Triangle" index' ); 
ylabel( 'Energy' ); 
title('Filterbank Energies (Spectra after Filter)');

%% Take the Log
sampleMtxFFTMelLog=log(sampleMtxFFTMel);
subplot(4,2,6)
plot(sampleMtxFFTMelLog);
xlabel( '"Triangle" index' ); 
ylabel( 'log scaled energy' ); 
title( 'log scaled filterbank energies');

%% DCT - Discrete Cosine Transform                       
nrOfMelCoeffs=14;  
MtxDCT=dctm(nrOfMelCoeffs,20);
temp =  MtxDCT * (sampleMtxFFTMelLog);
%temp = dct(log(sampleMtxFFTMel),nrOfMelCoeffs)
result = temp(2:14,:);
subplot(4,2,8)
imagesc( 1/Fs*(1:(length(y))), [2:14], result ); 
xlabel( 'Time [s]' ); 
ylabel( 'Cepstrum index' );
title('Mel frequency cepstrum');

%% Grid-plot of Mel coefficients (???)
[xq,yq] = meshgrid(0:0.05:13, 0:0.05:25);
result_ip = interp2(result,xq,yq);
figure(2)
clf;
gca = mesh(result_ip.');
grid on;
title('Mel Coefficients');
axis tight;

% saveas(1,[pwd '\' wavename],'png');

%% Vector Quantisation
[idx,ctrs1] = kmeans(result', 13, 'Replicates',5);
figure(3);
clf;
plot(ctrs1(:,1),ctrs1(:,2),'kx','MarkerSize',12,'LineWidth',2);
grid on;
axis([-5 5 -1 2]);
title('Vector quantized squared euclidian distances');
xlabel('');
ylabel('');

saveas(3, [pwd '\' wavename '_VC'], 'png');
 
%  subplot(3,1,2) 
%  [idx,ctrs2] = kmeans(B',13,...
%                     'Replicates',5);
%  plot(ctrs2(:,1),ctrs2(:,2),'kx','MarkerSize',12,'LineWidth',2)
%  axis([-5 5 -1 2])
%  subplot(3,1,3)
%  [idx,ctrs3] = kmeans(C',13,...
%                     'Replicates',5);  
%  plot(ctrs3(:,1),ctrs3(:,2),'kx','MarkerSize',12,'LineWidth',2)
%  axis([-5 5 -1 2])
