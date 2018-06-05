function [pixel2cm] = get_scale_t(im)

%Choose a distance from your video which you know the dimensions of, then
%run this function with a call to "movie", the location of the video file,
%and "cm", the length in centimeters of the object you are measuring.  

%pixels2cm = length in pixels of object/cm

cm = inputdlg('Enter distance in cm of real world object', 'Scaling', [1 50]); 
figure;
imshow(im);
line=imline;
wait(line);
pos = line.getPosition();
pixels = sqrt((pos(1,1)-pos(2,1))^2 + (pos(1,2)-pos(2,2))^2);
pixel2cm = pixels/str2num(cm{1});
close(gcf)