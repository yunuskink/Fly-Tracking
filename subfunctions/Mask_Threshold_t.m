function [bwMask] = Mask_Threshold_t(sum_im,samp_im,bwMask)

blah='Choose mask'

f = figure;
ax = axes('Parent',f,'position',[0.13 0.39  0.77 0.54]);

imshow(immultiply(samp_im,bwMask));

b = uicontrol('Parent',f,'Style','slider','Position',[81,54,419,23],'value',0, 'min',0, 'max',1);
SE_ui = uicontrol('Parent',f,'Style','edit','Position',[240,20,200,40],'String',2);

b.Callback = {@update_mask_im,sum_im,bwMask,samp_im,b,SE_ui};
SE_ui.Callback = {@update_mask_im,sum_im,bwMask,samp_im,b,SE_ui};

h = uicontrol('Position',[20 20 200 40],'String','Done','Callback','uiresume');

uiwait

bwMask(sum_im<=(b.Value*max(max(sum_im)))) = 0;
SE = strel('disk',str2num(SE_ui.String));
bwMask = imclose(bwMask,SE);
bwMask = imerode(bwMask,SE);
close(f);
end

function update_mask_im(src,evnt,sum_im,bwMask,samp_im,b,SE_ui)
bwMask_thresh = bwMask;
thresh = b.Value;
bwMask_thresh(sum_im<=(thresh*max(max(sum_im)))) = 0;
SE = strel('disk',str2num(SE_ui.String));
bwMask_thresh = imclose(bwMask_thresh,SE);
bwMask_thresh = imerode(bwMask_thresh,SE);
imshow(samp_im);
hold on;
%RGBin = ~bwMask_thresh.*255;
%RGBin(end, end, 3) = 0;  % All information in red channel
%himin=imshow(RGBin);
%set(himin,'AlphaData',0.2);
RGBout = bwMask_thresh.*255;
RGBout(end, end, 3) = 0;  % All information in red channel
himout=imshow(RGBout);
set(himout,'AlphaData',0.6);
hold off
end