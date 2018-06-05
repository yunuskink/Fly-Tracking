function [N_tot] = count_flies(im)
figure
imshow(im)
hold on
pos_f = [];
done = 0;
while ~done
    [x,y,button] = ginput(1);
    if button == 1;
        pos_f = [pos_f;x y];
        scatter(x,y,'g')
    else
        done = 1;
    end
end
close(gcf)
N_tot = size(pos_f,1);