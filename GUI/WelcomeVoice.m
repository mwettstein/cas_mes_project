function varargout = WelcomeVoice(varargin)
% WELCOMEVOICE MATLAB code for WelcomeVoice.fig
%      WELCOMEVOICE, by itself, creates a new WELCOMEVOICE or raises the existing
%      singleton*.
%
%      H = WELCOMEVOICE returns the handle to a new WELCOMEVOICE or the handle to
%      the existing singleton*.
%
%      WELCOMEVOICE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in WELCOMEVOICE.M with the given input arguments.
%
%      WELCOMEVOICE('Property','Value',...) creates a new WELCOMEVOICE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before WelcomeVoice_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to WelcomeVoice_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help WelcomeVoice

% Last Modified by GUIDE v2.5 12-Dec-2014 08:49:21

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @WelcomeVoice_OpeningFcn, ...
                   'gui_OutputFcn',  @WelcomeVoice_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% --- Executes just before WelcomeVoice is made visible.
function WelcomeVoice_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to WelcomeVoice (see VARARGIN)

% Choose default command line output for WelcomeVoice
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes WelcomeVoice wait for user response (see UIRESUME)
% uiwait(handles.figure1);
addpath('../rsc', '../utilities', '../');
global allusers; 
global nrOfMfccCoeffs;
nrOfMfccCoeffs = 96;
if exist('users.mat', 'file') == 2 
    load('users.mat');
    allusers = users;
end;
generateCodebook('kmeans');

% --- Outputs from this function are returned to the command line.
function varargout = WelcomeVoice_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in checkAut.
function checkAut_Callback(hObject, eventdata, handles)
% hObject    handle to checkAut (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global allusers

% nrOfMfccCoeffs = 128;
distinction_limit = 1.5;

fs = 48000;
depth = 24;
rec = audiorecorder(fs,depth,1);
%% Record 3 seconds
set(handles.commands, 'String', 'Start speaking')
recordblocking(rec, 3);
set(handles.commands, 'String', 'End of Recording')
%% Extract and plot audio file
recdata = getaudiodata(rec);
recdata = recdata/max(abs(recdata));            % normalize audio
subplot(3,2,2)
plot(1/fs*(1:length(recdata)),recdata);
subplot(3,2,4)
spectrogram(recdata, 512, 64, 256, fs/1000, 'yaxis');
axis tight;
xlabel('Time [ms]');
ylabel('Frequency [kHz]');
title('Spectrogram');
username = searchUser(recdata, allusers, distinction_limit);
if(strcmp(username, 'error'))
    set(handles.commands, 'String', 'No user found!');
else
    set(handles.commands, 'String', ['User ' username ' recognized']);
end
% subplot(3,1,2)
% spectrogram(recdata, 256, 250, 256, fs/1000, 'yaxis');


function commands_Callback(hObject, eventdata, handles)
% hObject    handle to commands (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of commands as text
%        str2double(get(hObject,'String')) returns contents of commands as a double

% --- Executes during object creation, after setting all properties.
function commands_CreateFcn(hObject, eventdata, handles)
% hObject    handle to commands (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
%new

% --- Executes on button press in gotoUserAdmin.
function gotoUserAdmin_Callback(hObject, eventdata, handles)
% hObject    handle to gotoUserAdmin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global state
state = 'locked';
UserAdmin;
