function [dimg,map]=make_rvin(img,d)

dimg=img;
[Ny,Nx]=size(dimg);
map=zeros(size(img));
tmp=zeros(2);
tmp_map=zeros(2);
switch d
    case 0.25
        for yiter=1:2:Ny
            for xiter=1:2:Nx
                tmp(:)=dimg(yiter:yiter+1,xiter:xiter+1);
                tmp_map(:)=0;
                id=randperm(4,1);
                
                tmp(id)=rand(1,1);
                tmp_map(id)=1;
                map(yiter:yiter+1,xiter:xiter+1)=tmp_map;
                dimg(yiter:yiter+1,xiter:xiter+1)=tmp;
            end
        end
    case 0.5
        for yiter=1:2:Ny
            for xiter=1:2:Nx
                tmp(:)=dimg(yiter:yiter+1,xiter:xiter+1);
                tmp_map(:)=0;
                id=randperm(4,2);
                
                tmp(id)=rand(1,2);
                tmp_map(id)=1;
                map(yiter:yiter+1,xiter:xiter+1)=tmp_map;
                dimg(yiter:yiter+1,xiter:xiter+1)=tmp;
            end
        end
    case 0.75
        for yiter=1:2:Ny
            for xiter=1:2:Nx
                tmp(:)=dimg(yiter:yiter+1,xiter:xiter+1);
                tmp_map(:)=0;
                id=randperm(4,3);
                
                tmp(id)=rand(1,3);
                tmp_map(id)=1;
                map(yiter:yiter+1,xiter:xiter+1)=tmp_map;
                dimg(yiter:yiter+1,xiter:xiter+1)=tmp;
            end
        end
end