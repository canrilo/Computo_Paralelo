#include <stdio.h>
#define N 10

__global__ void addvec(int *a, int *b, int *c)
{
	int tid=threadIdx.x; // Manejar todos los datos con este índice
	if(tid<N)
	{
		c[tid]=a[tid]+b[tid];
	}
}

int main(void)
{
	int a[N], b[N], c[N],i;
	int *dev_a, *dev_b, *dev_c;
	
	//Asignación de espacio en la memoria de GPU
	cudaMalloc((void**)&dev_a,N*sizeof(int));
	cudaMalloc((void**)&dev_b,N*sizeof(int));
	cudaMalloc((void**)&dev_c,N*sizeof(int));
	
	//Inicializar los datos originales en el CPU
	for (i = 0; i < N; i++)
	{
		a[i]=i*2;
		b[i]=i*2+1;
	}
	
	//Copia de vectores a la GPU
	cudaMemcpy(dev_a,a,N*sizeof(int),cudaMemcpyHostToDevice);
	cudaMemcpy(dev_b,b,N*sizeof(int),cudaMemcpyHostToDevice);

	//Se lanza el kernel
	addvec<<<1,N>>>(dev_a,dev_b,dev_c);
	
	//Se recuperan los datos de la GPU
	cudaMemcpy(c,dev_c,N*sizeof(int),cudaMemcpyDeviceToHost);
	
	//Se muestra el resultado
	for (i = 0; i < N; i++)
	{
		printf("%d+%d=%d\n",a[i],b[i],c[i]);
	}
	cudaFree(dev_a);
	cudaFree(dev_b);
	cudaFree(dev_c);
	
	return 0;
	
}
