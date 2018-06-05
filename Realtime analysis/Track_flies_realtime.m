function [ResMat] = Track_flies_realtime()

%This function will acquire an image, track the positions of the flies
%using the fly_fit approach, then repeat. It will request the entry of the
%params file which is output from a separate function. 

%Results will be periodically saved in the current folder in addition to
%images demonstrating the quality of the tracking algorithm.

%First, load the parameters file

[filename,pathname] = uigetfile;
params = load([pathname,filename],'params');
params = params.params;
imaqreset;
%Get the video ready to start recording
vid=videoinput('gentl',1, 'Mono8');
src = getselectedsource(vid);
src.ExposureAuto = 'Continuous';
vid.ReturnedColorSpace = 'grayscale';
triggerconfig(vid,'Manual');
vid.FramesPerTrigger = 1;
vid.TriggerRepeat = Inf;
vid.ROIPosition = params.ROI_position;
set(vid,'Timeout',50); %set the Timeout property of VIDEOINPUT object 'vid' to 50 seconds
%Run Data Collection Indefinitely
time_scale = Inf;


start(vid)

params.N_tot = 1;
test_params(params,vid)

[params.N_tot] = count_flies_automated(params,vid);

test_params(params,vid)

%Now, with these parameters, collect pictures as frequently as possible
%while a button is not pressed.
f = figure;
set(f,'Position',[700 700 250 80])
pause_btn = uicontrol('Style', 'pushbutton', 'String', 'Pause','Position', [20 20 50 40])
environment_text = uicontrol('Style', 'edit', 'String', '0','Position', [80 20 50 40])
%stop_btn = uicontrol('Style', 'pushbutton', 'String', 'Stop','Position', [100 20 50 40],'Callback', 'cla');
pause_btn.Callback = {@pause_expt, pause_btn};

keep_going = 1;
p=1;
check_in_time = 20;
track_fig = figure;
ResMat = [];
tic
expt_num = 1;
%The loop starts recording
while keep_going
    %If the pause button is pressed
    if strcmp(pause_btn.String,'Paused')
        save(strcat('ResMat',num2str(time),'.mat'),'ResMat')
        [params.N_tot] = count_flies_automated(params,vid);
        test_params(params,vid);
        pause_btn.String = 'Pause';
        expt_num = expt_num+1;   
    end
    %If the time for the experiment for collection has finished, wait for
    %the next chamber to be set up.
    environment = str2double(environment_text.String);
    %Collect image from camera
    trigger(vid);
    %while get(vid,'FramesAvailable')<1  %Wait until at least 1 frame is
    %available
    %unavailable=1;
    %end
    
    [im,time] = getdata(vid,1);
    flushdata(vid)
    %Get rid of outside parts and apply the mask.
    %im = im(min_y:max_y,min_x:max_x);
    im = im.*uint8(params.bwMask);
    [bw, CC, CC_large] = get_thresholded_flies(im,params.t_thresh,params.bwMask,params.SE, params.area_min, params.area_max, params.fsize,params.background);
    CC = CC.PixelIdxList;
    CC_large = CC_large.PixelIdxList;
    flag = 0;
    ResMat_temp = [];
    if ~isempty(CC_large)
        ResMat_temp = [];
        flag = 2;
        N_missing = params.N_tot - length(CC);
        [pos,N_flies_found] = Master_separate_flies(im,CC_large,N_missing,params.protoflies_whole,params.protoflies_edge,0,params.weight,params.area_min);
        if N_flies_found>0
            ResMat_temp = [time*ones(N_flies_found,1), pos(:,1), pos(:,2), flag*ones(N_flies_found,1), p*ones(N_flies_found,1)];
            ResMat_temp(:,6) = expt_num;
            ResMat_temp(:,8) = environment;
        end
        
    end
    ResMat_temp2 = zeros(length(CC),6);
    ResMat_temp2(:,1) = time;
    ResMat_temp2(1,4) = flag;
    ResMat_temp2(:,5) = p;
    ResMat_temp2(:,6) = expt_num;

    ResMat_temp2(:,8) = environment;

    for j=1:length(CC)
        [y,x] = ind2sub(size(im),CC{j});
        ResMat_temp2(j,2) = mean(x);
        ResMat_temp2(j,3) = mean(y);
    end
    ResMat = [ResMat; ResMat_temp;ResMat_temp2];
    
    if time>check_in_time
        figure(track_fig);
        image(im); hold on
        if ~isempty(ResMat_temp)
            scatter(ResMat_temp(:,2),ResMat_temp(:,3),'r*');
        end
        scatter(ResMat_temp2(:,2),ResMat_temp2(:,3),'g*');
        savefig(gcf,strcat(num2str(time),'.fig')); hold off
        %save(strcat(num2str(time),'.mat'),'im')
        save(strcat('ResMat','.mat'),'ResMat')
        check_in_time = check_in_time + 20;
    end
    p=p+1;
end

end

function pause_expt(source,event,pause_btn)
pause_btn.String = 'Paused';
%When paused, load up the video feed of the experiment to let user load
%in new flies
%test_params(params,vid);
%vid=videoinput('gentl',1, 'YUV422Packed');
%start(vid);
%vidRes = vid.VideoResolution;
%imWidth = vidRes(1);
%imHeight = vidRes(2);
%nBands = vid.NumberOfBands;
%fig = figure;
%hImage = image( zeros(imHeight, imWidth, nBands) );
%preview(vid,hImage)
%done_btn = uicontrol('Style', 'pushbutton', 'String', 'Pause','Position', [20 20 50 40],'Callback', 'close');
%uiwait(fig);
end

%function stop_expt(source,event,vid)
%When paused, load up the video feed of the experiment to let user load
%in new flies
%delete(vid)
%end

