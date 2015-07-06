#include <stdio.h>
#include <stdlib.h>
#include <math.h>

__global__ void matrixMultGPU(int *A,int *B,int *C, int N,int mod){

	int k, sum=0;
	int col = threadIdx.x + blockDim.x * blockIdx.x;
	int fil = threadIdx.y + blockDim.y * blockIdx.y;
	if (col < N && fil < N)
	{
		for (k = 0; k < N; k++) 
		{
			sum += A[fil * N + k] * B[k * N + col];
		}
		if(mod==0)
		{
			C[fil * N + col] = sum;	
		} else
		{
			C[fil * N + col] += sum;	
		}
		__syncthreads();
		
	}
}

int main (void){
	//Creación de variables del sistema
	int *a, *b, *c, N,NN;
	int *a_ul,*a_ur,*a_ll,*a_lr,*b_ul,*b_ur,*b_ll,*b_lr,*c_ul,*c_ur,*c_ll,*c_lr;
	int *DB,*DA,*DC1,*DC2;
	int i,j;
	int T,div=1, iteraciones=10,ind=0;
	float elapsedTime;
	printf("Ingrese el tamano deseado para las matrices:\n");
	scanf("%d",&NN);
	if(NN%2!=0 || NN<2)
	{
		printf("El tamaño debe ser mayor a dos y par\n");
		exit(1);
	}
	N=(int)NN/2;
	//Creación de variables de tiempo
	cudaEvent_t start,stop;
	cudaEventCreate(&start);
	cudaEventCreate(&stop);
	
	printf("Creando espacio e inicializando matrices...\n");
	
	//Asignación e inicialización de memoria
	a=(int*)malloc(NN*NN*sizeof(int));
	b=(int*)malloc(NN*NN*sizeof(int));
	c=(int*)malloc(NN*NN*sizeof(int));
	
	a_ll=(int*)malloc(N*N*sizeof(int));
	a_lr=(int*)malloc(N*N*sizeof(int));
	a_ul=(int*)malloc(N*N*sizeof(int));
	a_ur=(int*)malloc(N*N*sizeof(int));
	
	b_ll=(int*)malloc(N*N*sizeof(int));
	b_lr=(int*)malloc(N*N*sizeof(int));
	b_ul=(int*)malloc(N*N*sizeof(int));
	b_ur=(int*)malloc(N*N*sizeof(int));
	
	c_ll=(int*)malloc(N*N*sizeof(int));
	c_lr=(int*)malloc(N*N*sizeof(int));
	c_ul=(int*)malloc(N*N*sizeof(int));
	c_ur=(int*)malloc(N*N*sizeof(int));
	
	//Inicialización de Matrices
	for(i=0;i<NN;i++)
	{
		for(j=0;j<NN;j++)
		{
			a[i*NN+j]=i*j;
			b[i*NN+j]=i*j;
		}
	}
	
	//Creación de submatrices
	for(i=0;i<N;i++)
	{
		for(j=0;j<N;j++)
		{
			a_ul[i*N+j]=a[i*NN+j];
			a_ur[i*N+j]=a[i*NN+j+N];
			a_ll[i*N+j]=a[(i+N)*NN+j];
			a_lr[i*N+j]=a[(i+N)*NN+j+N];
			
			b_ul[i*N+j]=b[i*NN+j];
			b_ur[i*N+j]=b[i*NN+j+N];
			b_ll[i*N+j]=b[(i+N)*NN+j];
			b_lr[i*N+j]=b[(i+N)*NN+j+N];
		}
	}
	
	
	if(cudaMalloc(&DA,N*N*sizeof(int))!=cudaSuccess)
	{
		printf("########\nHubo un problema en la asignacion de memoria en la GPU\n########\n");
		exit(1);
	}
	if(cudaMalloc(&DB,N*N*sizeof(int))!=cudaSuccess)
	{
		printf("########\nHubo un problema en la asignacion de memoria en la GPU\n########\n");
		exit(1);
	}
	if(cudaMalloc(&DC1,N*N*sizeof(int))!=cudaSuccess)
	{
		printf("########\nHubo un problema en la asignacion de memoria en la GPU\n########\n");
		exit(1);
	}
	if(cudaMalloc(&DC2,N*N*sizeof(int))!=cudaSuccess)
	{
		printf("########\nHubo un problema en la asignacion de memoria en la GPU\n########\n");
		exit(1);
	}
	printf("Asignacion de memoria correcta\n");
	
	
	//Cálculo de bloques e hilos
	while((float)N/(float)div>32)
	{
		div++;
	}
	float f_N=(float)N,f_div=(float)div;
	T=(int)ceil(f_N/f_div);
	dim3 ThreadsBloque(T,T);
	dim3 Bloques(div, div);
	printf("Se va a realizar la suma con %d bloques y %d hilos\n",div,T);
	printf("Se va a realizar %d iteraciones de matrices %dx%d\n",iteraciones,NN,NN);
	
	//Ejecución de kernel
	cudaEventRecord(start,0);
	while(ind<iteraciones)
	{	
		if(cudaMemcpy(DA,a_ul,N*N*sizeof(int),cudaMemcpyHostToDevice)!=cudaSuccess)
		{
			printf("#########\nHubo un problema en la copia de memoria a la GPU\n#########\n");
			exit(1);
		}
		if(cudaMemcpy(DB,b_ul,N*N*sizeof(int),cudaMemcpyHostToDevice)!=cudaSuccess)
		{
			printf("#########\nHubo un problema en la copia de memoria a la GPU\n#########\n");
			exit(1);
		}
		matrixMultGPU<<<Bloques, ThreadsBloque>>>(DA,DB,DC1,N,0);
		
		if(cudaMemcpy(DB,b_ur,N*N*sizeof(int),cudaMemcpyHostToDevice)!=cudaSuccess)
		{
			printf("#########\nHubo un problema en la copia de memoria a la GPU\n#########\n");
			exit(1);
		}
		matrixMultGPU<<<Bloques, ThreadsBloque>>>(DA,DB,DC2,N,0);
		if(cudaMemcpy(DA,a_ur,N*N*sizeof(int),cudaMemcpyHostToDevice)!=cudaSuccess)
		{
			printf("#########\nHubo un problema en la copia de memoria a la GPU\n#########\n");
			exit(1);
		}
		if(cudaMemcpy(DB,b_ll,N*N*sizeof(int),cudaMemcpyHostToDevice)!=cudaSuccess)
		{
			printf("#########\nHubo un problema en la copia de memoria a la GPU\n#########\n");
			exit(1);
		}
		matrixMultGPU<<<Bloques, ThreadsBloque>>>(DA,DB,DC1,N,1);
		if(cudaMemcpy(DB,b_lr,N*N*sizeof(int),cudaMemcpyHostToDevice)!=cudaSuccess)
		{
			printf("#########\nHubo un problema en la copia de memoria a la GPU\n#########\n");
			exit(1);
		}
		matrixMultGPU<<<Bloques, ThreadsBloque>>>(DA,DB,DC2,N,1);
		cudaMemcpy(c_ul,DC1,N*N*sizeof(int),cudaMemcpyDeviceToHost);
		cudaMemcpy(c_ur,DC1,N*N*sizeof(int),cudaMemcpyDeviceToHost);
		if(cudaMemcpy(DA,a_ll,N*N*sizeof(int),cudaMemcpyHostToDevice)!=cudaSuccess)
		{
			printf("#########\nHubo un problema en la copia de memoria a la GPU\n#########\n");
			exit(1);
		}
		if(cudaMemcpy(DB,b_ul,N*N*sizeof(int),cudaMemcpyHostToDevice)!=cudaSuccess)
		{
			printf("#########\nHubo un problema en la copia de memoria a la GPU\n#########\n");
			exit(1);
		}
		matrixMultGPU<<<Bloques, ThreadsBloque>>>(DA,DB,DC1,N,0);
		if(cudaMemcpy(DB,b_ur,N*N*sizeof(int),cudaMemcpyHostToDevice)!=cudaSuccess)
		{
			printf("#########\nHubo un problema en la copia de memoria a la GPU\n#########\n");
			exit(1);
		}
		matrixMultGPU<<<Bloques, ThreadsBloque>>>(DA,DB,DC2,N,0);
		if(cudaMemcpy(DA,a_lr,N*N*sizeof(int),cudaMemcpyHostToDevice)!=cudaSuccess)
		{
			printf("#########\nHubo un problema en la copia de memoria a la GPU\n#########\n");
			exit(1);
		}
		if(cudaMemcpy(DB,b_ll,N*N*sizeof(int),cudaMemcpyHostToDevice)!=cudaSuccess)
		{
			printf("#########\nHubo un problema en la copia de memoria a la GPU\n#########\n");
			exit(1);
		}
		matrixMultGPU<<<Bloques, ThreadsBloque>>>(DA,DB,DC1,N,1);
		if(cudaMemcpy(DB,b_lr,N*N*sizeof(int),cudaMemcpyHostToDevice)!=cudaSuccess)
		{
			printf("#########\nHubo un problema en la copia de memoria a la GPU\n#########\n");
			exit(1);
		}
		matrixMultGPU<<<Bloques, ThreadsBloque>>>(DA,DB,DC2,N,1);
		cudaMemcpy(c_ll,DC1,N*N*sizeof(int),cudaMemcpyDeviceToHost);
		cudaMemcpy(c_lr,DC2,N*N*sizeof(int),cudaMemcpyDeviceToHost);		
		
		ind++;
	}
	cudaEventRecord(stop,0);
	cudaEventSynchronize(stop);
	cudaEventElapsedTime(&elapsedTime,start,stop);
	printf("El tiempo tomado para %d iteraciones fue de %3.5f ms\n",iteraciones,elapsedTime);
	for(i=0;i<N;i++)
	{
		for(j=0;j<N;j++)
		{
			c[i*NN+j]=c_ul[i*N+j];
			c[i*NN+j+N]=c_ur[i*N+j];
			c[(i+N)*NN+j]=c_ll[i*N+j];
			c[(i+N)*NN+j+N]=c_lr[i*N+j];
		}
	}
	
	printf("Por ejemplo %d deberia ser 0\n",c[3*NN]);
	printf("Por ejemplo %d deberia ser 0\n",c[(int)NN/2]);
	printf("Por ejemplo %d deberia ser %d\n",c[NN+1],(int)((2*pow(NN-1,3)+3*pow(NN-1,2)+NN-1)/6));
	/*
	for(i=0;i<NN;i++)
	{	
		printf("\n");
		for(j=0;j<NN;j++)
		{
			printf("\t%d",a[i*NN+j]);
		}
		//printf("\t");
		for(j=0;j<NN;j++)
		{
			printf("\t%d",b[i*NN+j]);
		}
		//printf("\t");
		for(j=0;j<NN;j++)
		{
			printf("\t%d",c[i*NN+j]);
		}
	}
	*/
	
	free(a);
	free(a_ll);
	free(a_lr);
	free(a_ul);
	free(a_ur);
	free(b_ur);
	free(b_ll);
	free(b_lr);
	free(b_ul);
	free(c_ll);
	free(c_lr);
	free(c_ul);
	free(c_ur);
	free(b);
	free(c);
	cudaFree(DA);
	cudaFree(DB);
	cudaFree(DC1);
	cudaFree(DC2);
		
	return 0;
}