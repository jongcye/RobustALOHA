%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GPU version !!
% application : Random Vvalued Impulsive Noise (RVIN)
% rALOHA for grey images
% 10 DEC 2017, written by Kyong Hwan, Jin
% kyonghwan.jin@gmail.com
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
restoredefaultpath;clear;close all;home;
% gpuDevice(1);
addpath('./bin/');
if ~exist('./bin/hank2patch_single.ptx','file') || ~exist('./bin/patch2hank_single.ptx','file')
    compile_gpu;
end

rvin_density=[0.25 0.4];
tolE_set=[2e-1 3e-1];
tau=1e-1;

diter=2;
for iter=2
    %% reading images & adaptive hyper params
    switch iter
        case 1
            img=double(imread('./test_images/baboon512.jpg'));dname='baboon';
            Nfir=13;Nimg=45;if diter==2,tau=0.75e-1;end
        case 2
            img=double(imread('./test_images/barbara.png'));dname='barbara';
            Nfir=11;Nimg=25;
        case 3
            img=double(imread('./test_images/boat.png'));dname='boat';
            Nfir=11;Nimg=25;
        case 4
            img=double(imread('./test_images/cameraman.tif'));dname='cameraman';
            Nfir=13;Nimg=31;if diter==2,tau=0.75e-1;end
        case 5
            img=double(imread('./test_images/house.png'));dname='house';
            if diter==1
                Nfir=11;Nimg=25;
            else
                Nfir=13;Nimg=45;
            end
            if diter==2,tau=0.75e-1;end
        case 6
            img=double(imread('./test_images/lena.png'));dname='lena';
            Nfir=11;Nimg=25;
        case 7
            img=double(imread('./test_images/peppers256.png'));img=img(2:end-1,2:end-1);dname='peppers';
            if diter==2,tau=0.75e-1;end
    end
    
    
    %% insertion of RVIN
    maxval=255;
    img = img/maxval;
    d=rvin_density(diter); % noise density
    id=randperm(length(img(:)),fix(d*length(img(:))));
    map=zeros(size(img));
    map(id)=1;
    dimg=img;
    dimg(map==1)=rand(fix(d*length(img(:))),1);
    
    
    %% hyper parameters
    tolE=tolE_set(diter);
    mask=ones(size(dimg));
    param=struct('iname',dname,'mask',mask,'dimg',dimg,...
        'mu',1e0,'beta',1e0,'tau',tau,...
        'tolE',tolE,'tolE_stop',1e-4,...
        'muiter',50,'Nimg',Nimg,'Nfir',Nfir,'d',d,'Nc',1,...
        'maxval',255,'opt_inc','inc');
    
    
    %% rALOHA
    [recon,reconE,t_pro] = aloha_sl(param);
    error = img - recon;
    psnr_aloha = 10*log10(1/mean((error(:)).^2));
    display(['PSNR (ALOHA) : ' num2str(psnr_aloha,4)])
    
end