function [Res_down]=Downsample_ResMat(ResMat,dt)

times = unique(ResMat(:,1));
t_s = 0:dt:max(ResMat(:,1))-dt;
%Now find all the times that are closest to the t_s
down_times = zeros(size(t_s));
for i=1:length(t_s)
    [mn,ind] = min(abs(times-t_s(i)));
    down_times(i) = times(ind(1));
end

down_times = unique(down_times);

Res_down = ResMat(ismember(ResMat(:,1),down_times),:);