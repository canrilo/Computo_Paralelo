#include <stdio.h>
#include <stdlib.h>
#include <math.h>

// Kernel that executes on the CUDA device

__global__ void square_array(float *a, float *b, int N)
{
	int idx = blockIdx.x * blockDim.x + threadIdx.x;
	if (idx<N)
	{
		a[idx] = a[idx] * a[idx];
	} 
}

// main routine that executes on the host
int main(void)
{
	float elapsedTime;
	float *a, *a_d,*b,*b_d; // Pointer to host & device arrays
	const int N = 12; // Number of elements in arrays
	int ind=0,iteraciones=10;
	size_t size = N * sizeof(float);
	a = (float *)malloc(size); // Allocate array on host
	b = (float *)malloc(size); // Allocate array on host
	cudaMalloc((void **) &a_d, size); // Allocate array on device
	cudaMalloc((void **) &b_d, size); // Allocate array on device
	cudaEvent_t start,stop;
	cudaEventCreate(&start);
	cudaEventCreate(&stop);
	// Initialize host array and copy it to CUDA device
	for (int i=0; i<N; i++)
	{
		a[i] = (float)i;
		b[i] = (float)i+1;
	}		
	cudaMemcpy(a_d, a, size,cudaMemcpyHostToDevice);
	cudaMemcpy(b_d, b, size,cudaMemcpyHostToDevice);
	// Do calculation on device:
	int block_size = 4;
	int n_blocks = N/block_size;
	cudaEventRecord(start,0);
	while(ind<iteraciones)
	{
		square_array <<< n_blocks, block_size >>> (a_d,b_d, N);
		ind++;
	}
	cudaEventRecord(stop,0);
	cudaEventSynchronize(stop);
	cudaEventElapsedTime(&elapsedTime,start,stop);
	printf("El tiempo tomado para %d iteraciones fue de %3.3f ms\n",iteraciones,elapsedTime/10);
	// Retrieve result from device and store it in host array
	cudaMemcpy(a, a_d, sizeof(float)*N,cudaMemcpyDeviceToHost);
	/*// Print results
	for (int i=0; i<N; i++) 
		printf("%d %f\n", i, a[i]);
	*/
	// Cleanup
	free(a);
	free(b);
	cudaFree(a_d);
	cudaFree(b_d);
}