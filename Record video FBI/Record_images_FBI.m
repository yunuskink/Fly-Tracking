%First, load the parameters file

[filename,pathname] = uigetfile;
params_IR = load(strcat(pathname,filename),'params_IR');%Params file is to get the ROI
params_IR = params_IR.params_IR;
params_GFP = load(strcat(pathname,filename),'params_GFP');%Params file is to get the ROI
params_GFP = params_GFP.params_GFP;
imaqreset;
%Get the video ready to start recording
vid_IR=videoinput('gentl',1, 'Mono8');
src_IR = getselectedsource(vid_IR);
src_IR.ExposureAuto = 'Off';
vid_IR.ReturnedColorSpace = 'grayscale';
triggerconfig(vid_IR,'Manual');
vid_IR.TriggerRepeat = Inf;
vid_IR.FramesPerTrigger = 1;
vid_IR.ROIPosition = params_IR.ROI_position;
vid_IR.LoggingMode = 'disk';

vid_GFP = videoinput('gentl', 2, 'Mono8');
vid_GFP.LoggingMode = 'disk';
src_GFP = getselectedsource(vid_GFP);
src_GFP.ExposureAuto = 'Continuous';
vid_GFP.ReturnedColorSpace = 'grayscale';
triggerconfig(vid_GFP,'Manual');
vid_GFP.TriggerRepeat = Inf;
vid_GFP.FramesPerTrigger = 1;
vid_GFP.ROIPosition = params_GFP.ROI_position;

%align_with_mask;
logfile_IR = VideoWriter('1_IR.avi', 'Grayscale AVI');
logfile_GFP = VideoWriter('1_GFP.avi', 'Grayscale AVI');
vid_IR.DiskLogger = logfile_IR;
vid_GFP.DiskLogger = logfile_GFP;


framerate_IR = 30;
framerate_GFP = 1;
t_interval = 7200;
frame_interval_IR = framerate_IR*t_interval;
frame_interval_GFP = framerate_GFP*t_interval-2;
vid_IR.FramesPerTrigger = frame_interval_IR;
vid_GFP.FramesPerTrigger = frame_interval_GFP;
set(vid_IR,'Timeout',50);
set(vid_GFP,'Timeout',50);
start(vid_IR);start(vid_GFP);
src_IR.ExposureTimeAbs = params_IR.expsr_time;
src_GFP.ExposureAuto = 'Off';
src_GFP.ExposureTime = params_GFP.expsr_time;

%src.AcquisitionFrameRate = src.AcquisitionFrameRateLimit; Doesn't work,
%the framerate always goes to the fastest possible which is super-annoying

src_IR.AcquisitionFrameRateAbs = framerate_IR;
src_GFP.AcquisitionFrameRate = framerate_GFP;

keep_going = 1;
%The loop starts recording
%first = 1;
tic
%logfile_IR = VideoWriter([num2str(0),'_IR.avi'], 'Grayscale AVI');
%logfile_GFP = VideoWriter([num2str(0),'_GFP.avi'], 'Grayscale AVI');%if first

while keep_going
    %Every minute...
    tic
    trigger(vid_IR);
    trigger(vid_GFP);toc
    %while (vid_IR.FramesAcquired ~= vid_IR.DiskLoggerFrameCount)&&(vid_GFP.FramesAcquired ~= vid_GFP.DiskLoggerFrameCount)
    %    pause(.1)
    %end
    %logfile_IR = VideoWriter([num2str(0),'_IR.avi'], 'Grayscale AVI');
    %logfile_GFP = VideoWriter([num2str(0),'_GFP.avi'], 'Grayscale AVI');

    %vid_IR.DiskLogger = logfile_IR;
    %vid_GFP.DiskLogger = logfile_GFP;
    %if first
    %    first = 0;%No longer the first
    %else
        %[im_IR,time_IR] = getdata(vid_IR,frame_interval_IR);
        %im_IR = squeeze(im_IR);
        %[im_GFP,time_GFP] = getdata(vid_GFP,frame_interval_GFP);
        %im_GFP = squeeze(im_GFP);
        %save(strcat(num2str(time_IR(1)),'.mat'),'im_IR','time_IR');%Save previous minute's results while camera collects the next minute
        %save(strcat(num2str(time_IR(1)),'.mat'),'im_IR','im_GFP','time_IR','time_GFP');%Save previous minute's results while camera collects the next minute
    %end
    wait(vid_IR,500,'logging');
end

while (vid_IR.FramesAcquired ~= vid_IR.DiskLoggerFrameCount)&&(vid_GFP.FramesAcquired ~= vid_GFP.DiskLoggerFrameCount)
    pause(.1)
end

close(logfile_IR)
close(logfile_GFP)



%SOME DAQ CONTROL STUFF I STILL NEED TO FIGURE OUT.
if 0
   %output data
s = daq.createSession('ni');
s.Rate = 5000; %must be no more than 5000
addAnalogOutputChannel(s,'Dev1',1,'Voltage'); %the 0 is the number of the terminal youre connecting to
s.IsContinuous = true;
outputData = linspace(-1, 1, 5000)';%can make this anything you want
queueOutputData(s,outputData)
startBackground(s);
%pause(); allows you to pause the command line until you press any key
tic;
while 1
%copy and paste this into something else if you want it to work
if toc > 5
    stop(s)
    outputData = linspace(0,0, 5000)';%can make this anything you want
    queueOutputData(s,outputData)
    startBackground(s);
end

end
 
end