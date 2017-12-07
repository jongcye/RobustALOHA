%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GPU version !!
% application : salt & pepper
% rALOHA for grey images
% *****
% adaptive median filtering is given by Dr. Nikolova :
% R. H. Chan, C.-W. Ho, and M. Nikolova, ?Salt-and-pepper noise
% removal by median-type noise detectors and detail-preserving
% regularization,? IEEE Trans. Image Process., vol. 14, no. 10,
% pp. 1479?1485, 2005.
% *****
% 10 DEC 2017, written by Kyong Hwan, Jin
% kyonghwan.jin@gmail.com
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
restoredefaultpath;clear;close all;home;
addpath('./bin/');
if ~exist('./bin/hank2patch_single.ptx','file') || ~exist('./bin/patch2hank_single.ptx','file')
    compile_gpu;
end

%% load mask & image - Nfir should be odd number.
img=double(imread('./test_images/house.png'));
maxval=255;
img = img/maxval;
noise_density=0.7; % noise density
[dimg,map]=make_saltpepper(img,noise_density);

error = img - dimg;
psnr_dimg = 10*log10(1/mean(error(:).^2));
display(['PSNR (noisy) : ' num2str(psnr_dimg,4)])

%%
mask=ones(size(dimg));
param=struct('iname','saltpeppers_house','mask',mask,'dimg',dimg, ...
    'mu',1e0,'beta',1e0,'tau',.8e-1,...
    'tolE',3e-1,'tolE_stop',1e-4,...
    'muiter',5e1,'Nimg',25,'Nfir',9,'Nc',1,'d',noise_density,...
    'maxval',maxval,'ref',img,...
    'opt_inc','inc'); 

%% AM-ALOHA denoising
param.mask=(1-adpmedian(dimg*maxval));
param.tolE=1e-4;
param.muiter=5e1;
param.Nimg=35;
param.Nfir=13;
param.mu=10;
[recon_amaloha,t_pro] = aloha(param);
error       = img - recon_amaloha;
psnr_amaloha    = 10*log10(1/mean(error(:).^2));
display(['Elapsed time : ' num2str(t_pro,4) 's'])
display(['PSNR (AM-ALOHA): ' num2str(psnr_amaloha,4)])
