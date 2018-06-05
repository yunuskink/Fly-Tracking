function [protoflies_edge,protoflies_whole] = Master_proto_fly_multi_image(test_frames,ang_res,params)

names = fieldnames(params);
for i=1:size(names,1)
    eval(strcat(names{i},'=params.',names{i},';')); %Bad coding, but it gets all the variables out of params
end

CC_total = []; frame_ids = [];
for i=1:length(test_frames)
    im = test_frames{i};
    [bw] = threshold_flies_adapt(im,t_thresh,bwMask,SE,fsize,background);
    CC = bwconncomp(bw);
    
    areas  = regionprops(CC,'Area');
    areas = cat(1, areas.Area);
    CC.PixelIdxList([find(areas<area_min);find(areas>area_max)]) = [];
    
    CC = CC.PixelIdxList;
    CC_total = [CC_total,CC];
    frame_ids = [frame_ids, ones(1,length(CC))*i];
end

CC = CC_total;
[optimizer, metric] = imregconfig('monomodal');

fly = {};

frame = test_frames{1};
%max_dim = 0;
[y,x] = ind2sub(size(frame),CC{1});
mask = zeros(size(frame)); mask(CC{1}) = 1;
protofly_whole = double(frame);
protofly_whole(~mask) = 0;
%protofly_whole(setdiff(CC{1},[1:(size(protofly_whole,1)*size(protofly_whole,2))])) = 0;
protofly_whole = protofly_whole(min(y)-10:max(y)+10,min(x)-10:max(x)+10);
protofly_edge = double(bwmorph(protofly_whole,'remove'));

for i=1:length(CC)
    [y,x] = ind2sub(size(test_frames{frame_ids(i)}),CC{i});
    fly{i} = imcomplement(test_frames{frame_ids(i)});
    mask = zeros(size(test_frames{frame_ids(i)})); mask(CC{i}) = 1;
    fly{i}(~mask) = 0;
    %fly{i}(setdiff(CC{1},[1:(size(fly{i},1)*size(fly{i},2))])) = 0;
    fly{i} = fly{i}(min(y)-10:max(y)+10,min(x)-10:max(x)+10);
    fly{i} = imregister(fly{i},round(protofly_whole/i),'rigid',optimizer,metric);
    protofly_whole = protofly_whole + double(fly{i});
    protofly_edge = protofly_edge + bwmorph(fly{i},'remove');
    i/length(CC)
end

protofly_edge = round(255*protofly_edge./max(protofly_edge(:)));
protofly_whole = round(255*protofly_whole./max(protofly_whole(:)));
protofly_edge(protofly_edge<15)=0; protofly_whole(protofly_whole<15)=0;

protoflies_edge = {};
protoflies_whole = {};
for i=1:ang_res
    protoflies_edge{i} = double(imrotate(protofly_edge,360*i/ang_res,'nearest','loose'));
    protoflies_whole{i} = double(imrotate(protofly_whole,360*i/ang_res,'nearest','loose'));
end