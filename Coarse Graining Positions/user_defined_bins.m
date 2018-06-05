function [bins] = user_defined_bins(bwMask,bin_num)

imagesc(bwMask)

bins = zeros(size(bwMask));

done = 0;

%done_btn = uicontrol('Style', 'pushbutton', 'String', 'Last One','Position', [20 20 50 20],'Callback','return');
for i=1:bin_num
    p = impoly;
    mask = createMask(p);
    bins(mask) = i;
end

bins = bins.*bwMask;

SE = strel('square',3);
while nnz(~bins.*bwMask)
    bins = imdilate(bins,SE);
end
