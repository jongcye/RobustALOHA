function [dimgp,vid,mid]=make_dsr(dimg,Nimg,Nfir)
Nshrink=Nimg-Nfir+1;
if mod(Nimg,2)==0
    hNimg=Nimg/2;
else
    hNimg=(Nimg-1)/2;
end

[Ny,Nx,~]=size(dimg);
dimgp=padarray(dimg,[hNimg,hNimg]);

vmask=ones(size(dimg));
vmask=padarray(vmask,[hNimg,hNimg]);
vid=find(vmask==1);

mmask=zeros(size(dimg,1),size(dimg,2));

if mod(Nshrink,2)==0
    hNshrink=Nshrink/2;
    mmask(hNshrink+1:hNshrink:Ny-hNshrink+1,hNshrink+1:hNshrink:Nx-hNshrink+1)=1;
    mmask(hNshrink+1:hNshrink:Ny-hNshrink+1,Nx-hNshrink+1)=1;
    mmask(Ny-hNshrink+1,hNshrink+1:hNshrink:Nx-hNshrink+1)=1;
    mmask(Ny-hNshrink+1,Nx-hNshrink+1)=1;
else
    hNshrink=(Nshrink-1)/2;
    mmask(hNshrink+1:hNshrink:Ny-hNshrink,hNshrink+1:hNshrink:Nx-hNshrink)=1;
    mmask(hNshrink+1:hNshrink:Ny-hNshrink,Nx-hNshrink)=1;
    mmask(Ny-hNshrink,hNshrink+1:hNshrink:Nx-hNshrink)=1;
    mmask(Ny-hNshrink,Nx-hNshrink)=1;
end
mmask=padarray(mmask,[hNimg,hNimg]);
mid=find(mmask==1);
