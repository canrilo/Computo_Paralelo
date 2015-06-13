/*
Parallel and Distributed Computing Class
OpenMP
Practice 4 :Parallelizing dot product of 2 vectors
Name
 :
*/
#include <omp.h>
#include <stdio.h>
#include <math.h>
#include <stdlib.h>

u_int32_t result=0;

void Prod_Vec(int* array_a, int* array_b, int size, int threads)
{
	int i = 0;
	#pragma omp parallel for reduction(+:result)
		for (i=0; i < size; i++)
		{	
			//#pragma omp atomic
				result += array_a[i] * array_b[i];
		}
}

int main(int argc, char **argv)
{
	int* a;
	int* b;
	int i;
	int num_t,size,paralelo;
	double start,stop;
	if(argc!=4){
		printf("Se debe correr con num_hilos size paral!\n EXIT!\n");
		exit(1);
	}
	num_t=atoi(argv[1]);
	size=atoi(argv[2]);
	paralelo=atoi(argv[3]);
	if(paralelo>1){
		printf("paral debe ser 0 o 1 si se desea activar paralelo!\n EXIT!\n");
		exit(1);
	}
	a=malloc(size*sizeof(int));
	b=malloc(size*sizeof(int));
	for(i=0;i<size;i++)
	{
		a[i]=2*i;
		b[i]=2*i+1;
	}
	printf("\nParallelizing the Dot Product of 2 vectors with %d Elements and %d Threads\n",size,num_t);
	start=omp_get_wtime();
	if(paralelo==1)
	{
		Prod_Vec(a, b, size,num_t);
	}else
	{
		
		for (i = 0; i < size; ++i)
		{
			result += a[i] * b[i];
		}
	}
	stop=omp_get_wtime();
	printf("Product realized successfully!!\n");
	printf("El tiempo de ejecución fue: %f\n",stop-start);
	printf("El Resultado del Prod. punto es: %u\n",result);
	free(a);
	free(b);
	return 0;
}
