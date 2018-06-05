function [bw, CC, CC_large] = get_thresholded_flies_px(im,t_thresh,bwMask,SE, area_min, area_max, fsize,background)
%This takes in an image and outputs the bw thresholded image along with
%it's connected components.  If area_min and area_max are passed in, it
%gets rid of any cc's that are not in that range.

%Threshold the flies into a binary image and do some basic image
%processing.
%background = 256;
[bw] = threshold_flies_adapt(im,t_thresh,bwMask,SE,fsize, background);

%CC = bwconncomp(bw);
%Get rid of connected components that are the holes in between flies, such
%an annoying problem! This gets rid of connected components whose mean
%intensity in above the right value.
%intensities = regionprops(CC,im,'MeanIntensity');
%intensities = find([intensities.MeanIntensity]>t_thresh);
%CC_large = CC;
%areas  = regionprops(CC,'Area');
%areas = cat(1, areas.Area);
%CC.PixelIdxList([intensities';find(areas<area_min);find(areas>area_max)]) = [];
%CC_large.PixelIdxList([intensities';find(areas<area_max)]) = [];