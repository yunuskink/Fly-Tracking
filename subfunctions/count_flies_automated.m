function [N_flies] = count_flies_automated(params,vid)

%Take an image from the camera, make an estimate of the number of flies in
%the image, plot that image and label the flies and readout the total number of
%flies. When the user presses a button asking to recount, then repeat.


fig = figure;
done_btn = uicontrol('Style', 'pushbutton', 'String', 'Done','Position', [20 20 50 40],'Callback', 'uiresume');
N_flies_text = uicontrol('Parent',fig,'Style','edit','Position',[120,54,46,23],'String',00);
Recount_btn = uicontrol('Style', 'pushbutton', 'String', 'Recount','Position', [80 20 50 40]);
set(gca,'XTickLabel',[]);set(gca,'YTickLabel',[])
recount_flies_callback(0,0,params,vid,0);
Recount_btn.Callback = {@recount_flies_callback,params,vid,str2double(N_flies_text.String)};

uiwait

N_flies = str2double(get(N_flies_text,'String'));

close(fig)

end

function recount_flies_callback(src,evnt,params,vid,N_guess)
ResMat = [];
%Collect image from camera
trigger(vid);
[im,time] = getdata(vid,1);
%Get rid of outside parts and apply the mask.
%im = im(min_y:max_y,min_x:max_x);
im = im.*uint8(params.bwMask);
[bw, CC, CC_large] = get_thresholded_flies(im,params.t_thresh,params.bwMask,params.SE, params.area_min, params.area_max, params.fsize,params.background);
if N_guess == 0
    N_guess = round(sum(bw(:))/params.sizeguess);
end
CC = CC.PixelIdxList;
CC_large = CC_large.PixelIdxList;
flag = 0;
ResMat_temp = [];
if ~isempty(CC_large)
    flag = 2;
    N_missing = N_guess - length(CC);
    [pos,N_flies_found] = Master_separate_flies(im,CC_large,N_missing,params.protoflies_whole,params.protoflies_edge,0,params.weight,params.area_min);
    if N_flies_found>0
        ResMat_temp = [time*ones(N_flies_found,1), pos(:,1), pos(:,2), flag*ones(N_flies_found,1), ones(N_flies_found,1)];
    end
end
ResMat_temp2 = zeros(length(CC),5);
ResMat_temp2(:,1) = 1;
ResMat_temp2(1,4) = flag;
ResMat_temp2(:,5) = 1;
for j=1:length(CC)
    [y,x] = ind2sub(size(im),CC{j});
    ResMat_temp2(j,2) = mean(x);
    ResMat_temp2(j,3) = mean(y);
end
ResMat = [ResMat; ResMat_temp;ResMat_temp2];
imagesc(im); hold on
if length(ResMat_temp)
    scatter(ResMat_temp(:,2),ResMat_temp(:,3),'r*');
end
scatter(ResMat_temp2(:,2),ResMat_temp2(:,3),'g*');
RGB = ~params.bwMask.*255;
RGB(end, end, 3) = 0;  % All information in red channel
him=imshow(RGB);
set(him,'AlphaData',0.2);
hold off
title(strcat('There are ', num2str(size(ResMat,1)), ' labelled'))
save(strcat('Loading Flies Image',num2str(time(1)),'.mat'),'im')
end
