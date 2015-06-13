/*
Parallel and Distributed Computing Class
OpenMP
Practice 3 :Parallelizing the Sum of 2 vectors
Name
 :
*/
#include <omp.h>
#include <stdio.h>
#include <math.h>
#include <stdlib.h>

void Suma_Vec(int* a, int* b, int* c, int size, int threads)
{
	int i = 0;
	#pragma omp parallel for num_threads(threads)
		for (i = 0; i < size; ++i)
		{
			c[i] = a[i] + b[i];
		}
}

int main(int argc, char **argv)
{
	int* a;
	int* b;
	int* c;
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
	a=malloc(size*sizeof(int));
	b=malloc(size*sizeof(int));
	c=malloc(size*sizeof(int));
	for(i=0;i<size;i++)
	{
		a[i]=2*i;
		b[i]=2*i+1;
		c[i]=0;
	}
	printf("\nParallelizing the Sum of 2 vectorswith %d Elements and %d Threads\n",size,num_t);
	start=omp_get_wtime();
	if(paralelo==1)
	{
		Suma_Vec(a, b, c, size,num_t);
	}else
	{
		for (i = 0; i < size; ++i)
		{
			c[i] = a[i] + b[i];
		}
	}
	stop=omp_get_wtime();
	printf("Sum realized successfully!!\n");
	printf("El tiempo de ejecución fue: %f\n",stop-start);
	printf("El último valor del vector c es: %d\n",c[1]);
	free(a);
	free(b);
	free(c);
	return 0;
}
