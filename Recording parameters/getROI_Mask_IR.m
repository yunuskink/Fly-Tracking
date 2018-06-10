%getROI_Mask_1_cam
%This function will get the exposure time, ROI, and Mask for just the IR
%camera. The experiment should be set up and a few sample flies should be placed
%in so that a proper exposure time can be chosen. A live view from the
%camera will be then be shown. Cameras can now be focused and adjusted and
%the chamber can be moved to the best position. Simultaneously, choose the
%exposure time for each camera, the time is measured in microseconds (I
%think), then click done.

%Now you can choose the ROI for each camera by drawing a box around the
%chamber. The extremities of this box will be used to create a rectangle
%which represents the only portion of the camera that will be recorded.
%Give yourself a few pixels at least of padding around the boundary.

imaqreset
fig = figure;
%subplot(1,2,1); 
ax_IR = gca;
%subplot(1,2,2); ax_GFP = gca;

vid_IR=videoinput('gentl',1, 'Mono8');
src_IR = getselectedsource(vid_IR);
src_IR.ExposureAuto = 'Off';
src_IR.ExposureTimeAbs = 800;
vid_IR.ReturnedColorSpace = 'grayscale';
triggerconfig(vid_IR,'Manual');
vid_IR.TriggerRepeat = Inf;
vid_IR.FramesPerTrigger = 1;

start(vid_IR)

%vid_GFP = videoinput('gentl', 2, 'Mono8');
%src_GFP = getselectedsource(vid_GFP);
%src_GFP.ExposureAuto = 'Continuous';
%vid_GFP.ReturnedColorSpace = 'grayscale';
%triggerconfig(vid_GFP,'Manual');
%vid_GFP.TriggerRepeat = Inf;
%vid_GFP.FramesPerTrigger = 1;
done_btn = uicontrol('Position',[0 20 60 40],'String','Done','Callback','dn = 1;uiresume');
expsr_time_IR = 3000;
expsr_txt_IR = uicontrol('Style', 'edit','String',num2str(expsr_time_IR),'Position',[90 20 90 40],'Callback', 'expsr_time_IR = str2num(expsr_txt_IR.String);uiresume'); 
%expsr_time_GFP = 3000;
%expsr_txt_GFP = uicontrol('Style', 'edit','String',num2str(expsr_time_GFP),'Position',[400 20 90 40],'Callback', 'expsr_time_GFP = str2num(expsr_txt_GFP.String);uiresume'); 

%start(vid_GFP)
dn = 0;
%%%%%%%%%%%%%%%%%%PREVIEW TO ALIGN CAMERAS AND CHAMBER%%%%%%%%%%%%%%%%%%%%
%src_GFP.ExposureAuto = 'Off';
vidRes_IR = vid_IR.VideoResolution;
%vidRes_GFP = vid_GFP.VideoResolution;
h_IR = image(ax_IR, zeros(vidRes_IR(2), vidRes_IR(1), 1) );colormap('jet')
%h_GFP = image(ax_GFP, zeros(vidRes_GFP(2), vidRes_GFP(1), 1) );colormap('jet')
preview(vid_IR,h_IR);colormap(ax_IR,'jet')
%preview(vid_GFP,h_GFP);colormap(ax_GFP,'jet')
while ~dn
    uiwait
    src_IR.ExposureTimeAbs = expsr_time_IR;
    %src_GFP.ExposureTime = expsr_time_GFP;
    %trigger(vid_IR);
    %[im_IR,time] = getdata(vid_IR,1);
    %image(ax_IR,im_IR);colormap('gray');
    %axis equal
    %trigger(vid_GFP);
    %[im_GFP,time] = getdata(vid_GFP,1);
    %image(ax_GFP,im_GFP); colormap('gray');
    %axis equal
end

%expsr_time_GFP = str2num(expsr_txt_GFP.String);
expsr_time_IR = str2num(expsr_txt_IR.String); 
stoppreview(vid_IR);
%stoppreview(vid_GFP);
close(gcf)

trigger(vid_IR);
[im_IR,time] = getdata(vid_IR,1);
%trigger(vid_GFP);
%[im_GFP,time] = getdata(vid_GFP,1);

%%%%%%%%%%%%%%%%%%%%%%%%DRAW IR ROI%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fig = figure;
imshow(im_IR,'InitialMagnification','fit');
disp('Create rectangular ROI!')
hmask = impoly ;
disp('Double click rectangle to finish!')
wait(hmask);
hmask = createMask(hmask);
[y,x] = find(hmask);
ROI_position_IR = [min(x)-5,min(y)-5,max(x)-min(x)+10,max(y)-min(y)+10];
close(gcf)
delete(vid_IR); %Have to restart video to set the ROIposition property.
vid_IR=videoinput('gentl',1, 'Mono8');
vid_IR.ReturnedColorSpace = 'grayscale';
triggerconfig(vid_IR,'Manual');
vid_IR.FramesPerTrigger = 1;
vid_IR.TriggerRepeat = Inf;
vid_IR.ROIPosition = ROI_position_IR;
set(vid_IR,'Timeout',50); %set the Timeout property of VIDEOINPUT object 'vid' to 50 seconds
start(vid_IR);
trigger(vid_IR);
[im_IR,time] = getdata(vid_IR,1);
figure;
image(im_IR)
imshow(im_IR,'InitialMagnification','fit');
disp('Create polygonal Mask!')
hmask = impoly ;
disp('Double click polygon to finish!')
wait(hmask);
bwMask_IR = createMask(hmask) ;

params_IR = struct('ROI_position',ROI_position_IR,'bwMask',bwMask_IR,'expsr_time',expsr_time_IR);

[filename,pathname] = uiputfile('*.mat','Save Params As');
%save(strcat(pathname,filename),'params_IR','params_GFP')
save(strcat(pathname,filename),'params_IR')
