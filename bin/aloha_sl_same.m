function [recon,reconE,t_rec]=aloha_sl_same(param)

Nfir        = param.Nfir;
Nimg        = param.Nimg;
Nc          = param.Nc;
mu          = param.mu;
beta        = param.beta;
tau         = param.tau;
tolE        = param.tolE;
tolE_stop   = param.tolE_stop;
muiter      = param.muiter;
mask        = param.mask;
dimg        = param.dimg;
opt_inc     = param.opt_inc;

M           = Nimg;
N           = Nimg;
Mfir        = Nfir;

%% select scanning positions
[dimgp,vid,mid] = make_dsr(dimg,Nimg,Nfir);

%% setting GPU kernel
p=256;
func_p2h = parallel.gpu.CUDAKernel('patch2hank_single.ptx','patch2hank_single.cu');
func_p2h.ThreadBlockSize = p;
func_p2h.GridSize = ceil((M-Mfir+1)*(N-Nfir+1)*Mfir*Nfir*Nc/p);

func_h2p = parallel.gpu.CUDAKernel('hank2patch_single.ptx','hank2patch_single.cu');
func_h2p.ThreadBlockSize = p;
func_h2p.GridSize = ceil(M*N*Nc/p);

H   = @(out,inp) feval(func_p2h, out,inp,M,N,Nc,Mfir,Nfir);
Hi  = @(out,inp) feval(func_h2p, out,inp,M,N,Nc,Mfir,Nfir);

%% ALOHA - initialization, patch based low rank matrix completion
tic;
[rimg,rimgE]        = aloha_sl_sub_same(dimgp,mask,mid,Nimg,Nfir,Nc,...
    mu,beta,tau,tolE,tolE_stop,muiter,H,Hi,opt_inc);
t_rec=toc;
recon   = reshape(rimg(vid),size(dimg));
reconE   = reshape(rimgE(vid),size(dimg));

