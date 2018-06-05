function [C] = cross_correlation(im,protoflies,mask)

C = zeros(size(im,1),size(im,2),length(protoflies));
C = double(C);
for j=1:length(protoflies)
    im_temp = conv2(double(im),protoflies{j},'same');
    %im_temp(~mask) = 0; %Don't allow finding flies where there are none.
    C(:,:,j) = im_temp;
end

C = 255.*C/max(C(:));