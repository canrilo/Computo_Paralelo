#include <stdio.h>
#include <stdlib.h>
#define N 16384

__global__ void addVecGrande(int *a, int *b, int *c)
	{
		int tid=threadIdx.x+blockIdx.x*blockDim.x;
		if(tid<N)
		{
			c[tid]=a[tid]+b[tid];
		}
	}

int main (void)
{
	
	int *dev_a, *dev_b, *dev_c,*a,*b,*c;
	float elapsedTime;
	//asignar memoria en la GPU
	a=(int *)malloc(N*sizeof(int));
	b=(int *)malloc(N*sizeof(int));
	c=(int *)malloc(N*sizeof(int));
	cudaMalloc((void**)&dev_a,N*sizeof(int));
	cudaMalloc((void**)&dev_b,N*sizeof(int));
	cudaMalloc((void**)&dev_c,N*sizeof(int));
	cudaEvent_t start,stop;
	cudaEventCreate(&start);
	cudaEventCreate(&stop);
	for(int i=0; i<N;i++)
	{
		a[i]=i;
		b[i]=i+1;
	}
	//copiar el arreglo 'a' y 'b' en la GPU
	cudaMemcpy(dev_a,a,N*sizeof(int),cudaMemcpyHostToDevice);
	cudaMemcpy(dev_b,b,N*sizeof(int),cudaMemcpyHostToDevice);
	printf("Se van a ejecutar 128 bloques con 128 hilos\n");
	cudaEventRecord(start,0);
	addVecGrande<<<128,128>>>(dev_a,dev_b,dev_c);
	cudaEventRecord(stop,0);
	cudaEventSynchronize(stop);
	cudaEventElapsedTime(&elapsedTime,start,stop);
	printf("El tiempo tomado fue de %3.3f ms\n",elapsedTime);
	cudaMemcpy(c,dev_c,N*sizeof(int),cudaMemcpyDeviceToHost);
	printf("En el renglon 0: \t%d\t+\t%d\t=\t%d\n",a[0],b[0],c[0]);
	printf("En el renglon 10: \t%d\t+\t%d\t=\t%d\n",a[10],b[10],c[10]);
	printf("En el renglon %d: \t%d\t+\t%d\t=\t%d\n",N,a[N-1],b[N-1],c[N-1]);
	
	printf("Se van a ejecutar 256 bloques con 64 hilos\n");
	cudaEventRecord(start,0);
	addVecGrande<<<256,64>>>(dev_a,dev_b,dev_c);
	cudaEventRecord(stop,0);
	cudaEventSynchronize(stop);
	cudaEventElapsedTime(&elapsedTime,start,stop);
	printf("El tiempo tomado fue de %3.3f ms\n",elapsedTime);
	cudaMemcpy(c,dev_c,N*sizeof(int),cudaMemcpyDeviceToHost);
	printf("En el renglon 0: \t%d\t+\t%d\t=\t%d\n",a[0],b[0],c[0]);
	printf("En el renglon 10: \t%d\t+\t%d\t=\t%d\n",a[10],b[10],c[10]);
	printf("En el renglon %d: \t%d\t+\t%d\t=\t%d\n",N,a[N-1],b[N-1],c[N-1]);
	
	printf("Se van a ejecutar 32 bloques con 512 hilos\n");
	cudaEventRecord(start,0);
	addVecGrande<<<32,512>>>(dev_a,dev_b,dev_c);
	cudaEventRecord(stop,0);
	cudaEventSynchronize(stop);
	cudaEventElapsedTime(&elapsedTime,start,stop);
	printf("El tiempo tomado fue de %3.3f ms\n",elapsedTime);
	cudaMemcpy(c,dev_c,N*sizeof(int),cudaMemcpyDeviceToHost);
	printf("En el renglon 0: \t%d\t+\t%d\t=\t%d\n",a[0],b[0],c[0]);
	printf("En el renglon 10: \t%d\t+\t%d\t=\t%d\n",a[10],b[10],c[10]);
	printf("En el renglon %d: \t%d\t+\t%d\t=\t%d\n",N,a[N-1],b[N-1],c[N-1]);
	
	free(a);
	free(b);
	free(c);
	cudaFree(dev_a);
	cudaFree(dev_b);
	cudaFree(dev_c);
	return 0;
}