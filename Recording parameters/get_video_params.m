%get_video_params

%GUI:
%Four test images will be displayed and regularly updated when the update
%button is pressed.
%OPTIONS:
%1) Button to draw a mask
%2) Button to automate drawing of mask with a certain parameter size
%3) Fly threshhold
%4) Area minimum
%5) Area maximum (not necessary for DIC yet)
%6) Button to plot histogram of areas though unnecessary for DIC
%7) Button to launch window to count flies
%8) SE for do image closing but probably not necessary
%9) fsize for filtering out noise, probably not necessary


%GET USER INPUT FOR MOVIE FILENAME
[filename,pathname] = uigetfile('*.avi','Select movie file');
mv_filename = strcat(pathname,filename);
mv = VideoReader(mv_filename);

%GET SAMPLE IMAGES
tot_frames = mv.framerate*mv.duration-10;
rand_frames = datasample([1:tot_frames],4);

test_frames = {};
for i=1:4
    mv.CurrentTime = rand_frames(i)/mv.framerate;
    test_frames{i} = rgb2gray(readFrame(mv));
end

%GET PARAMS FILE THAT SHOULD CONTAIN THE ROI AND BWMASK
answer = questdlg('Do you already have a params?','Params choice','Yes','No','Yes');
switch answer
    case 'Yes'
        [filename,pathname] = uigetfile;
        params_filename = strcat(pathname,filename);
        params = load(params_filename,'params');%Params file is to get the ROI
        params = params.params;
        names = fieldnames(params);
        for i=1:size(names,1)
            eval(strcat(names{i},'=params.',names{i},';')); %Bad coding, but it gets all the variables out of params
        end
    case 'No'
        params = struct;
        bwMask = uint8(ones(size(test_frames{1},1),size(test_frames{1},2)));
        ROI_position = NaN;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%GET MASK%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Test if current mask is good enough
figure;
subplot(1,2,1);imagesc(test_frames{1})
subplot(1,2,2);imagesc(test_frames{1}.*uint8(bwMask));
answer = questdlg('Do you want to assign a new mask?','Mask choice','Yes','No','Yes');
switch answer
    case 'Yes'
        [params.bwMask] = Get_Mask_mv(mv_filename);
        bwMask = params.bwMask;
    case 'No'
        bwMask = params.bwMask;
end

%%%%%%%%%%%%%%%%%%%%%%BUILDING GUI%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%setting up axes%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
f = figure;
downshift = 40;
res = get(0,'ScreenSize'); res(1) = res(1)+downshift;res(2) = res(2)+downshift;res(3) = res(3)-downshift;res(4) = res(4)-downshift;
f.OuterPosition = res;
ax_s = {};
ax_s{1} = axes('Parent',f,'position',[0.3 0.55 0.35 0.35]);
ax_s{2} = axes('Parent',f,'position',[0.65 0.55 0.35 0.35]);
ax_s{3} = axes('Parent',f,'position',[0.3 0.1 0.35 0.35]);
ax_s{4} = axes('Parent',f,'position',[0.65 0.1 0.35 0.35]);
for i=1:length(ax_s)
    image(ax_s{i},test_frames{i});
    axis(ax_s{i},'image','equal');
end

%%%%%%%%%%%%%%%%%%%%making buttons and text entry%%%%%%%%%%%%%%%%%%%%%%%%%
b_t_thresh = uicontrol('Parent',f,'Style','slider','Position',[10,400,419,23],'value',0, 'min',-50, 'max',50);
done_btn = uicontrol('Position',[20 70 100 40],'String','Done','Callback','uiresume');
update_btn = uicontrol('Position',[20 5 100 40],'String','UPDATE IMAGES');
plot_fly_szs_btn = uicontrol('Position',[140 5 100 40],'String','FLY SIZES');
count_flies_btn = uicontrol('Position',[140 70 100 40],'String','COUNT FLIES');
b_area_min = uicontrol('Parent',f,'Style','edit','Position',[10,140,80,23],'String','0');label_area_min = uicontrol('Parent',f,'Style','text','Position',[10,170,80,23],'String','Min Area');
b_area_max = uicontrol('Parent',f,'Style','edit','Position',[110,140,80,23],'String','100000');label_area_max = uicontrol('Parent',f,'Style','text','Position',[110,170,80,23],'String','Max Area');
b_max_disp = uicontrol('Parent',f,'Style','edit','Position',[210,140,80,23],'String','2');label_max_disp = uicontrol('Parent',f,'Style','text','Position',[210,170,80,23],'String','Max Displacement');
b_fsize = uicontrol('Parent',f,'Style','edit','Position',[10,210,80,23],'String','20');label_fsize = uicontrol('Parent',f,'Style','text','Position',[10,240,80,23],'String','Filter Size');
b_background = uicontrol('Parent',f,'Style','edit','Position',[110,210,80,23],'String','250');label_background = uicontrol('Parent',f,'Style','text','Position',[110,240,80,23],'String','Background');
%b_sizeguess = uicontrol('Parent',f,'Style','text','Position',[210,140,80,23],'String','0');label_sizeguess = uicontrol('Parent',f,'Style','text','Position',[210,170,80,23],'String','AVERAGE SIZE');
b_N_tot = uicontrol('Parent',f,'Style','text','Position',[310,140,80,23],'String','0');label_N_tot = uicontrol('Parent',f,'Style','text','Position',[310,170,80,23],'String','TOTAL FLIES');

