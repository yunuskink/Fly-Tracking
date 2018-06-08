function [bins] = bin_square(mask,bins_x)

bins = uint8(mask);

[y,x] = ind2sub(size(mask),find(mask==1));
l_x = (max(x) - min(x))/bins_x;
l_y = (max(y) - min(y))/bins_x;
centers_x = round(min(x)+l_x/2:l_x:max(x));
centers_y = round(min(y)+l_y/2:l_x:max(y));

bin_id = 2;

for i=1:bins_x
    for j=1:bins_x
        bins(centers_y(i),centers_x(j)) = bin_id;
        bin_id = bin_id + 1;
    end
end

%Trying something different from the commented out code above.
[one_inds_x,one_inds_y] = find(mask==1);
one_inds = [one_inds_x, one_inds_y];
[inds_x,inds_y] = find(bins>1);
inds = [inds_x, inds_y];
n = nearestneighbour(one_inds',inds');
%[n,d]=knnsearch(inds,one_inds,'k',1,'distance','euclidean');
for i=1:size(inds,1)
    loc = find(n==i);
    loc = sub2ind(size(bins),one_inds_x(loc),one_inds_y(loc));
    bins(loc)=bins(inds(i,1),inds(i,2));
    
    %D = pdist2([inds_x, inds_y],[one_inds_x(i), one_inds_y(i)]);
    %ind = find(D==min(D));
    %bins(one_inds_x(i),one_inds_y(i)) = bins(inds_x(ind(1)),inds_y(ind(1)));
end

bin_ids = unique(bins);
%Get rid of 0
bin_ids = bin_ids(2:end);
bins_temp = zeros(size(bins));
for i=1:length(bin_ids)
    bins_temp(ind2sub(size(bins),find(bins==bin_ids(i))))=i;
end
bins=bins_temp;
