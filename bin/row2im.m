%% from ESPIRiT open sources (http://www.eecs.berkeley.edu/~mlustig/Software.html)

function [res,W] = row2im(mtx,imSize, winSize)

sz = imSize(3);
sx = imSize(1); sy = imSize(2);
res = zeros(imSize(1),imSize(2),imSize(3));
W = res;
mtx = reshape(mtx,size(mtx,1),[],sz);
count=0;
for y=1:winSize(2)
    for x=1:winSize(1)
        count = count+1;
        res(x:sx-winSize(1)+x,y:sy-winSize(2)+y,:) = res(x:sx-winSize(1)+x,y:sy-winSize(2)+y,:) + reshape(mtx(:,count,:),(sx-winSize(1)+1),(sy-winSize(2)+1),sz);
        W(x:sx-winSize(1)+x,y:sy-winSize(2)+y,:) = W(x:sx-winSize(1)+x,y:sy-winSize(2)+y,:)+1;
    end
end

res = res./W;
