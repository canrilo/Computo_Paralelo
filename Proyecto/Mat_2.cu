#include <stdio.h>
#include <stdlib.h>
#include <math.h>

__global__ void matrixMultGPU(int *a, int *b, int *c,int N)
{
	int tx = threadIdx.x;
	int ty = threadIdx.y;
	float sum=0;
	for (int k = 0; k < N; k++) 
	{
		float Ael= a[ty * N + k];
		float Bel= b[k * N + tx];
		sum += Ael*Bel;
	}
	c[ty * N + tx] = sum;
}


int main (void){
	//Creación de variables del sistema
	int *a, *b, *c, *dev_a, *dev_b, *dev_c, N;
	int i,j;
	int T,div=1, iteraciones=100,ind=0;
	float elapsedTime;
	printf("Ingrese el tamano deseado para las matrices:\n");
	scanf("%d",&N);
	
	//Creación de variables de tiempo
	cudaEvent_t start,stop;
	cudaEventCreate(&start);
	cudaEventCreate(&stop);
	
	printf("Creando espacio e inicializando matrices...\n");
	
	//Asignación e inicialización de memoria
	a=(int*)malloc(N*N*sizeof(int));
	b=(int*)malloc(N*N*sizeof(int));
	c=(int*)malloc(N*N*sizeof(int));
	
	for(i=0;i<N;i++)
	{
		for(j=0;j<N;j++)
		{
			a[i*N+j]=i*j;
			b[i*N+j]=i*j;
			c[i*N+j]=0;
		}
	}
	
	if(cudaMalloc(&dev_a,N*N*sizeof(int))!=cudaSuccess)
	{
		printf("########\nHubo un problema en la asignacion de memoria en la GPU\n########\n");
		exit(1);
	}
	if(cudaMalloc(&dev_b,N*N*sizeof(int))!=cudaSuccess)
	{
		printf("########\nHubo un problema en la asignacion de memoria en la GPU\n########\n");
		exit(1);
	}
	if(cudaMalloc(&dev_c,N*N*sizeof(int))!=cudaSuccess)
	{
		printf("########\nHubo un problema en la asignacion de memoria en la GPU\n########\n");
		exit(1);
	}
	
	printf("Asignacion de memoria correcta\n");
	//Copia de memoria a GPU
	if(cudaMemcpy(dev_a,a,N*N*sizeof(int),cudaMemcpyHostToDevice)!=cudaSuccess)
	{
		printf("#########\nHubo un problema en la copia de memoria a la GPU\n#########\n");
		exit(1);
	}
	if(cudaMemcpy(dev_b,b,N*N*sizeof(int),cudaMemcpyHostToDevice)!=cudaSuccess)
	{
		printf("#########\nHubo un problema en la copia de memoria a la GPU\n#########\n");
		exit(1);
	}
	
	//Cálculo de bloques e hilos
	while((float)N/(float)div>32)
	{
		div++;
	}
	float f_N=(float)N,f_div=(float)div;
	T=(int)ceil(f_N/f_div);
	//T=N;
	dim3 ThreadsBloque(T,T);
	//div=1;
	dim3 Bloques(div, div);
	printf("Se va a realizar la suma con %d bloques y %d hilos\n",div,T);
	printf("Se va a realizar %d iteraciones de matrices %dx%d\n",iteraciones,N,N);
	
	//Ejecución de kernel
	cudaEventRecord(start,0);
	while(ind<iteraciones)
	{
		matrixMultGPU<<<Bloques, ThreadsBloque>>>(dev_a,dev_b,dev_c,N);
		ind++;
	}
	cudaEventRecord(stop,0);
	cudaEventSynchronize(stop);
	cudaEventElapsedTime(&elapsedTime,start,stop);
	
	printf("El tiempo tomado para %d iteraciones fue de %3.5f ms\n",iteraciones,elapsedTime);
	cudaMemcpy(c,dev_c,N*N*sizeof(int),cudaMemcpyDeviceToHost);
	printf("Por ejemplo %d deberia ser 0\n",c[3*N]);
	printf("Por ejemplo %d deberia ser 0\n",c[(int)N/2]);
	printf("Por ejemplo %d deberia ser %d\n",c[N+1],(int)((2*pow(N-1,3)+3*pow(N-1,2)+N-1)/6));
	
	/*for(i=0;i<N;i++)
	{	
		printf("\n");
		for(j=0;j<N;j++)
		{
			printf("\t%d",a[i*N+j]);
		}
		//printf("\t");
		for(j=0;j<N;j++)
		{
			printf("\t%d",b[i*N+j]);
		}
		//printf("\t");
		for(j=0;j<N;j++)
		{
			printf("\t%d",c[i*N+j]);
		}
	}
	*/	
	
	free(a);
	free(b);
	free(c);
	cudaFree(dev_a);
	cudaFree(dev_b);
	cudaFree(dev_c);
	
	
	return 0;
}