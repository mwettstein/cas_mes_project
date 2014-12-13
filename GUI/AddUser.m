function varargout = AddUser(varargin)
% ADDUSER MATLAB code for AddUser.fig
%      ADDUSER, by itself, creates a new ADDUSER or raises the existing
%      singleton*.
%
%      H = ADDUSER returns the handle to a new ADDUSER or the handle to
%      the existing singleton*.
%
%      ADDUSER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ADDUSER.M with the given input arguments.
%
%      ADDUSER('Property','Value',...) creates a new ADDUSER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before AddUser_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to AddUser_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help AddUser

% Last Modified by GUIDE v2.5 12-Dec-2014 16:57:14

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @AddUser_OpeningFcn, ...
                   'gui_OutputFcn',  @AddUser_OutputFcn, ...
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


% --- Executes just before AddUser is made visible.
function AddUser_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to AddUser (see VARARGIN)

% Choose default command line output for AddUser
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes AddUser wait for user response (see UIRESUME)
% uiwait(handles.figure1);
if exist('users.mat', 'file') == 2 
    load('users.mat');
else
    users.user0.name = 'dummy';
    users.user0.autorisation = false;
    users.user0.sample = sign(sin(0:0.1:50));
    users.user0.characteristics = [1,2,3,4,5,6,7,8,9,10,11,12,13,14];
    save('users.mat','users');
end;

global allusers;
global state;
allusers = users;
set(handles.commands, 'String', '-- locked --')
set(handles.editable, 'String', '')
state = 'locked';




% --- Outputs from this function are returned to the command line.
function varargout = AddUser_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in enter.
function enter_Callback(hObject, eventdata, handles)
% hObject    handle to enter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global state
global allusers
if strcmp(get(handles.editable,'string'), '123')
    set(handles.commands, 'String', '++ unlocked ++')
    state = 'unlocked';
    set(handles.list,'String',allusers.user0.name);
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


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function users_Callback(hObject, eventdata, handles)
% hObject    handle to users (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of users as text
%        str2double(get(hObject,'String')) returns contents of users as a double


% --- Executes during object creation, after setting all properties.
function users_CreateFcn(hObject, eventdata, handles)
% hObject    handle to users (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editable_Callback(hObject, eventdata, handles)
% hObject    handle to editable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editable as text
%        str2double(get(hObject,'String')) returns contents of editable as a double


% --- Executes during object creation, after setting all properties.
function editable_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in delUser.
function delUser_Callback(hObject, eventdata, handles)
% hObject    handle to delUser (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in addUser.
function addUser_Callback(hObject, eventdata, handles)
% hObject    handle to addUser (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in AudioIdent.
function AudioIdent_Callback(hObject, eventdata, handles)
% hObject    handle to AudioIdent (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function list_Callback(hObject, eventdata, handles)
% hObject    handle to list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of list as text
%        str2double(get(hObject,'String')) returns contents of list as a double


% --- Executes during object creation, after setting all properties.
function list_CreateFcn(hObject, eventdata, handles)
% hObject    handle to list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
