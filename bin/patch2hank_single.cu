/*==========================================================
 * patch2hank.cu
 *
 * making block hankel matrix
 *
 * compile command
 * nvcc('patch2hank_single.cu -arch sm_35')
 *
 * This is a MEX-file for MATLAB.
 *
 *========================================================*/
/* $created: 11-Mar-2015 $ */

// #define fmin(a,b) ((a) < (b) ? (a) : (b))
// #define fmax(a,b) ((a) > (b) ? (a) : (b))
// #include "mex.h"
// #include "cuda.h"

__global__ void patch2hank_single(float* out,float* y,int sy,int sx,int sz,int firy, int firx)
{
    
    int idx = threadIdx.x+blockIdx.x*blockDim.x;
    int um=sy-firy+1;
    int un=firy;
    int ii=0,jj=0,zz=0,di=0,dj=0,ri=0,rj=0,pi=0,pj=0,k=0;
    if ( idx < (sy-firy+1)*(sx-firx+1)*firy*firx*sz )
    {
        zz=(int)(idx/((sy-firy+1)*(sx-firx+1)*firy*firx));
        k=idx%((sy-firy+1)*(sx-firx+1)*firy*firx);
        ii=k%((sy-firy+1)*(sx-firx+1));
        jj=(int)(k/((sy-firy+1)*(sx-firx+1)));        
        
        di=ii/um;
        dj=jj/un;
        
        ri=ii%um;
        rj=jj%un;
        
        pi= ri+rj;
        pj= di+dj;
        
        out[ii + jj*((sy-firy+1)*(sx-firx+1)) + zz*((sy-firy+1)*(sx-firx+1)*firy*firx)]=y[pi+pj*sy+zz*sy*sx];
    }
}