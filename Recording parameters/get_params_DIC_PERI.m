function [params] = get_params_DIC_PERI(im,params)

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

test_frames = {};
for i=1:4
    test_frames{i} = im(:,:,randi(size(im,3)));
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
b_t_thresh = uicontrol('Parent',f,'Style','slider','Position',[10,400,419,23],'value',0, 'min',0, 'max',100);
done_btn = uicontrol('Position',[20 70 100 40],'String','Done','Callback','uiresume');
update_btn = uicontrol('Position',[20 5 100 40],'String','UPDATE IMAGES');
%mask_btn = uicontrol('Position',[140 5 100 40],'String','GET MASK');
count_flies_btn = uicontrol('Position',[140 70 100 40],'String','COUNT FLIES');
b_area_min = uicontrol('Parent',f,'Style','edit','Position',[10,140,80,23],'String','0');
b_area_max = uicontrol('Parent',f,'Style','edit','Position',[110,140,80,23],'String','100000');
b_sizeguess = uicontrol('Parent',f,'Style','text','Position',[210,140,80,23],'String','0');label_sizeguess = uicontrol('Parent',f,'Style','text','Position',[210,170,80,23],'String','AVERAGE SIZE');
b_N_tot = uicontrol('Parent',f,'Style','text','Position',[310,140,80,23],'String','0');label_N_tot = uicontrol('Parent',f,'Style','text','Position',[310,170,80,23],'String','TOTAL FLIES');

%%%%%%%%%%%%%%%%%%%%%%%%SET DEFAULT VALUES%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin>1
    names = fieldnames(params);
    for i=1:size(names,1)
        eval(strcat(names{i},'=params.',names{i},';')); %Bad coding, but it gets all the variables out of params
    end
    %b_area_min.String = num2str(area_min);b_area_max.String = num2str(area_max);b_sizeguess.String = num2str(sizeguess);b_N_tot.String = num2str(N_tot);
    %b_t_thresh.Value = t_thresh;
    
else
    bwMask = uint8(ones(size(im,1),size(im,2)));
end
fsize=5;%b_fsize = uicontrol('Parent',f,'Style','edit','Position',[120,54,46,23],'String',20);
SE = 4;%b_SE = uicontrol('Parent',f,'Style','edit','Position',[180,54,46,23],'String',4);
background = 255;

%[bwMask] = Get_Mask_DIC(test_frames{1});

%%%%%%%%%%%%%%%%%%%%%%%%ASSIGNING CALLBACKS%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
update_btn.Callback = {@update_images,b_t_thresh,fsize,SE,ax_s,b_area_min,b_area_max,test_frames,bwMask,background};
count_flies_btn.Callback = {@count_flies_callback,test_frames{1},b_N_tot};
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%ONCE FINISHED%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
uiwait
t_thresh = b_t_thresh.Value;
area_min = str2double(b_area_min.String);
area_max = str2double(b_area_max.String);
sizeguess = str2double(b_sizeguess.String);
N_tot = str2double(b_N_tot.String);
close(f)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%PROTOFLIES%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
choice = questdlg('Find New Protoflies','Protoflies','Yes','Open Protofly File','Yes');

switch choice
    case 'Yes'
        ang_res = 40;
        [protoflies_edge,protoflies_whole] = Master_proto_fly_multi_image(test_frames,ang_res,params);
    case 'Open Protofly File'
        uiopen('load')
end

params = struct('area_min',area_min,'area_max',area_max,'sizeguess',sizeguess,'bwMask',bwMask,'SE',SE,'t_thresh',t_thresh,...
    'fsize',fsize,'N_tot',N_tot,'background',background,'ROI_position',ROI_position,'weight',0.5);

params.protoflies_edge = protoflies_edge;
params.protoflies_whole = protoflies_whole;

[FileName,PathName] = uiputfile('*.mat','Save Params As');
save(strcat(PathName,FileName),'params')

end

%%%%%%%%%%%%%%%%%%%%%%UPDATE IMAGES CALLBACK%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function update_images(src,evnt,b_t_thresh,fsize,SE,ax_s,b_area_min,b_area_max,test_frames,bwMask,background)
t_thresh = b_t_thresh.Value;
area_min =str2double(b_area_min.String);
area_max =str2double(b_area_max.String);

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

%%%%%%%%%%%%%%%%%%%%%%%GET MASK CALLBACK%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%COUNT FLIES CALLBACK%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function count_flies_callback(src,evnt,im,b_N_tot)
[N_tot] = count_flies(im);
b_N_tot.String = num2str(N_tot);
end

