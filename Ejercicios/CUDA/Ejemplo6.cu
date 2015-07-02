#include <stdio.h>
#include <stdlib.h>

__global__ void kernel(int *d, int n){
	__shared__ int s[64];
	int t =threadIdx.x;
	int tr=n-t-1;
	s[t]=d[t];
	__syncthreads();
	d[t]=s[tr];
}

int main (void)
{
	const int n=64;
	int a[n],r[n],d[n];
	for(int i=0;i<n;i++)
	{
		a[i]=i;
		r[i]=n-i-1;
		d[i]=0;
	}
	
	int *d_d;
	cudaMalloc(&d_d, n * sizeof(int));
	cudaMemcpy(d_d, a, n*sizeof(int), cudaMemcpyHostToDevice);
	kernel<<<1,n>>>(d_d, n);
	cudaMemcpy(d, d_d, n*sizeof(int), cudaMemcpyDeviceToHost);
	for (int i = 0; i < n; i++)
		if (d[i] != r[i])
			printf("Verificar- Hay un error");
	
	printf("En teoria 3 deberia ser igual a %d\n",d[n-3-1]);
}
