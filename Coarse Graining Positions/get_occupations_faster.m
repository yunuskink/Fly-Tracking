function [occupations,t_s] = get_occupations_faster(ResMat,bins)

%ResMat(ResMat(:,1)==0,:)=[];

for i=1:size(ResMat,1)
    ResMat(i,4) = bins(round(ResMat(i,3)),round(ResMat(i,2)));
end

if size(ResMat,2)>3
ResMat(ResMat(:,4)==0,:) = [];
end

[~,ind] = sort(ResMat(:,1),'Ascend');
ResMat = ResMat(ind,:);

chng_t = find(ResMat(2:end-1,1) - ResMat(1:end-2,1));
chng_t = [1; chng_t;size(ResMat,1)+1]; 

times = unique(ResMat(:,1));
%times = times(1:40:end);
occupations = zeros(length(chng_t)-1,(length(unique(bins(:)))-1));

num_bins = size(occupations,2);

for i=1:length(chng_t)-1
    occupations(i,:) = histcounts(ResMat(chng_t(i):chng_t(i+1)-1,4),[0.5:1:num_bins+0.5]);

end

t_s = times;
