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
close all; clc; addpath('rsc', 'utilities'); superpack; format short;
set(0,'DefaultAxesLineStyleOrder','-|-.|--|:');

%% get the data
% wavename = 'mw3';
wavename = 'fpta1';
% wavename = 'yo_this_stuff_is_fresh';
[y,Fs] = audioread([wavename '.wav']);
y = y/max(abs(y));                  % normalize audio
% sound(y,Fs);
% if( max(abs(y))<=1 ), y = y * 2^15; end;
figure('units','normalized','outerposition',[0 0 1 1], 'PaperPositionMode', 'auto', ... 
              'color', 'w',...% 'PaperOrientation', 'landscape',
              'Visible', 'on' ); 
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
blockLength = 25e-3;  %to be adjusted
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

%% windowing (weight every block with hamming window)
window=hamming(length(sampleMtx(:,1)));
sampleMtxW=diag(window)*sampleMtx;

%% plot spectrogram
subplot(4,2,3)
spectrogram(y, 256, 250, 512, Fs/1000, 'yaxis');
axis tight;
xlabel('Time [ms]');
ylabel('Frequency [kHz]');
title('Spectrogram');

%% plot windowed samples
subplot(4,2,5)
plot(1000*(1:length(sampleMtx(:,1)))/Fs,sampleMtxW);
% set(get(AX(2),'Ylabel'),'String','Window Amplitude');
% set(AX(2),'YLim', [-1 1]);
% set(AX(2),'YTick', [-1:0.5:1]);
axis tight;
% xlim1 = get(AX(1),'XLim');
% set(AX(2),'XLim', xlim1); 
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
nrOfPoints=nrOfPoints/2+1;
sampleMtxFFT = fft_temp(1:nrOfPoints,:);

subplot(4,2,7)
% plot(linspace(0,Fs/2,nrOfPoints)/1000, sampleMtxFFT(:,1:10:65));%linspace(0,Fs/2,nrOfPoints),
semilogy(linspace(0,Fs/2,nrOfPoints)/1000, sampleMtxFFT(:,1:10:65));%linspace(0,Fs/2,nrOfPoints),
grid on;
title('Single sided spectra of input Samples (excerpt)');
axis tight;
xt = get(gca,'XLim');
xlabel('Frequency [kHz]');
ylabel('Amplitude');


%% Calculate Mel frequency filter coeffs
[coeffs, f]= melfiltercoeff_old(20,nrOfPoints,Fs,mel2hz,hz2mel);
% coeffs = melfiltercoeff_old(20,nrOfPoints,Fs,mel2hz,hz2mel);
subplot(4,2,2)
plot(f/1000,coeffs);
title('Mel scaled triangle filterbank');
set(gca, 'XLim', xt);
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
% temp = dct(log(sampleMtxFFTMel),nrOfMelCoeffs)
result = temp(2:14,:);
subplot(4,2,8)
imagesc( 1/Fs*(1:(length(y))), [2:14], result ); 
xlabel( 'Time [s]' ); 
ylabel( 'Cepstrum index' );
title('Mel frequency cepstrum');

%% Grid-plot of Mel coefficients
[xlim ylim] = size(result);
[xq,yq] = meshgrid(linspace(0, ylim, ylim*30), linspace(0, xlim, xlim*30));
% [xq,yq] = meshgrid(0:0.05:13, 0:0.05:25);       % generate close-mesh meshgrid for interpolation
result_ip = interp2(result,xq,yq);              % interpolate data to close-mesh meshgrid

figure(2)
clf;
mHandle = mesh(result_ip.');
view(33, 28);                                   % change POV to AZ 33 EL 28
grid on;
title('Mel Coefficients');
axis tight;

%% Vector Quantisation
result_transp = result';                        % from here on, work with transposed matrix
opts = statset('Display','off');
[idx,ctrs1,sumd,D] = kmeans(result_transp, 13, 'Distance', 'sqEuclidean', 'Replicates', 150, 'options', opts);

figure(3);
clf;
color = hsv(12);                                % generate colormap for iterative coloring in for-loop
hold on;

for i=1:12                                      % iterative plotting
    plot(result_transp(idx==i,1),result_transp(idx==i,2), '.', 'Color', color(i,:), 'MarkerSize',12);
end

plot(ctrs1(:,1),ctrs1(:,2),'kx','MarkerSize',12,'LineWidth',2);
hold off;
grid on;
axis([-5 5 -2 4]);
title('Vector quantized squared euclidian distances');
csvwrite([wavename '_sumd.csv'], sumd);

%% finishing
% saveas(1,[pwd '\pngs\' wavename],'png');
% saveas(2,[pwd '\pngs\' wavename '_mfc'], 'png');
% saveas(3,[pwd '\pngs\' wavename '_VC'],'png');

% close all;
