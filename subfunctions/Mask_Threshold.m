function varargout = Mask_Threshold(varargin)
%Run as bwMask_thresh = Mask_Threshold(Movie_sum,first_image,bwMask) 
%MASK_THRESHOLD MATLAB code for Mask_Threshold.fig
%      MASK_THRESHOLD, by itself, creates a new MASK_THRESHOLD or raises the existing
%      singleton*.
%
%      H = MASK_THRESHOLD returns the handle to a new MASK_THRESHOLD or the handle to
%      the existing singleton*.
%
%      MASK_THRESHOLD('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MASK_THRESHOLD.M with the given input arguments.
%
%      MASK_THRESHOLD('Property','Value',...) creates a new MASK_THRESHOLD or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Mask_Threshold_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Mask_Threshold_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Mask_Threshold

% Last Modified by GUIDE v2.5 07-Jun-2016 16:13:36

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Mask_Threshold_OpeningFcn, ...
                   'gui_OutputFcn',  @Mask_Threshold_OutputFcn, ...
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


% --- Executes just before Mask_Threshold is made visible.
function Mask_Threshold_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Mask_Threshold (see VARARGIN)

% Choose default command line output for Mask_Threshold
handles.output = hObject;
handles.Movie_sum = varargin{1};
handles.first_image = varargin{2};
handles.bwMask = varargin{3};
handles.thresh = 0;
axes(handles.axes1);
imshow(immultiply(handles.first_image,handles.bwMask));
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Mask_Threshold wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Mask_Threshold_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
uiwait;
bwMask_thresh = handles.bwMask;
thresh = get(handles.slider1, 'Value');
bwMask_thresh(handles.Movie_sum<=(thresh*max(max(handles.Movie_sum)))) = 0;
varargout{1} = bwMask_thresh;


% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
thresh = get(hObject,'Value')
bwMask_thresh = handles.bwMask;
%ind = find(handles.Movie_sum<handles.thresh);
%size(ind)
bwMask_thresh(handles.Movie_sum<=(thresh*max(max(handles.Movie_sum)))) = 0;
axes(handles.axes1);
imshow(immultiply(handles.first_image,bwMask_thresh));

% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

uiresume;
