function varargout = dehaze(varargin)
% DEHAZE MATLAB code for dehaze.fig
%      DEHAZE, by itself, creates a new DEHAZE or raises the existing
%      singleton*.
%
%      H = DEHAZE returns the handle to a new DEHAZE or the handle to
%      the existing singleton*.
%
%      DEHAZE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DEHAZE.M with the given input arguments.
%
%      DEHAZE('Property','Value',...) creates a new DEHAZE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before dehaze_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to dehaze_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help dehaze

% Last Modified by GUIDE v2.5 25-Sep-2017 16:08:32

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @dehaze_OpeningFcn, ...
                   'gui_OutputFcn',  @dehaze_OutputFcn, ...
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


function dehaze_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

path(path,strcat(pwd,'\WDC dehazing'));
axes(handles.axes1);axis off;
axes(handles.axes2);axis off;
axes(handles.axes3);axis off;
axes(handles.axes4);axis off;
global image btdown brushFlag;
image = []; btdown = 0; brushFlag = -1;
set(handles.figure1,'pointer','arrow');

function varargout = dehaze_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;

function bt_file_Callback(hObject, eventdata, handles)
    global image imageWB atmColor transMap clue_map lowerBound brushFlag redMask blueMask weightGain;
    % reset
    set(handles.figure1,'pointer','arrow');brushFlag = -1; 
    transMap = [];
    % GUI read image
    [filename,pathname]=uigetfile({'*.*'},'choose an image');
    if isequal(filename,0), disp('Users Selected Canceled'); end    
    str=[pathname filename];
    image = im2double(imread(str)); 
    [m,n,~] = size(image); scale = 640/max(m,n);
    image = imresize(image,scale);    
    axes(handles.axes1); imshow(image); axis off;
    cla(handles.axes2); cla(handles.axes3); cla(handles.axes4);
    % pre-process
    atmColor = wdc_airLight(image);
    imageWB = wdc_whiteImage(image,atmColor);
    clue_map = 1 - wdc_dx(imageWB,2,ceil(0.05*min(size(imageWB,1),size(imageWB,2))));
    weightGain = ones(size(image,1),size(image,2));
    lowerBound = 1 - wdc_dx(imageWB,1);
    redMask = zeros(size(image,1),size(image,2));
    blueMask = zeros(size(image,1),size(image,2));
    
function bt_dehaze_Callback(hObject, eventdata, handles)
    global image imageWB atmColor transMap lowerBound clue_map brushFlag redMask blueMask weightGain;
    set(handles.figure1,'pointer','arrow');brushFlag = -1;
    if isempty(image), return; end
    % dehazing process  
    if isempty(transMap)
        weight = 1./max( (lowerBound-clue_map).^2,0.001)/1000;
        transMap = wls_optimization(clue_map, weight, imageWB, 0.02);
    else
        clue_map(blueMask==1)=median(transMap(redMask==1));
        weightGain(blueMask==1)=2;
        weight = 1./max( (lowerBound-clue_map).^2,0.001)/1000;
        weight = weight.*weightGain;
        transMap = wls_optimization(clue_map, weight, imageWB, 0.02);     
    end 
    haze_factor = 1.1;
    Tc = (max(lowerBound,transMap) + (haze_factor-1) )/haze_factor;
    
    J = wdc_radiance(image,max(0.0,Tc),atmColor);
    % display  
    axes(handles.axes1); imshow(image);axis off;
    axes(handles.axes2); imshow(J.^0.9);axis off;
    axes(handles.axes3); imshow(transMap);colormap(jet);axis off;
    axes(handles.axes4); imshow(clue_map); colormap(jet); axis off;
    % clear
    redMask = zeros(size(redMask,1),size(redMask,2));
    blueMask = zeros(size(blueMask,1),size(blueMask,2));
    
function bt_clear_Callback(hObject, eventdata, handles)
    global image brushFlag redMask blueMask;
    set(handles.figure1,'pointer','arrow');brushFlag = -1;
    redMask = zeros(size(redMask,1),size(redMask,2));
    blueMask = zeros(size(blueMask,1),size(blueMask,2));
    if ~isempty(image), axes(handles.axes1); imshow(image); axis off; end

function bt_reset_Callback(hObject, eventdata, handles)
    global image imageWB clue_map brushFlag redMask blueMask weightGain;
    set(handles.figure1,'pointer','arrow');brushFlag = -1;
    if ~isempty(image)         
        clue_map = 1 - wdc_dx(imageWB,2,ceil(0.05*min(size(imageWB,1),size(imageWB,2))));
        weightGain = ones(size(image,1),size(image,2));
        redMask = zeros(size(image,1),size(image,2));
        blueMask = zeros(size(image,1),size(image,2));
        axes(handles.axes1); imshow(image); axis off;
        cla(handles.axes2); cla(handles.axes3); cla(handles.axes4);
    end
    
function bt_ref_Callback(hObject, eventdata, handles)
    global image brushFlag
    brushFlag = 0;
    if ~isempty(image), set(handles.figure1,'pointer','cross'); end
        
function bt_oc_Callback(hObject, eventdata, handles)
    global image brushFlag
    brushFlag = 1;
    if ~isempty(image), set(handles.figure1,'pointer','cross'); end
    
function figure1_WindowButtonUpFcn(hObject, eventdata, handles)
    global btdown
    btdown = 0;
    
function figure1_WindowButtonDownFcn(hObject, eventdata, handles)
    global btdown brushFlag
    if brushFlag>=0 && strcmp(get(gcf,'SelectionType'),'normal') % left button
       btdown = 1;
    end
    if strcmp(get(gcf,'SelectionType'),'alt') % right button
       brushFlag = -1; btdown = 0;
       set(handles.figure1,'pointer','arrow');
    end
    
function figure1_WindowButtonMotionFcn(hObject, eventdata, handles)
    global image btdown brushFlag redMask blueMask
    if btdown==1 && brushFlag>=0 && ~isempty(image)
         axes(handles.axes1);
         pt = get(handles.axes1,'CurrentPoint'); n = pt(1,1);m = pt(1,2);      
         if brushFlag == 0
            radius = 2;
            mset = [max(1,fix(m-radius)),min(fix(m+radius),size(image,1))];
            nset = [max(1,fix(n-radius)),min(fix(n+radius),size(image,2))];
            rectangle('Position',[fix(n-radius),fix(m-radius),2*radius,2*radius],'EdgeColor',[1,0,0],'FaceColor',[1,0,0]);
            redMask( mset(1):mset(2), nset(1):nset(2) ) = 1;
         elseif brushFlag ==1
            radius = 5;
            mset = [max(1,fix(m-radius)),min(fix(m+radius),size(image,1))];
            nset = [max(1,fix(n-radius)),min(fix(n+radius),size(image,2))];
            rectangle('Position',[fix(n-radius),fix(m-radius),2*radius,2*radius],'EdgeColor',[0,0,1],'FaceColor',[0,0,1]);
            blueMask( mset(1):mset(2), nset(1):nset(2) ) = 1;
         end
    end


% --- Executes on button press in bt_reset.

% hObject    handle to bt_reset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
