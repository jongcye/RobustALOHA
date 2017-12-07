function [rimg_n,rimg_E]=...
    aloha_sl_sub_same(dimg,mask,mid,Nimg,Nfir,Nc,mu,beta,tau,...
    tolE,tolE_stop,muiter,H_gpu,Hi_gpu,opt_inc)

if mod(Nimg,2)==0
    hNimg=Nimg/2;
else
    hNimg=(Nimg-1)/2;
end

hNfir=(Nfir-1)/2;
Ny=size(dimg,1);
rimg=zeros(size(dimg));
rimg_E=rimg;
map_count=zeros(size(dimg));

N=length(mid(:));
maskp=padarray(mask,[hNimg,hNimg],0);
%% set parameters for LMaFit
opts = [];
opts.tol    = tolE;
opts.maxit  = 1e3;
opts.Zfull  = 1;
opts.DoQR   = 1;
opts.print  = 0;

%% patch based ALOHA
H   = @(inp) im2row(inp,[Nfir Nfir]);
for iter=1:N %fix(N/2)-10:fix(N/2)+40 %
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
    [m, n]=size(cmtx);
    opts.est_rank=2;
    [U,V,~] = lmafit_mc_adp_single(m,n,1,ids,data_ids,opts);
    r=size(U,2);
    %% Hankel structured matrix completion using ADMM
    meas_id = find(rmask);
    meas    = rval(meas_id);
    U   = gpuArray(single(U));
    V   = gpuArray(single(V'));
    [X,E,endi]=admm_hankel_sl_same(U,V,meas,meas_id,mu,beta,tau,muiter,Nimg,Nimg,Nc,tolE_stop,H_gpu,Hi_gpu);
    
    %% Aggregation
    rimg(roiys,roixs,:)       = rimg(roiys,roixs,:)+X(hNfir+1:end-hNfir,hNfir+1:end-hNfir,:);
    rimg_E(roiys,roixs,:)     = rimg_E(roiys,roixs,:)+E(hNfir+1:end-hNfir,hNfir+1:end-hNfir,:);
    map_count(roiys,roixs,:)  = map_count(roiys,roixs,:)+1;
    display([num2str(iter) '/' num2str(N) ', rank : ' num2str(r) ', iteration : ' num2str(endi)]);

end

%% normalization about overlapping
id=(map_count==0);
map_count(id)=1;
rimg_n      = rimg./map_count;
rimg_E      = rimg_E./map_count;
