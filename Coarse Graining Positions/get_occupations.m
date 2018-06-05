function [occupations,t_s] = get_occupations(ResMat,bins)

ResMat(ResMat(:,1)==0,:)=[];

for i=1:size(ResMat,1)
    ResMat(i,4) = bins(round(ResMat(i,3)),round(ResMat(i,2)));
end

times = unique(ResMat(:,1));
%times = times(1:40:end);
occupations = zeros(length(times),(length(unique(bins(:)))-1));

ResMat(ResMat(:,4)==0,:) = [];

num_bins = size(occupations,2);

for i=1:length(times)
    occupations(i,:) = histcounts(ResMat(ResMat(:,1) == times(i),4),[0.5:1:num_bins+0.5]);
end

t_s = times;
