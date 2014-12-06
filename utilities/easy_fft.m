function [ out_data ] = easy_fft( in_data, fs )
%EASY_FFT - quick & easy fft plot for dummies
%   Detailed explanation goes here

% Solve problem with mismatching lengths of x-axes between subplots!

nrOfPoints=2^nextpow2(length(in_data));
out_data=fft(in_data,nrOfPoints)/length(in_data);
f=fs/2*linspace(0,1,nrOfPoints/2+1);
%plot
figure('units','normalized','outerposition',[0 0 1 1]);
%% Subplot 1 - Time domain speech signal
subplot(3,1,1)
plot(1/fs*(1:length(in_data)),in_data)
title('time domain','FontSize',12)
xlabel('time[s]')
ylabel('y(t)')

%% Subplot 2 - Spectrogram of speech signal
subplot(3,1,2)
spectrogram(in_data, 256, 250, 256, fs, 'yaxis');
title('Spectrogram','FontSize',12);

%% Subplot 3 - FFT of speech signal
subplot(3,1,3)
plot(f,2*abs(out_data(1:nrOfPoints/2+1)))
%mark maximum
[my,ix]=find(abs(out_data(1:nrOfPoints/2+1))==max(abs(out_data(1:nrOfPoints/2+1))));
line(f(ix),2*abs(out_data(ix)),...
          'marker','s',...
          'markerfacecolor',[0,0,0],...
          'linestyle','none');   
text(f(ix)+1/40*f(length(f)),2*abs(out_data(ix)),[num2cell(f(ix)) ' Hz'],...
     'horizontalalignment','center',...
          'fontsize',12); 
        title('frequency domain','FontSize',12)
xlabel('frequency[Hz]')
ylabel('|Y(f)|')
end

