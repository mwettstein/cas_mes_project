fs = 48000;
depth = 24;

%% Record 3 seconds
rec = audiorecorder(fs,depth,1);

disp('Start speaking.')
recordblocking(rec, 3);
disp('End of Recording.');
%% Extract and plot audio file
recdata = getaudiodata(rec);
plot(length(recdata)/fs,recdata)

%% save audiofile
audiowrite('testinterval.wav',recdata,fs)