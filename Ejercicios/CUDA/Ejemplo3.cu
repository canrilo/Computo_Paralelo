#include <stdio.h>
#include <stdlib.h>
//#define N 16384

__global__ void addCincoVec(int *a, int N)
	{
		int tid=threadIdx.x+blockIdx.x*blockDim.x;
		if(tid<N)
		{
			a[tid]=a[tid]+5;
		}
	}

int main (void)
{
	
	int *dev_a,*a;
	int N,num_blocs,num_hilos;
	float elapsedTime;
	printf("Ingrese el tamano del vector\n");
	scanf("%d",&N);
	//asignar memoria en la GPU
	a=(int *)malloc(N*sizeof(int));
	cudaMalloc((void**)&dev_a,N*sizeof(int));
	cudaEvent_t start,stop;
	cudaEventCreate(&start);
	cudaEventCreate(&stop);
	for(int i=0; i<N;i++)
	{
		a[i]=i;
	}
	if(N>1024){
		num_blocs=(int)(N/1024)+1;
		num_hilos=1024;
	}else{
		num_blocs=1;
		num_hilos=N;
	}
	//copiar el arreglo 'a' y 'b' en la GPU
	cudaMemcpy(dev_a,a,N*sizeof(int),cudaMemcpyHostToDevice);
	printf("Se van a ejecutar %d bloques con %d hilos\n",num_blocs,num_hilos);
	cudaEventRecord(start,0);
	addCincoVec<<<num_blocs,num_hilos>>>(dev_a,N);
	cudaEventRecord(stop,0);
	cudaEventSynchronize(stop);
	cudaEventElapsedTime(&elapsedTime,start,stop);
	printf("El tiempo tomado fue de %3.3f ms\n",elapsedTime);
	cudaMemcpy(a,dev_a,N*sizeof(int),cudaMemcpyDeviceToHost);
	printf("En el renglon 0: %d\n",a[0]);
	printf("En el renglon %d: %d\n",(int)N/2,a[(int(N/2))]);
	printf("En el renglon %d: %d\n",N-1,a[N-1]);
	free(a);
	cudaFree(dev_a);
	return 0;
}