#include <stdio.h>
#include <stdlib.h>
#define N 256
__global__ void kernel(int *a, int *b, int *c){
	__shared__ int s[N];
	__shared__ int r[N];
	int t =threadIdx.x;
	r[t]=b[t];
	s[t]=a[t];
	__syncthreads();
	c[t]=s[t]+r[t];
}

int main (void)
{
	//const int n=64;
	int a[N],c[N],b[N],i;
	for(i=0;i<N;i++)
	{
		a[i]=i;
		b[i]=N-i-1;
		c[i]=0;
	}
	
	int *a_d,*b_d, *c_d;
	cudaMalloc(&a_d, N * sizeof(int));
	cudaMalloc(&b_d, N * sizeof(int));
	cudaMalloc(&c_d, N * sizeof(int));
	cudaMemcpy(a_d, a, N*sizeof(int), cudaMemcpyHostToDevice);
	cudaMemcpy(b_d, b, N*sizeof(int), cudaMemcpyHostToDevice);
	kernel<<<1,N>>>(a_d, b_d,c_d);
	cudaMemcpy(c, c_d, N*sizeof(int), cudaMemcpyDeviceToHost);
	for (i = 1; i < N; i++)
		if (c[i] != c[i-1])
			printf("Verificar- Hay un error");
	
	cudaFree(a_d);
	cudaFree(b_d);
	cudaFree(c_d);
}
