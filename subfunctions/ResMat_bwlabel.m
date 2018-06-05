function [ResMat] = ResMat_bwlabel(bw_label_mov, time)

N_flies = length(unique(bw_label_mov(:,:,1)))-1;

ResMat = zeros(N_flies*size(bw_label_mov,3),7);

ind = 1;

for i=1:500%size(bw_label_mov,3)
    stats = regionprops(bw_label_mov(:,:,i),'Centroid');
    for j=1:size(stats,1)
        ResMat(ind,2:3) = stats(j).Centroid;
        ResMat(ind,6) = i;
        ResMat(ind,7) = j;
        ResMat(ind,1) = time(i);
        ind = ind+1;
    end
end
