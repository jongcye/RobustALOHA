function X=admm_hankel(U,V,meas,meas_id,mu,muiter,Nimg,Nfir,Nc,H,Hi)

r=size(U,2);
I_gpu=gpuArray(eye(r,'single'));
X=gpuArray(zeros(Nimg,Nimg,Nc,'single'));
L=gpuArray(zeros((Nimg-Nfir+1)^2,Nfir^2*Nc,'single'));
Hx=L;

for iter=1:muiter
    X=Hi(X,U*V'-L);
    X(meas_id)=meas;
    
    Hx=H(Hx,X);
    HXL=mu*(Hx+L);
    
    U=HXL*V/(I_gpu+mu*V'*V);
    V=HXL'*U/(I_gpu+mu*U'*U);
    L=Hx-U*V'+L;
end

X(meas_id)=meas;
X=gather(X);