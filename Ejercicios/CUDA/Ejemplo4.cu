#include <stdio.h>
#include <stdlib.h>
#include <math.h>

__global__ void sumaMatrices(int *a, int *b, int *c, int N)
{
	int col = blockIdx.x * blockDim.x + threadIdx.x;
	int fil = blockIdx.y * blockDim.y + threadIdx.y;
	int indice = fil * N + col;
	if(fil<N&&col<N)
	{
		c[indice]=a[indice]+b[indice];
	}
}

int main (void)
{
	
	
	int *dev_a, *dev_b, *dev_c,*a,*b,*c;
	int T,div=2, iteraciones=10,ind=0;
	int N,i,j;
	float elapsedTime;
	printf("Ingrese el tamano de las matrices\n");
	scanf("%d",&N);
	
	
	a=(int*)malloc(N*N*sizeof(int));
	b=(int*)malloc(N*N*sizeof(int));
	c=(int*)malloc(N*N*sizeof(int));
	cudaMalloc((void**)&dev_a,N*N*sizeof(int));
	cudaMalloc((void**)&dev_b,N*N*sizeof(int));
	cudaMalloc((void**)&dev_c,N*N*sizeof(int));
	cudaEvent_t start,stop;
	cudaEventCreate(&start);
	cudaEventCreate(&stop);
	for(i=0;i<N;i++)
	{
		for(j=0;j<N;j++)
		{
			a[i*N+j]=i*N+j;
			b[i*N+j]=i*N+j;
			c[i*N+j]=0;
		}
	}
	cudaMemcpy(dev_a,a,N*N*sizeof(int),cudaMemcpyHostToDevice);
	cudaMemcpy(dev_b,b,N*N*sizeof(int),cudaMemcpyHostToDevice);
	// cada bloque en dimensión x y y tendrá un tamaño de T Threads
	while((float)N/(float)div>32)
	{
		div++;
	}
	float f_N=(float)N,f_div=(float)div;
	T=(int)ceil(f_N/f_div);
	dim3 ThreadsBloque(T,T);
	// El grid tendrá B números de bloques en x y y
	dim3 Bloques(div, div);
	printf("Se va a realizar la suma con %d bloques y %d hilos\n",div,T);
	cudaEventRecord(start,0);
	while(ind<iteraciones)
	{
		sumaMatrices<<<Bloques, ThreadsBloque>>>(dev_a,dev_b,dev_c,N);
		ind++;
	}
	
	cudaEventRecord(stop,0);
	cudaEventSynchronize(stop);
	cudaEventElapsedTime(&elapsedTime,start,stop);
	printf("El tiempo tomado para %d iteraciones fue de %3.3f ms\n",iteraciones,elapsedTime/10);
	cudaMemcpy(c,dev_c,N*N*sizeof(int),cudaMemcpyDeviceToHost);
	printf("Por ejemplo: \t%d\t+\t%d\t=%d\n",a[(int)N/2],b[(int)N/2],c[(int)N/2]);
	free(a);
	free(b);
	free(c);
	cudaFree(dev_a);
	cudaFree(dev_b);
	cudaFree(dev_c);
}