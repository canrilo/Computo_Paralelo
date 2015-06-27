#include <mpi.h>
#include <stdio.h>
#include <stdlib.h>


int main( argc, argv )
int argc;
char **argv;
{
	
	int tamano,i,numprocs, cuantos, rank;
	int *a;
	if(argc!=2)
	{
		printf("Debe indicar el tamaño del vector!\n EXIT!\n");
		exit(1);
	}
	
	tamano =atoi(argv[1]);
	a=malloc(tamano*sizeof(int));
	if(a==0)
	{
		printf("Ocurrió un problema con la asignación de memoria\n");
	}
	for (i = 0; i < tamano; i++)
	{
		a[i]=i+1;
	}
	
	
	MPI_Init(NULL, NULL);
	MPI_Comm_size(MPI_COMM_WORLD, &numprocs);
	MPI_Comm_rank(MPI_COMM_WORLD, &rank);
	int indice=0,suma=0;
	cuantos=(int)tamano/numprocs;
	int* copia_a=malloc(cuantos*sizeof(int));
	int gather[numprocs];
	
	MPI_Scatter(a,cuantos,MPI_INT,copia_a,cuantos,MPI_INT,0,MPI_COMM_WORLD);
	
	for (indice = 0; indice < cuantos; indice++)
	{
		suma+=copia_a[indice];
	}
	MPI_Gather(&suma,1,MPI_INT,&gather,1,MPI_INT,0,MPI_COMM_WORLD);
	
	if(rank==0)
	{
		for (i = 1; i < numprocs; i++)
		{
			gather[i]=gather[i]+gather[i-1];
		}
		
		printf("El resultado de la suma es %d\n",gather[numprocs-1]);
	}
	
	MPI_Finalize();
	
}
