function varargout = UserAdmin(varargin)
% USERADMIN MATLAB code for UserAdmin.fig
%      USERADMIN, by itself, creates a new USERADMIN or raises the existing
%      singleton*.
%
%      H = USERADMIN returns the handle to a new USERADMIN or the handle to
%      the existing singleton*.
%
%      USERADMIN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in USERADMIN.M with the given input arguments.
%
%      USERADMIN('Property','Value',...) creates a new USERADMIN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before UserAdmin_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to UserAdmin_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help UserAdmin

% Last Modified by GUIDE v2.5 19-Dec-2014 14:39:39

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @UserAdmin_OpeningFcn, ...
    'gui_OutputFcn',  @UserAdmin_OutputFcn, ...
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

% --- Executes just before UserAdmin is made visible.
function UserAdmin_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to UserAdmin (see VARARGIN)

% Choose default command line output for UserAdmin
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes UserAdmin wait for user response (see UIRESUME)
% uiwait(handles.figure1);

if exist('users.mat', 'file') == 2 
    load('users.mat');
else
    users.user0.name = 'Dummy';
    users.user0.autorisation = false;
    users.user0.sample = sign(sin(0:0.1:50));
    users.user0.characteristics = [1,2,3,4,5,6,7,8,9,10,11,12,13,14];
    %save('users.mat','users');
end;

global allusers;
global state;
allusers = users;

if strcmp( state, 'unlocked')
    set(handles.commands, 'String', '++ unlocked ++')
    state = 'unlocked';
    set(handles.editable,'string','');
    
    fields = fieldnames(allusers);
    outstring = '';
    for i=1:numel(fields)
        outstring = strvcat(outstring, allusers.(fields{i}).name);
    end
    set(handles.listbox2,'String',outstring);
else
    set(handles.commands, 'String', '-- locked --')
    set(handles.editable, 'String', '')
    set(handles.listbox2,'String','');
    state = 'locked';
end

% --- Outputs from this function are returned to the command line.
function varargout = UserAdmin_OutputFcn(hObject, eventdata, handles) 
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
if (strcmp(get(handles.editable,'string'), '123')) | strcmp( state, 'unlocked')
    set(handles.commands, 'String', '++ unlocked ++')
    state = 'unlocked';
    set(handles.editable,'string','');
    
    fields = fieldnames(allusers);
    outstring = '';
    for i=1:numel(fields)
        outstring = strvcat(outstring, allusers.(fields{i}).name);
    end
    set(handles.listbox2,'String',outstring);
else
    set(handles.commands, 'String', 'Enter Autentification')
    pause(1)
    set(handles.commands, 'String', '-- locked --')
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
global allusers
global state
% hObject    handle to delUser (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if strcmp( state, 'unlocked')
    index_selected = get(handles.listbox2,'Value');
    fields = fieldnames(allusers);
    allusers = rmfield(allusers,  fields(index_selected) ); 
    users = allusers;
    save('users.mat','users');
    
    set(handles.listbox2,'Value',numel(fields)-1);
    
    fields = fieldnames(allusers);
    outstring = '';
    for i=1:numel(fields)
        outstring = strvcat(outstring, allusers.(fields{i}).name);
    end
    set(handles.listbox2,'String',outstring);
else
    set(handles.commands, 'String', 'Enter Autentification')
    pause(1)
    set(handles.commands, 'String', '-- locked --')
end
        
% --- Executes on button press in useradmin.
function addUser_Callback(hObject, eventdata, handles)
% hObject    handle to useradmin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global state
if strcmp(state, 'unlocked')
    AddUser
else
    set(handles.commands, 'String', 'Enter Autentification')
    pause(1)
    set(handles.commands, 'String', '-- locked --')
end

% --- Executes on button press in AudioIdent.
function AudioIdent_Callback(hObject, eventdata, handles)
% hObject    handle to AudioIdent (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in listbox2.
function listbox2_Callback(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox2

% --- Executes during object creation, after setting all properties.
function listbox2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
global state
state = 'locked';
delete(hObject);
