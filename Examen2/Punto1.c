#include <omp.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

int main (int argc, char** argv)
{	
	int hilos, n, *a, *b,i;
	uint32_t dotp; 
	float start, end;
	hilos=atoi(argv[1]);
	n=atoi(argv[2]);
	printf("Ejecutando dotp para %d elementos con %d hilos\n",n,hilos);
	a=malloc(n*sizeof(int));
	b=malloc(n*sizeof(int));
	for (i = 0; i < n; i++)
	{
		a[i]=i+1;
		b[i]=i+1;
	}
	dotp=0;	
	start=omp_get_wtime();
	#pragma omp parallel for num_threads(hilos) reduction(+:dotp) //schedule(dynamic,2)
	for (i = 0; i < n; i++)
	{
		dotp+=a[i]*b[i];
	}
	end=omp_get_wtime();
	printf("El resultado fue de %d\n",dotp);
	printf("El tiempo de ejecución fue de %f\n",end-start);
	free(a);
	free(b);
	return 0;
}