%%%%%%%%%%%%%%%%%%%%%%%%SET DEFAULT VALUES%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if exist('area_min','var');b_area_min.String = num2str(area_min);end
if exist('area_max','var');b_area_max.String = num2str(area_max);end    
if exist('t_thresh','var');b_t_thresh.String = num2str(t_thresh);end
if exist('fsize','var');b_fsize.String = num2str(fsize);end    
if exist('background','var');b_background.String = num2str(background);end    
if exist('max_disp','var');b_max_disp.String = num2str(max_disp);end    
if exist('SE','var');else;SE = 4;end

mn_s = ones(size(test_frames));
for i=1:length(test_frames)
    mn_s(i) = mean(test_frames{i}(~bwMask));
end
background = round(mean(mn_s));b_background.String = num2str(background);

%%%%%%%%%%%%%%%%%%%%%%%%ASSIGNING CALLBACKS%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
update_btn.Callback = {@update_images,b_t_thresh,b_fsize,SE,ax_s,b_area_min,b_area_max,test_frames,bwMask,b_background};
plot_fly_szs_btn.Callback = {@plot_fly_szs,b_t_thresh,b_fsize,SE,ax_s,b_area_min,b_area_max,test_frames,bwMask,b_background};
count_flies_btn.Callback = {@count_flies_callback,test_frames{1},b_N_tot};
mask_btn.Callback = {@count_flies_callback,test_frames{1},b_N_tot};
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%ONCE FINISHED%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
uiwait
t_thresh = b_t_thresh.Value;
area_min = str2double(b_area_min.String);
area_max = str2double(b_area_max.String);
fsize = str2double(b_fsize.String);
background = str2double(b_background.String);
%sizeguess = str2double(b_sizeguess.String);
N_tot = str2double(b_N_tot.String);
max_disp = str2double(b_max_disp.String);
close(f)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%fitFLIES%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
choice = questdlg('Find New fitflies','fitflies','Yes','Open fitfly File','Yes');

params = struct('area_min',area_min,'area_max',area_max,'bwMask',bwMask,'SE',SE,'t_thresh',t_thresh,...
    'fsize',fsize,'N_tot',N_tot,'background',background,'ROI_position',ROI_position,'weight',0.5,'max_disp',max_disp);

switch choice
    case 'Yes'
        ang_res = 40;
        [fitflies_edge,fitflies_whole] = get_fitflies(test_frames,ang_res,params);
    case 'Open Fitfly File'
        uiopen('load')
end

%params = struct('area_min',area_min,'area_max',area_max,'bwMask',bwMask,'SE',SE,'t_thresh',t_thresh,...
%    'fsize',fsize,'N_tot',N_tot,'background',background,'ROI_position',ROI_position,'weight',0.5);

params.fitflies_edge = fitflies_edge;
params.fitflies_whole = fitflies_whole;

[FileName,PathName] = uiputfile('*.mat','Save Params As');
save(strcat(PathName,FileName),'params')

%%%%%%%%%%%%%%%%%%%%%%UPDATE IMAGES CALLBACK%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function update_images(src,evnt,b_t_thresh,b_fsize,SE,ax_s,b_area_min,b_area_max,test_frames,bwMask,b_background)
t_thresh = b_t_thresh.Value;
area_min =str2double(b_area_min.String);
area_max =str2double(b_area_max.String);
fsize = str2double(b_fsize.String);
background = str2double(b_background.String);

for i=1:length(ax_s)
    axes(ax_s{i});
    imshow(immultiply(test_frames{i},bwMask));
    hold on
    [bw, CC, CC_large] = get_thresholded_flies(test_frames{i},t_thresh,bwMask,SE, area_min, area_max, fsize,background); 
    for i=1:length(CC_large.PixelIdxList)
        bw(CC_large.PixelIdxList{i}) = 0;
    end
    RGB = bw*255;
    RGB(end, end, 3) = 0;  % All information in red channel
    him=imshow(RGB);
    set(him,'AlphaData',0.2);
    hold off
end

end

%%%%%%%%%%%%%%%%%%%%%%%PLOT FLY SIZES CALLBACK%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function plot_fly_szs(src,evnt,b_t_thresh,b_fsize,SE,ax_s,b_area_min,b_area_max,test_frames,bwMask,b_background)
t_thresh = b_t_thresh.Value;
area_min =str2double(b_area_min.String);
area_max =str2double(b_area_max.String);
fsize = str2double(b_fsize.String);
background = str2double(b_background.String);
szs = [];

for i=1:length(ax_s)
    [bw, CC, CC_large] = get_thresholded_flies(test_frames{i},t_thresh,bwMask,SE, area_min, area_max, fsize,background); 
    [CC] = bwconncomp(bw);
    for j=1:length(CC.PixelIdxList)
        szs(end+1) = length(CC.PixelIdxList{j});
    end
end

figure;histogram(szs,[area_min:(area_max-area_min)/20:area_max]);

end
%%%%%%%%%%%%%%%%%%%%%COUNT FLIES CALLBACK%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function count_flies_callback(src,evnt,im,b_N_tot)
[N_tot] = count_flies(im);
b_N_tot.String = num2str(N_tot);
end

