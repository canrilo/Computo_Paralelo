#include <stdio.h>
#include <stdlib.h>
#include <math.h>

__global__ void matrixMultGPU(int *a_ll,int *a_lr,int *a_ul, int *a_ur,int *b_ll,int *b_lr,int *b_ul, int *b_ur, int *c_ll,int *c_lr,int *c_ul, int *c_ur, int *t_ll,int *t_lr,int *t_ul, int *t_ur,int N){

	int k, sum_cur = 0,sum_cul = 0,sum_cll = 0,sum_clr = 0,sum_tur = 0,sum_tul = 0,sum_tll = 0,sum_tlr = 0;
	int col = threadIdx.x + blockDim.x * blockIdx.x;
	int fil = threadIdx.y + blockDim.y * blockIdx.y;
	if (col < N && fil < N) 
	{
		for (k = 0; k < N; k++) 
		{
			sum_cul += a_ul[fil * N + k] * b_ul[k * N + col];
			sum_cur += a_ul[fil * N + k] * b_ur[k * N + col];
			sum_cll += a_ll[fil * N + k] * b_ul[k * N + col];
			sum_clr += a_ll[fil * N + k] * b_ur[k * N + col];
			
			sum_tul += a_ur[fil * N + k] * b_ll[k * N + col];
			sum_tur += a_ur[fil * N + k] * b_lr[k * N + col];
			sum_tll += a_lr[fil * N + k] * b_ll[k * N + col];
			sum_tlr += a_lr[fil * N + k] * b_lr[k * N + col];
		}
		c_ul[fil * N + col] = sum_cul;
		c_ur[fil * N + col] = sum_cur;
		c_ll[fil * N + col] = sum_cll;
		c_lr[fil * N + col] = sum_clr;
		
		t_ul[fil * N + col] = sum_tul;
		t_ll[fil * N + col] = sum_tll;
		t_lr[fil * N + col] = sum_tlr;
		t_ur[fil * N + col] = sum_tur;
		__syncthreads();
		
		c_ul[fil * N + col]+=t_ul[fil * N + col];
		c_ll[fil * N + col]+=t_ll[fil * N + col];
		c_lr[fil * N + col]+=t_lr[fil * N + col];
		c_ur[fil * N + col]+=t_ur[fil * N + col];
	}
}

