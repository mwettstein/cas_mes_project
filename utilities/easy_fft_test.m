%% easy_fft test
fs=48e3;
nPoints= 1e4;
t=0:1/fs:nPoints*1/fs;
f1=3e3;
f2=4e3;
y=cos(2*pi*f1*t)+sin(2*pi*f2*t);

easy_fft(y,fs);
    