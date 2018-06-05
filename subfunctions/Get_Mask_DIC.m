function [bwMask] = Get_Mask_DIC(im)

figure ;
imshow(im(:,:,1),'InitialMagnification','fit');

disp('Create rectangular ROI!')
hmask = impoly ;
disp('Double click rectangle to finish!')
wait(hmask);
disp('Computation...')
bwMask = createMask(hmask) ;

close(gcf)
%Pass this image to a GUI that will let you set a minimum threshold for the
%brightness of the sum of all the images in a video.  This assumes the
%boundary is darker than the part of the chamber where the flies walk.
%bwMask = Mask_Threshold(Movie_sum,image,bwMask);
%SE = strel('disk',2) ;
%bwMask = imerode( bwMask,SE);
%end

bwMask = Mask_Threshold(mean(im,3),im(:,:,1),bwMask);
%Set a number of frames to consider for this thresholding step.
SE = strel('disk',2) ;
bwMask = imerode( bwMask,SE);

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    

    