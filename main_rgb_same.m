%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GPU version !!
% application : multichannel RVIN of common pixel locations
% rALOHA for RGB images
%
% 10 DEC 2017, written by Kyong Hwan, Jin
% kyonghwan.jin@gmail.com
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
restoredefaultpath;clear;close all;home;
addpath('./bin/');
if ~exist('./bin/hank2patch_single.ptx','file') || ~exist('./bin/patch2hank_single.ptx','file')
    compile_gpu;
end

%%
Nfir=9;
Nimg=25;

%%
img_raw=double(imread('./test_images/PeppersRGB.bmp'));dname='peppers_rgb_same';
img=imresize(img_raw,0.5);img=img(2:end-1,2:end-1,:);
[ny,nx,nc]=size(img);

maxval=255;
img = img/maxval;
d=0.3; % noise density
id=randperm(ny*nx,fix(d*ny*nx));
map=zeros(ny,nx);
map(id)=1;
map=repmat(map,[1 1 nc]);
dimg=img;
dimg(map==1)=rand(fix(d*ny*nx)*nc,1);

error = double(img - dimg);
psnr_dimg = 10*log10(1/mean(error(:).^2));
display(['PSNR (noisy) : ' num2str(psnr_dimg,4)])

%%
tolE=2e-1;
tau=1e-1;
mu=1e0;

mask=ones(size(dimg));
param=struct('iname',dname,'mask',mask,'dimg',dimg,...
    'mu',mu,'beta',1e0,'tau',tau,...
    'tolE',tolE,'tolE_stop',1e-4,...
    'muiter',5e2,'Nimg',Nimg,'Nfir',Nfir,'d',d,'Nc',nc,...
    'maxval',maxval,'opt_inc','inc');

%% rALOHA
[recon,reconE,t_pro] = aloha_sl_same(param);
error = img - recon;
psnr_aloha = 10*log10(1/mean((error(:)).^2));
display(['PSNR (ALOHA) : ' num2str(psnr_aloha,4)])

