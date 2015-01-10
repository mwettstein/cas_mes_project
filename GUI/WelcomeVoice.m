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

% Last Modified by GUIDE v2.5 23-Dec-2014 19:06:57

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
nrOfMfccCoeffs = 100;             % 100
if exist('users.mat', 'file') == 2 
    load('users.mat');
    allusers = users;
end;
% generateCodebook('kmeans');
% users = allusers;
% save('users.mat','users');

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
distinction_limit = 15;

fs = 48000;
depth = 24;
rec = audiorecorder(fs,depth,1);
%% Record 3 seconds
set(handles.textBox, 'String', 'Start speaking')
recordblocking(rec, 1.5);
set(handles.textBox, 'String', 'End of Recording')
%% Extract and plot audio file
recdata = getaudiodata(rec);
% recdata = recdata/max(abs(recdata));            % normalize audio
subplot(3,2,2)
plot(1/fs*(1:length(recdata)),recdata);
xlabel('Time [s]');
ylabel('Amplitude');
title('Speech Signal');
axis([0 1.5 -1 1]);

if(max(abs(recdata)) <= 0.2)
    set(handles.commands, 'String', 'Please speak up!', 'BackgroundColor', 'red', 'FontSize', 24, 'FontWeight', 'bold');
    return;
end

subplot(3,2,4)
spectrogram(recdata, 512, 64, 256, fs/1000, 'yaxis');
axis tight;
xlabel('Time [ms]');
ylabel('Frequency [kHz]');
title('Spectrogram');
[username, auth] = searchUser(recdata, allusers, distinction_limit, 1);
if(strcmp(username, 'error'))
    set(handles.textBox, 'String', 'No user found!');
    set(handles.commands, 'String', 'Access denied!', 'BackgroundColor', 'red', 'FontSize', 24, 'FontWeight', 'bold');
elseif(auth == 0)
    set(handles.textBox, 'String', [username ' recognized']);
    set(handles.commands, 'String', 'Access denied!', 'BackgroundColor', 'red', 'FontSize', 24, 'FontWeight', 'bold');
else
    set(handles.textBox, 'String', [username ' recognized']);
    set(handles.commands, 'String', 'Access granted!', 'BackgroundColor', 'green', 'FontSize', 24, 'FontWeight', 'bold');
    %     serialEval('run',20,'ack');
end


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



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
