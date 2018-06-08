function fitfly_video_tracking(params,mv,need_fitflies)
%This runs PERI analysis on an movie file. Modified 6_1_2018

%MODIFICATIONS NEEDED: 
%1) Ability to watch tracking as it goes.

%ADDITIONAL PARAMETERS:
ang_res = 40;%Degree increment by which the model_fly should be rotated. E.g. ang_res=60 will produce 6 distinct rotations
weight = 0.5;%Weight between fitting the edge of the model_fly versus the whole fly.

%Extract the variables from the params structure
names = fieldnames(params);
for i=1:size(names,1)
    eval(strcat(names{i},'=params.',names{i},';')); %Bad coding, but it gets all the variables out of params
end

v=VideoReader(mv);
p=0;

%need_fitflies for if we need to get fitflies
if need_fitflies==1
    frame = readFrame(v);
    v.CurrentTime = 0;
    frame = frame(min_y:max_y,min_x:max_x);
    %Get fitflies
    [fitflies_edge,fitflies_whole] = Master_proto_fly(frame,ang_res,params);
end

Results = {};
iter = 0;
total_iter = v.framerate*v.Duration/64;

params.min_x = 1;params.min_y = 1;params.max_x = v.Width;params.max_y=v.Height;

while v.CurrentTime+65/v.framerate<v.Duration
    iter = iter+1;
    prog = iter/total_iter
    %for z =1:2
    %In an attempt to parallelize, I will read in 64 frames of the video at
    %a time, then run a parfor loop to process those.
    frame_arr = zeros(size(bwMask,1),size(bwMask,2),64);
    for i=1:64
        frame =readFrame(v);
        
        frame_arr(:,:,i) = frame(min_y:max_y,min_x:max_x);
    end
    %parfor_progress(64);
    %Initialize Results structure to keep the results separate so that code can
    %be parallelized
    Results_t = {};
    parfor i=1:64
        t = p*64+i;
        frame = frame_arr(:,:,i);
        [~, CC, CC_large] = get_thresholded_flies(frame,t_thresh,bwMask,SE, area_min, area_max, fsize,background);
        CC = CC.PixelIdxList;
        CC_large = CC_large.PixelIdxList;
        flag = 0;
        ResMat_temp = []; %For PERI flies
        if ~isempty(CC_large)
            flag = 2;
            N_missing = N_tot - length(CC);
            [pos,N_flies_found] = Master_separate_flies(frame,CC_large,N_missing,fitflies_whole,fitflies_edge,0,weight,area_min);
            if N_flies_found>0
                ResMat_temp = [t*ones(N_flies_found,1), pos(:,1), pos(:,2), flag*ones(N_flies_found,1), i*ones(N_flies_found,1),0*ones(N_flies_found,1),0*ones(N_flies_found,1),0*ones(N_flies_found,1),NaN*ones(N_flies_found,1)];
            end
        end
        N_still_missing = N_tot - length(CC)-size(ResMat_temp,1);
        ResMat_temp3 = [];
        if N_still_missing>0 %This is important for mixed gender experiments where two males for example could be confused for a female
            
            areas = zeros(length(CC),1);
            for j=1:length(CC)
                areas(j) = length(CC{j});
            end
            [ar, order] = sort(areas);
            CC_large = {};
            for k=1:N_still_missing
                CC_large{k} = CC{order(end-k+1)};
            end
            %CC_large = CC{order(end-N_still_missing+1:end)};
            flag = 2;
            [pos,N_flies_found] = Master_separate_flies(frame,CC_large,N_still_missing,fitflies_whole,fitflies_edge,0,weight,area_min);
            if N_flies_found>0
                ResMat_temp3 = [t*ones(N_flies_found,1), pos(:,1), pos(:,2), flag*ones(N_flies_found,1), i*ones(N_flies_found,1),0*ones(N_flies_found,1),0*ones(N_flies_found,1),0*ones(N_flies_found,1),NaN*ones(N_flies_found,1)];
            end
        end
            
        ResMat_temp2 = zeros(length(CC),5);
        ResMat_temp2(:,1) = t;
        ResMat_temp2(1,4) = flag;
        ResMat_temp2(:,5) = i;
        for j=1:length(CC)
            [y,x] = ind2sub(size(frame),CC{j});
            ResMat_temp2(j,2) = mean(x);
            ResMat_temp2(j,3) = mean(y);
            ResMat_temp2(j,9) = length(CC{j});
        end
        ResMat = [ResMat_temp; ResMat_temp2; ResMat_temp3];        
        Results_t{i} = ResMat;
        %parfor_progress; %Count
        %length(Results)/length(frame_times)
        %figure;imagesc(frame);hold on;colormap('gray');scatter(ResMat(:,2),ResMat(:,3));
        %waitforbuttonpress
    end
    %parfor_progress(0);
    p=p+1;
    save(strcat('Results',num2str(iter),'.mat'),'Results_t')
    %Results = [Results, Results_t];
    
    
end

ResMat = [];
for i=1:length(Results)
    ResMat = [ResMat;Results{i}];
end

date_analyzed = datetime;
save(strcat('0COM_results',mov,'.mat'),'ResMat','params','fitflies_whole','fitflies_edge','date_analyzed');