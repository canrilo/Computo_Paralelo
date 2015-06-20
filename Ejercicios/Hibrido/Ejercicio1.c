#include <omp.h>
//#include "mpi.h"
#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[]) {
	
	int* a;
	int* b;
	int* c;
	float start, end;
	int elem=10000000,i;
	a=malloc(elem*sizeof(int));
	b=malloc(elem*sizeof(int));
	c=malloc(elem*sizeof(int));
	for (i = 0; i < elem; i++)
	{
		a[i]=i*2;
		b[i]=i*2+1;
	}
	start=omp_get_wtime();
	for (i = 0; i < elem; i++)
	{
		c[i]=a[i]+b[i];
	}
	end=omp_get_wtime();
	printf("El tiempo de ejecución para %d elementos es de %f\n",elem,end-start);
	free(a);
	free(b);
	free(c);
}
