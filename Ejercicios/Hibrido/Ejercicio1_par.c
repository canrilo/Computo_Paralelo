#include <omp.h>
#include "mpi.h"
#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[]) {
	
	int* a;
	int* b;
	int* c;
	float start, end;
	int elem=10000000,i,numerito;
	
	int numprocs, rank, namelen;
	char processor_name[MPI_MAX_PROCESSOR_NAME];
	int soy, np;	
	
	a=malloc(elem*sizeof(int));
	b=malloc(elem*sizeof(int));
	c=malloc(elem*sizeof(int));
	for (i = 0; i < elem; i++)
	{
		a[i]=i*2;
		b[i]=i*2+1;
	}
	
	start=omp_get_wtime();
	/////////////INICIA PARALELISMO////////////////////
	MPI_Init(&argc, &argv);
	
	MPI_Comm_size(MPI_COMM_WORLD, &numprocs); //obtiene el número de proceso
	MPI_Comm_rank(MPI_COMM_WORLD, &rank); // rango. Cantidad de procesos totales
	MPI_Get_processor_name(processor_name, &namelen); //nombre de la computadora
	
	numerito=(int)elem/numprocs;
	int* copia_a=malloc(numerito*sizeof(int));
	int* copia_b=malloc(numerito*sizeof(int));
	int* copia_c=malloc(numerito*sizeof(int));
		
	MPI_Scatter(a,numerito,MPI_INT,copia_a,numerito,MPI_INT,0,MPI_COMM_WORLD);
	MPI_Scatter(b,numerito,MPI_INT,copia_b,numerito,MPI_INT,0,MPI_COMM_WORLD);
	
	#pragma omp parallel for
		for (i = 0; i < numerito; i++)
		{
			copia_c[i]=copia_a[i]+copia_b[i];
		}

	MPI_Gather(copia_c,numerito,MPI_INT,c,numerito,MPI_INT,0,MPI_COMM_WORLD);
	
	//////////////FIN PARALELISMO//////////////////////
	end=omp_get_wtime();
	if(rank==0)
	{
		printf("El tiempo de ejecución para %d elementos es de %f\n",elem,end-start);
		printf("Prueba. Tres elementos sumados y su resultado son:\n");
		printf("%d \t+ \t%d \t= \t%d\n",a[0],b[0],c[0]);
		printf("%d \t+ \t%d \t= \t%d\n",a[(int)elem/2],b[(int)elem/2],c[(int)elem/2]);
		printf("%d \t+ \t%d \t= \t%d\n",a[elem-1],b[elem-1],c[elem-1]);
	}
	free(a);
	free(b);
	free(c);
	MPI_Finalize(); 
}
