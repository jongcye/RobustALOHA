/*==========================================================
 * patch2hank.cu
 *
 * making block hankel matrix
 *
 * compile command
 * nvcc('hank2patch_single.cu -arch sm_35')
 *
 * This is a MEX-file for MATLAB.
 *
 *========================================================*/
/* $created: 11-Mar-2015 $ */

// #define fmin(a,b) ((a) < (b) ? (a) : (b))
// #define fmax(a,b) ((a) > (b) ? (a) : (b))
// #include "mex.h"
// #include "cuda.h"

__global__ void hank2patch_single(float* out,float* y,int sy,int sx,int sz,int firy, int firx)
{
    
    int idx = threadIdx.x+blockIdx.x*blockDim.x;
    int um=sy-firy+1,bm=sx-firx+1;
    int un=firy,bn=firx;
    int ii=0,jj=0,zz=0,jid=0,iid=0,si=0,sj=0,ci=0,cj=0,k=0,m=0;
    if ( idx < sy*sx*sz )
    {
        zz=(int)(idx/(sy*sx));
        k=idx%(sy*sx);
        ii=k%(sy);
        jj=(int)(k/sy);        
        out[ii + jj*sy + zz*sy*sx]=(float)0.0f;
        for (jid=0;jid<=jj;jid++)
        {
                if ((jid<bm) && ((jj-jid) <bn))
                {
                    si=jid*um;
                    sj=(jj-jid)*un;
                    for (iid=0;iid<=ii;iid++)
                    {
                        if ((iid<um) && ((ii-iid) <un))
                        {
                            ci=si+iid;
                            cj=sj+(ii-iid);
                            out[ii + jj*sy + zz*sy*sx]+=y[ci+cj*um*bm+zz*um*bm*un*bn];
                            m+=1;
                        }
                    }
                }
        }
        out[ii + jj*sy + zz*sy*sx]/=(float)m;
    }
}