function [X,E,iter]=admm_hankel_sl(U,V,meas,meas_id,mu,beta,tau,tN,sizeM,sizeN,Nc,tolE,H,Hi)
meas_gpu=gpuArray(single(meas));
r=size(U,2);
I_gpu=gpuArray(single(eye(r)));

X=gpuArray(zeros(sizeM,sizeN,Nc,'single'));
Lambda=gpuArray(zeros(size(U,1),size(V,1),'single'));
Hx=Lambda;
E=X;
Theta=X;
M=X;
M(meas_id)=meas_gpu;

Xpre=X;
norm_meas=norm(meas_gpu);
tolE_gpu=gpuArray(tolE);
uv_p=X;

%%
opt_inv='direct';   % 'direct'/'QR'/'chol'/'approx'
for iter=1:tN
    E=M-X-Theta;
    E=sign(E).*max(abs(E)-tau/beta,0);

    X=1/(beta+mu)*(mu*Hi(uv_p,U*V'-Lambda) - beta*(E-M+Theta));
    
    % hard coded stopping rule
    relres=norm(meas_gpu-X(meas_id)-E(meas_id))/norm_meas;
    reschg=abs(1-norm(meas_gpu-X(meas_id)-E(meas_id))/norm(meas_gpu-Xpre(meas_id)));
    if  relres < tolE_gpu || reschg<tolE_gpu/2
        X=gather(X);
        E=gather(E);
        return;
    end
    
    
    Hx=H(Hx,X);
    switch opt_inv
        case 'direct'
            % direct inverse
            U=(mu*(Hx+Lambda)*V)/(I_gpu+mu*V'*V);
            V=(mu*(Hx+Lambda)'*U)/(I_gpu+mu*U'*U);
        case 'approx'
            uu=mu*V'*V;
            U=(mu*(Hx+Lambda)*V)*(I_gpu-uu+uu^2);
            vv=mu*U'*U;
            V=(mu*(Hx+Lambda)'*U)*(I_gpu-vv+vv^2);
        case 'chol'
            % using cholesky factorization
            cu=inv(chol(I_gpu+mu*V'*V,'lower'));
            mcu=cu'*cu;
            cv=inv(chol(I_gpu+mu*U'*U,'lower'));
            mcv=cu'*cu;
            
            U=(mu*(Hx+Lambda)*V)*mcu;
            V=(mu*(Hx+Lambda)'*U)*mcv;
            
        case 'QR'
            % using QR & SVD
            [Qv,Rv]=qr(V,0);
            [uv, sv, vv]=svd(Rv,0);
            if sum(isnan(uv(:)))~=0
                break;
            end
            U=mu*(Hx+Lambda)*Qv*uv*(sv./(1+mu*sv.^2))*vv';
            
            [Qu,Ru]=qr(U,0);
            [uu, su, vu]=svd(Ru,0);
            if sum(isnan(uu(:)))~=0
                break;
            end
            V=mu*(Hx+Lambda)'*Qu*uu*(su./(1+mu*su.^2))*vu';
    end
    Lambda=Hx-U*V'+Lambda;
    Theta=X+E-M+Theta;
    Xpre=X+E;
end
X=gather(X);
E=gather(E);
