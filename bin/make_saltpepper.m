function [dimg,map]=make_saltpepper(img,d)

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
                
                tmp(id)=double(rand(1,1)<0.5);
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
                
                tmp(id)=double(rand(1,2)<0.5);
                tmp_map(id)=1;
                map(yiter:yiter+1,xiter:xiter+1)=tmp_map;
                dimg(yiter:yiter+1,xiter:xiter+1)=tmp;
            end
        end
    otherwise
        map(randperm(Ny*Nx,fix(Ny*Nx*d)))=1;
        dimg(map==1)=double(rand(fix(Ny*Nx*d),1)<0.5);
end