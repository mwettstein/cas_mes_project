function [recdata]= getMicSample
fs = 48000;
depth = 24;

%% Record 1.5 seconds
rec = audiorecorder(fs,depth,1);
disp('Start speaking.')
recordblocking(rec, 1.5);
disp('End of Recording.');
%% Extract and plot audio file
y = getaudiodata(rec);
recdata=zeros(length(y),2);
recdata(1,2) = fs;
recdata(:,1) = y;
% plot(1/fs*(1:length(recdata)),recdata)