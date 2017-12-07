function [recon,t_rec]=aloha(param)

Nfir    = param.Nfir;
Nimg    = param.Nimg;
mu      = param.mu;
muiter  = param.muiter;
mask    = param.mask;
dimg    = param.dimg;
[Ny,Nx] = size(dimg);
tolE    = param.tolE;
M       = Nimg;
N       = Nimg;
Mfir    = Nfir;
%% select scanning positions
[dimgp,vid,mid] = make_dsr(dimg,Nimg,Nfir);

%% setting GPU kernel
p=256;
func_p2h = parallel.gpu.CUDAKernel('patch2hank_single.ptx','patch2hank_single.cu');
func_p2h.ThreadBlockSize = p;
func_p2h.GridSize = ceil((M-Mfir+1)*(N-Nfir+1)*Mfir*Nfir/p);

func_h2p = parallel.gpu.CUDAKernel('hank2patch_single.ptx','hank2patch_single.cu');
func_h2p.ThreadBlockSize = p;
func_h2p.GridSize = ceil(M*N/p);

H   = @(out,inp) feval(func_p2h, out,inp,M,N,1,Mfir,Nfir);
Hi  = @(out,inp) feval(func_h2p, out,inp,M,N,1,Mfir,Nfir);

%% ALOHA - initialization, patch based low rank matrix completion
tic;
rimg        = aloha_patch(dimgp,mask,mid,Nimg,Nfir,mu,muiter,H,Hi,tolE);
t_rec=toc;

recon   = reshape(rimg(vid),Ny,Nx);


