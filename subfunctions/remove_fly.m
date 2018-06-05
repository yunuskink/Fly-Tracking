function [im] = remove_fly(im,fly,offset,min_thresh,area_min)

%This function removes a fly that has be found from the original image. The
%"min_thresh" value serves to remove only the values that are above a
%certain value of the fly.

fly_x = size(fly,2);
fly_y = size(fly,1);

fly = padarray(fly,[size(im,1),size(im,2)],0,'post');

fly = imtranslate(fly,[round(offset(1)-fly_x/2),round(offset(2)-fly_y/2)],'FillValues',0,'OutputView','same');

fly = fly(1:size(im,1),1:size(im,2));

im(fly>min_thresh) = 0;

L = bwlabel(im);
for i=1:max(L(:))
    if sum(sum(L==i))<area_min
        im(L==i)=0;
    end
end





