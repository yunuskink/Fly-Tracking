function [bwMask] = Get_Mask_mv(mov_name)

mv = VideoReader(mov_name);
im = rgb2gray(readFrame(mv));

figure;
imagesc(im);colormap('gray')

disp('Create rectangular ROI!')
hmask = impoly ;
disp('Double click rectangle to finish!')
wait(hmask);
disp('Computation...')
bwMask = createMask(hmask) ;

answer = questdlg('Is this mask good enough?','Mask choice','Yes','No, you try it','Yes');

close(gcf)

switch answer
    case 'Yes'
    case 'No, you try it'
        tot_frames = mv.framerate*mv.duration-10;
        num_sample_images = 100;
        rand_frames = datasample([1:tot_frames],num_sample_images);
        im = zeros(mv.Height,mv.Width,length(rand_frames));
        for i=1:length(rand_frames)
            mv.CurrentTime = rand_frames(i)/mv.framerate;
            im(:,:,i) = rgb2gray(readFrame(mv));
        end
        bwMask = Mask_Threshold(mean(im,3),im(:,:,1),bwMask);
        %Set a number of frames to consider for this thresholding step.
        SE = strel('disk',2) ;
        bwMask = imerode(bwMask,SE);
end
    
    
    
    
    
    
    
    
    

    