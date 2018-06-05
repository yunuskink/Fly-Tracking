function [bw, CC, CC_large] = get_thresholded_flies(im,t_thresh,bwMask,SE, area_min, area_max, fsize,background)
%This takes in an image and outputs the bw thresholded image along with
%it's connected components.  If area_min and area_max are passed in, it
%gets rid of any cc's that are not in that range.

%Threshold the flies into a binary image and do some basic image
%processing.
%[bw] = threshold_flies_adapt(im,t_thresh,bwMask,SE,filt_size, 256);
%[bw] = threshold_flies(im,t_thresh,bwMask,SE,filt_size);
[bw] = threshold_flies_adapt(im,t_thresh,bwMask,SE,fsize, background);
CC = bwconncomp(bw);
%Get rid of connected components that are the holes in between flies, this gets rid of connected components whose mean
%intensity in above the right value.
%intensities = regionprops(CC,im,'MeanIntensity');
%intensities = find([intensities.MeanIntensity]>t_thresh);
CC_large = CC;
areas  = regionprops(CC,'Area');
areas = cat(1, areas.Area);
small = find(areas<area_min);
for i=1:length(small)
    bw(cell2mat(CC.PixelIdxList(small(i))))=0;
end
CC.PixelIdxList([find(areas<area_min);find(areas>area_max)]) = [];
CC_large.PixelIdxList([find(areas<area_max)]) = [];
