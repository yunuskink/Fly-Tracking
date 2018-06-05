%align_with_mask
src_IR.ExposureTimeAbs = params_IR.expsr_time;
start(vid_IR);start(vid_GFP);
src_IR.ExposureTimeAbs = params_IR.expsr_time;
figure;
subplot(1,2,1); ax_IR = gca;
subplot(1,2,2); ax_GFP = gca;
RGB_IR = ~params_IR.bwMask.*255;
RGB_IR(end, end, 3) = 0;
RGB_GFP = ~params_GFP.bwMask.*255;
RGB_GFP(end, end, 3) = 0;

done_btn = uicontrol('Position',[0 20 60 40],'String','Done','Callback','dn = 1;');
dn = 0;
%%%%%%%%%%%%%%%%%%PREVIEW TO ALIGN CAMERAS AND CHAMBER%%%%%%%%%%%%%%%%%%%%
while ~dn
    trigger(vid_IR);
    [im_IR,time] = getdata(vid_IR,1);
    %hold on
    im_IR = squeeze(im_IR);
    image(ax_IR,im_IR.*uint8(params_IR.bwMask));
    %image(ax_IR,im_IR);
    %him_IR=image(ax_IR,RGB_IR);
    %set(him_IR,'AlphaData',0.3);
    %hold off
    axis equal
    trigger(vid_GFP);
    [im_GFP,time] = getdata(vid_GFP,1);
    %hold on;
    image(ax_GFP,im_GFP.*uint8(params_GFP.bwMask));
    %image(ax_GFP,im_GFP);
    %him_GFP=image(ax_GFP,RGB_GFP);
    %set(him_GFP,'AlphaData',0.3);
    %hold off
    axis equal
    wait(vid_IR,500,'logging');wait(vid_GFP,500,'logging');
end
close(gcf)

stop(vid_IR);stop(vid_GFP)