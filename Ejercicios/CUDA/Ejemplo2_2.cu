#include <stdio.h>
#include <stdlib.h>
//#define N 16384

__global__ void addVecGrande(int *a, int *b, int *c, int N)
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
	int N,num_blocs,num_hilos,div;
	printf("Ingrese el tamano del vector (multiplo de 32)\n");
	scanf("%d",&N);
	if(N%32!=0){
		printf("El numero debe ser multiplo de 32\n");
		exit(1);
	}
	div=N/32;
	//asignar memoria en la GPU
	a=(int *)malloc(N*sizeof(int));
	b=(int *)malloc(N*sizeof(int));
	c=(int *)malloc(N*sizeof(int));
	cudaMalloc((void**)&dev_a,N*sizeof(int));
	cudaMalloc((void**)&dev_b,N*sizeof(int));
	cudaMalloc((void**)&dev_c,N*sizeof(int));
	
	for(int i=0; i<N;i++)
	{
		a[i]=i;
		b[i]=i+1;
	}
	if(div>128&&(div/4)%2==0)
	{
		num_blocs=128;
		num_hilos=N/128;
	} else{
		num_hilos=div;
		num_blocs=32;
	}
	//copiar el arreglo 'a' y 'b' en la GPU
	cudaMemcpy(dev_a,a,N*sizeof(int),cudaMemcpyHostToDevice);
	cudaMemcpy(dev_b,b,N*sizeof(int),cudaMemcpyHostToDevice);
	printf("Se van a ejecutar %d bloques con %d hilos\n",num_blocs,num_hilos);
	addVecGrande<<<num_blocs,num_hilos>>>(dev_a,dev_b,dev_c,N);
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