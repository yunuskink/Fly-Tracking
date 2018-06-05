%get_params_t
%Interactively gets the parameters for the high throughput analysis from a computer
%camera. Need to set up camera with a sample population of a few flies.

%STEPS:
%1) ROI and Scaling
%2) Mask
%Background
%3) Threshhold Values
%4) Size Values (Area Min and Area Max)
%5) Protoflies

clear

N_frames = 20; dt = 1;

%Get the video ready to start recording
vid=videoinput('gentl',1, 'Mono8');
%vid=videoinput('dcam',1,'F7_YUV422_1032x776_mode0');
vid.ReturnedColorSpace = 'grayscale';
vid.FramesPerTrigger = 1;
set(vid,'Timeout',50); %set the Timeout property of VIDEOINPUT object 'vid' to 50 seconds
src = getselectedsource(vid);
src.ExposureAuto = 'Continuous';
%src = getselectedsource(vid);
%Shutter = src.Shutter;
start(vid);
im = getdata(vid,1);
imagesc(im)
roi = roipoly;
[y,x] = find(roi);
ROI_position = [min(x)-5,min(y)-5,max(x)-min(x)+10,max(y)-min(y)+10];

delete(vid); %Have to restart video to set the ROIposition property.
vid=videoinput('gentl',1, 'Mono8');
vid.ReturnedColorSpace = 'grayscale';
triggerconfig(vid,'Manual');
vid.FramesPerTrigger = 1;
vid.TriggerRepeat = Inf;
vid.ROIPosition = ROI_position;
set(vid,'Timeout',50); %set the Timeout property of VIDEOINPUT object 'vid' to 50 seconds
start(vid);
save('temp')
close(gcf)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%GETTING TEST FRAMES%%%%%%%%%%%%%%%%%%%%%%%%%
%Now that we have the approproaite window, now collect some frames from the
%video.
test_frames = {};
for i=1:N_frames
    trigger(vid);
    test_frames{i} = getdata(vid,1);
    pause(dt)
end

%The above calibration data may take a while so save this in case later stuff
%is screwed up.
save('temp')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Scale factor%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
px2cm_array = [];
for i=1:3
    px2cm_array(i) = get_scale_t(im);
end
pixel2cm = mean(px2cm_array);
save('temp')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%bwMask%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sum_image = zeros(size(test_frames{1}));
for i=1:length(test_frames)
    sum_image = sum_image+double(test_frames{i});
end
sum_image = int8(sum_image*255./max(sum_image(:)));
imagesc(sum_image)
bwMask = roipoly;
close(gcf)
choice = questdlg('Is the mask you drew good enough?','Mask','Yes','No','Yes');
if strcmp(choice,'No')
    bwMask = uint8(Mask_Threshold_t(sum_image,test_frames{1},bwMask));
end

save('temp')

for i=1:length(test_frames)
    test_frames{i} = test_frames{i}.*uint8(bwMask);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%BACKGROUND%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
n_pix = 0;intensity = 0;
for i=1:length(test_frames)
    n_pix = n_pix + length(find(test_frames{i}>0));
    intensity = intensity + sum(test_frames{i}(:));
end
background = min([1.25*intensity/n_pix, 255]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%THRESHOLDING%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[t_thresh, SE, fsize] = set_t_thresh_t(test_frames{1},test_frames{2},bwMask,background);

save('temp')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%FLY SIZES%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[area_min,area_max,sizeguess,areas_tot] = fly_polydispersity_t(test_frames{1},test_frames{2},test_frames{3},bwMask,t_thresh,SE,fsize,background);

save('temp')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%COUNTING FLIES%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[N_tot] = count_flies(test_frames{1});
save('temp')
weight = 0.5;
params = struct('area_min',area_min,'area_max',area_max,'sizeguess',sizeguess,'bwMask',bwMask,'SE',SE,'t_thresh',t_thresh,...
    'fsize',fsize,'pixel2cm',pixel2cm,'areas_tot',areas_tot,'ROI_position',ROI_position,...
    'N_tot',N_tot,'background',background,'weight',weight);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%PROTOFLIES%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
choice = questdlg('Find New Protoflies','Protoflies','Yes','Open Protofly File','Yes');

switch choice
    case 'Yes'
        ang_res = 40;
        [protoflies_edge,protoflies_whole] = Master_proto_fly_multi_image(test_frames,ang_res,params);
    case 'Open Protofly File'
        uiopen('load')
end
params.protoflies_edge = protoflies_edge;
params.protoflies_whole = protoflies_whole;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%SAVING%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[filename,pathname] = uiputfile('*.mat','Save Params As');
save([pathname,filename],'params')
save(strcat(filename,'test_frames.mat'),'test_frames')
