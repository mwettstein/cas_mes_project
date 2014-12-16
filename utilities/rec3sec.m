clear all
clc

fs = 48000;
depth = 24;

%% Record 1.5 seconds
rec = audiorecorder(fs,depth,1);
disp('Start speaking.')
recordblocking(rec, 2);
disp('End of Recording.');
%% Extract and plot audio file
recdata = getaudiodata(rec);

%% save audiofile
%audiowrite('test.wav',recdata,fs)
plot(1/fs*(1:length(recdata)),recdata)