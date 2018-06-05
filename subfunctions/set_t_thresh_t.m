function [t_thresh, SE, fsize] = set_t_thresh_t(im1,im2,bwMask,background)

im_array = {};

im1(bwMask==0) = 0;im_array{1} = im1;
im2(bwMask==0) = 0;im_array{2} = im2;

blah='Choose threshholding paramters'

%Build GUI
f = figure;
ax_s = {};
ax_s{1} = axes('Parent',f,'position',[0.1 0.39  0.35 0.35]);
ax_s{2} = axes('Parent',f,'position',[0.5 0.39  0.35 0.35]);


b_t_thresh = uicontrol('Parent',f,'Style','slider','Position',[81,80,419,23],'value',0, 'min',0, 'max',100);
b_fsize = uicontrol('Parent',f,'Style','edit','Position',[120,54,46,23],'String',20);
b_SE = uicontrol('Parent',f,'Style','edit','Position',[180,54,46,23],'String',4);
h = uicontrol('Position',[0 20 60 40],'String','Done','Callback','uiresume');

b_t_thresh.Callback = {@update_images,b_t_thresh,b_fsize,b_SE,ax_s,im_array,bwMask,background};
b_fsize.Callback = {@update_images,b_t_thresh,b_fsize,b_SE,ax_s,im_array,bwMask,background};
b_SE.Callback = {@update_images,b_t_thresh,b_fsize,b_SE,ax_s,im_array,bwMask,background};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%ONCE FINISHED%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
uiwait
t_thresh = b_t_thresh.Value;
fsize = str2double(b_fsize.String);
SE = str2double(b_SE.String);

close(f)

end

function update_images(src,evnt,b_t_thresh,b_fsize,b_SE,ax_s,im_array,bwMask,background)
t_thresh = b_t_thresh.Value;
fsize = str2double(b_fsize.String);
SE = str2double(b_SE.String);

for i=1:length(ax_s)
    axes(ax_s{i});
    imshow(im_array{i});
    hold on
    [bw] = get_thresholded_flies_px(im_array{i},t_thresh,bwMask,SE, 0, 1000000, fsize,background);
    RGB = bw*255;
    RGB(end, end, 3) = 0;  % All information in red channel
    him=imshow(RGB);
    set(him,'AlphaData',0.2);
    hold off
end

end