int main (void){
	//Creación de variables del sistema
	int *a, *b, *c, N,NN;
	int *a_ul,*a_ur,*a_ll,*a_lr,*b_ul,*b_ur,*b_ll,*b_lr,*c_ul,*c_ur,*c_ll,*c_lr;
	int *da_ul,*da_ur,*da_ll,*da_lr,*db_ul,*db_ur,*db_ll,*db_lr,*dc_ul,*dc_ur,*dc_ll,*dc_lr,*dt_ul,*dt_ur,*dt_ll,*dt_lr;
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
	
	{
	if(cudaMalloc(&da_ll,N*N*sizeof(int))!=cudaSuccess)
	{
		printf("########\nHubo un problema en la asignacion de memoria en la GPU\n########\n");
		exit(1);
	}
	if(cudaMalloc(&da_ul,N*N*sizeof(int))!=cudaSuccess)
	{
		printf("########\nHubo un problema en la asignacion de memoria en la GPU\n########\n");
		exit(1);
	}
	if(cudaMalloc(&da_ur,N*N*sizeof(int))!=cudaSuccess)
	{
		printf("########\nHubo un problema en la asignacion de memoria en la GPU\n########\n");
		exit(1);
	}
	if(cudaMalloc(&da_lr,N*N*sizeof(int))!=cudaSuccess)
	{
		printf("########\nHubo un problema en la asignacion de memoria en la GPU\n########\n");
		exit(1);
	}
	if(cudaMalloc(&db_ll,N*N*sizeof(int))!=cudaSuccess)
	{
		printf("########\nHubo un problema en la asignacion de memoria en la GPU\n########\n");
		exit(1);
	}
	if(cudaMalloc(&db_lr,N*N*sizeof(int))!=cudaSuccess)
	{
		printf("########\nHubo un problema en la asignacion de memoria en la GPU\n########\n");
		exit(1);
	}
	if(cudaMalloc(&db_ul,N*N*sizeof(int))!=cudaSuccess)
	{
		printf("########\nHubo un problema en la asignacion de memoria en la GPU\n########\n");
		exit(1);
	}
	if(cudaMalloc(&db_ur,N*N*sizeof(int))!=cudaSuccess)
	{
		printf("########\nHubo un problema en la asignacion de memoria en la GPU\n########\n");
		exit(1);
	}
	if(cudaMalloc(&dc_ur,N*N*sizeof(int))!=cudaSuccess)
	{
		printf("########\nHubo un problema en la asignacion de memoria en la GPU\n########\n");
		exit(1);
	}
	if(cudaMalloc(&dc_ul,N*N*sizeof(int))!=cudaSuccess)
	{
		printf("########\nHubo un problema en la asignacion de memoria en la GPU\n########\n");
		exit(1);
	}
	if(cudaMalloc(&dc_ll,N*N*sizeof(int))!=cudaSuccess)
	{
		printf("########\nHubo un problema en la asignacion de memoria en la GPU\n########\n");
		exit(1);
	}
	if(cudaMalloc(&dc_lr,N*N*sizeof(int))!=cudaSuccess)
	{
		printf("########\nHubo un problema en la asignacion de memoria en la GPU\n########\n");
		exit(1);
	}
	if(cudaMalloc(&dt_ur,N*N*sizeof(int))!=cudaSuccess)
	{
		printf("########\nHubo un problema en la asignacion de memoria en la GPU\n########\n");
		exit(1);
	}
	if(cudaMalloc(&dt_ul,N*N*sizeof(int))!=cudaSuccess)
	{
		printf("########\nHubo un problema en la asignacion de memoria en la GPU\n########\n");
		exit(1);
	}
	if(cudaMalloc(&dt_ll,N*N*sizeof(int))!=cudaSuccess)
	{
		printf("########\nHubo un problema en la asignacion de memoria en la GPU\n########\n");
		exit(1);
	}
	if(cudaMalloc(&dt_lr,N*N*sizeof(int))!=cudaSuccess)
	{
		printf("########\nHubo un problema en la asignacion de memoria en la GPU\n########\n");
		exit(1);
	}
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
	{
	//Copia de memoria a GPU
	if(cudaMemcpy(da_ll,a_ll,N*N*sizeof(int),cudaMemcpyHostToDevice)!=cudaSuccess)
	{
		printf("#########\nHubo un problema en la copia de memoria a la GPU\n#########\n");
		exit(1);
	}
	if(cudaMemcpy(da_lr,a_lr,N*N*sizeof(int),cudaMemcpyHostToDevice)!=cudaSuccess)
	{
		printf("#########\nHubo un problema en la copia de memoria a la GPU\n#########\n");
		exit(1);
	}
	if(cudaMemcpy(da_ul,a_ul,N*N*sizeof(int),cudaMemcpyHostToDevice)!=cudaSuccess)
	{
		printf("#########\nHubo un problema en la copia de memoria a la GPU\n#########\n");
		exit(1);
	}
	if(cudaMemcpy(da_ur,a_ur,N*N*sizeof(int),cudaMemcpyHostToDevice)!=cudaSuccess)
	{
		printf("#########\nHubo un problema en la copia de memoria a la GPU\n#########\n");
		exit(1);
	}
	if(cudaMemcpy(db_ll,b_ll,N*N*sizeof(int),cudaMemcpyHostToDevice)!=cudaSuccess)
	{
		printf("#########\nHubo un problema en la copia de memoria a la GPU\n#########\n");
		exit(1);
	}
	if(cudaMemcpy(db_lr,b_lr,N*N*sizeof(int),cudaMemcpyHostToDevice)!=cudaSuccess)
	{
		printf("#########\nHubo un problema en la copia de memoria a la GPU\n#########\n");
		exit(1);
	}
	if(cudaMemcpy(db_ul,b_ul,N*N*sizeof(int),cudaMemcpyHostToDevice)!=cudaSuccess)
	{
		printf("#########\nHubo un problema en la copia de memoria a la GPU\n#########\n");
		exit(1);
	}
	if(cudaMemcpy(db_ur,b_ur,N*N*sizeof(int),cudaMemcpyHostToDevice)!=cudaSuccess)
	{
		printf("#########\nHubo un problema en la copia de memoria a la GPU\n#########\n");
		exit(1);
	}
	}
	
	
	while(ind<iteraciones)
	{	
		matrixMultGPU<<<Bloques, ThreadsBloque>>>(da_ll,da_lr,da_ul,da_ur,db_ll,db_lr,db_ul,db_ur,dc_ll,dc_lr,dc_ul,dc_ur,dt_ll,dt_lr,dt_ul,dt_ur,N);
		ind++;
	}
	
	
	
	cudaMemcpy(c_ll,dc_ll,N*N*sizeof(int),cudaMemcpyDeviceToHost);
	cudaMemcpy(c_lr,dc_lr,N*N*sizeof(int),cudaMemcpyDeviceToHost);
	cudaMemcpy(c_ur,dc_ur,N*N*sizeof(int),cudaMemcpyDeviceToHost);
	cudaMemcpy(c_ul,dc_ul,N*N*sizeof(int),cudaMemcpyDeviceToHost);
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
	cudaFree(da_ll);
	cudaFree(da_lr);
	cudaFree(da_ul);
	cudaFree(da_ur);
	cudaFree(db_ll);
	cudaFree(db_lr);
	cudaFree(db_ul);
	cudaFree(db_ur);
	cudaFree(dc_ll);
	cudaFree(dc_lr);
	cudaFree(dc_ul);
	cudaFree(dc_ur);
	cudaFree(dt_ll);
	cudaFree(dt_lr);
	cudaFree(dt_ul);
	cudaFree(dt_ur);
		
	return 0;
}