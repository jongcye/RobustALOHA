function [rimg_n,iterset]= aloha_patch(dimg,mask,mid,Nimg,Nfir,mu,muiter,H_gpu,Hi_gpu,tolE)

if mod(Nimg,2)==0
    hNimg=Nimg/2;
else
    hNimg=(Nimg-1)/2;
end

hNfir=(Nfir-1)/2;
Ny=size(dimg,1);
Nc=size(dimg,3);
rimg=zeros(size(dimg));
map_count=zeros(size(dimg));
m=(Nimg-Nfir+1)^2;
n=Nfir^2;

N=length(mid(:));
maskp=padarray(mask,[hNimg,hNimg]);

%% set parameters for LMaFit
opts = [];
opts.tol = tolE;
opts.maxit = 1e4;
opts.Zfull = 1;
opts.DoQR  = 1;
opts.print = 0;
opts.est_rank = 2;

%% patch based ALOHA
H   = @(inp) im2row(inp,[Nfir Nfir]);

iterset=zeros(N,1);
for iter=1:N
    %% Sliding patches
    ucur=mid(iter)-1;
    uy=mod(ucur,Ny)+1;
    ux=fix(ucur/Ny)+1;
    
    if mod(Nimg,2)==0
        roiy=uy-hNimg:uy+hNimg-1;
        roix=ux-hNimg:ux+hNimg-1;
        roiys=roiy(hNfir+1:end-hNfir);
        roixs=roix(hNfir+1:end-hNfir);
    else
        roiy=uy-hNimg:uy+hNimg;
        roix=ux-hNimg:ux+hNimg;
        roiys=roiy(hNfir+1:end-hNfir);
        roixs=roix(hNfir+1:end-hNfir);
    end
    
    rmask       = maskp(roiy,roix,:);
    mask_cmtx   = H(rmask);
    rval        = dimg(roiy,roix,:);
    cmtx        = H(rval);
    ids         = find(mask_cmtx==1);
    data_ids    = single(cmtx(ids));
    
    %% Initialization with LMaFit for initial U and V
    [U,V,~] = lmafit_mc_adp_single(m,n,1,ids,data_ids,opts);
    iterset(iter)=size(U,2);
    V=V';
    meas_id = find(rmask);
    meas    = rval(meas_id);
    
    %% Hankel structured matrix completion using ADMM
    U   = gpuArray(single(U));
    V   = gpuArray(single(V));
    meas= gpuArray(single(meas));
    X   = admm_hankel(U,V,meas,meas_id,mu,muiter,Nimg,Nfir,Nc,H_gpu,Hi_gpu);

    %% Aggregation
    rimg(roiys,roixs,:)       = rimg(roiys,roixs,:)+X(hNfir+1:end-hNfir,hNfir+1:end-hNfir,:);
    map_count(roiys,roixs,:)  = map_count(roiys,roixs,:)+1;
    display([num2str(iter) '/' num2str(N) ', rank : ' num2str(size(U,2))]);
end

%% normalization about overlapping
id=(map_count==0);
map_count(id)=1;
rimg_n      = rimg./map_count;
