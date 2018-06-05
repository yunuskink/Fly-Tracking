function [bw] = threshold_flies_adapt(im,t_thresh,bwMask,SE,fsize, background)

%I do this in so many different place and have fiddled with it so much it makes sense to put it in a separate function.

%Set the boundary to be white. This affects the adaptive thresholding at
%the edge and whould instead be set to whatever the mean background value
%is. Should fix this.
%background = 256;
im(bwMask==0) = background; 
bw = adaptivethresh(im,fsize,t_thresh);
bw(bwMask==0) = 1;
%bw = imopen(bw,SE);
%bw = imopen(bw,SE);
%bw = imopen(bw,SE);
bw = ~bw;
%bw = imclose(bw,SE);
%bw = immultiply(bwMask,bw);
%Separate clumped flies using a watershed.
%bw = watershed(immultiply(imgaussfilt(im,filt_size,'FilterDomain','frequency'),uint8(bw)));