function [area_min,area_max,sizeguess,areas_tot] = fly_polydispersity_t(im1,im2,im3,bwMask,t_thresh,SE,fsize,background)

im_array = {};
areas_tot = [];

im1(bwMask==0) = 0;im_array{1} = im1;
im2(bwMask==0) = 0;im_array{2} = im2;
im3(bwMask==0) = 0;im_array{3} = im3;

blah='Choose area paramters'

%Build GUI
f = figure;
ax_s = {};
ax_s{1} = axes('Parent',f,'position',[0.05 0.6  0.35 0.35]);
ax_s{2} = axes('Parent',f,'position',[0.50 0.6  0.35 0.35]);
ax_s{3} = axes('Parent',f,'position',[0.05 0.2  0.35 0.35]);
ax_s{4} = axes('Parent',f,'position',[0.50 0.2  0.35 0.35]);

b_area_min = uicontrol('Parent',f,'Style','edit','Position',[2,30,80,23],'String','0');
b_area_max = uicontrol('Parent',f,'Style','edit','Position',[90,30,80,23],'String','100000');
b_sizeguess = uicontrol('Parent',f,'Style','text','Position',[180,30,80,23],'String','0');
h = uicontrol('Position',[280 30 80 23],'String','Done','Callback','uiresume');

b_area_max.Callback = {@update_images_area,b_area_min,b_area_max,b_sizeguess,ax_s,im_array,bwMask,t_thresh,SE,fsize,background};
b_area_min.Callback = {@update_images_area,b_area_min,b_area_max,b_sizeguess,ax_s,im_array,bwMask,t_thresh,SE,fsize,background};

uiwait
area_min = str2double(b_area_min.String);
area_max = str2double(b_area_max.String);
sizeguess = str2double(b_sizeguess.String);
close(f)

end

function update_images_area(src,evnt,b_area_min,b_area_max,b_sizeguess,ax_s,im_array,bwMask,t_thresh,SE,fsize,background)
area_min = str2double(b_area_min.String);
area_max = str2double(b_area_max.String);
areas_tot = [];
for i=1:length(im_array)
    axes(ax_s{i});
    [bw] = get_thresholded_flies_px(im_array{i},t_thresh,bwMask,SE, area_min, area_max, fsize,background);
    imshow(immultiply(im_array{i},bwMask));
    hold on
    CC = bwconncomp(bw);
    areas  = regionprops(CC,'Area');
    areas = cat(1, areas.Area);
    CC.PixelIdxList([find(areas<area_min);find(areas>area_max)]) = [];
    for m=1:length(CC.PixelIdxList)
        areas_tot = cat(1,areas_tot,length(CC.PixelIdxList{m}));
        mask_temp = zeros(size(bw));
        mask_temp(ind2sub(size(bw),CC.PixelIdxList{m})) = 1;
        B = bwboundaries(mask_temp);
        boundary = B{1};
        plot(boundary(:,2), boundary(:,1), 'r', 'LineWidth', 1)
    end
    hold off
end
sizeguess = median(areas_tot);
set(b_sizeguess,'String',num2str(sizeguess));
axes(ax_s{end});
histogram(areas_tot)
end
