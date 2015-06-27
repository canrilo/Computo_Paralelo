#include <mpi.h>
#include <stdio.h>
#include <stdlib.h>


int main( argc, argv )
int argc;
char **argv;
{
	//printf("%d\n",atoi(argv[1]));
	MPI_Init(NULL,NULL);
	int rank, suma, tamano,i,numprocs,numero;
	tamano = atoi(argv[1]);
	int vector[tamano];
	for (i = 0; i < tamano; i++)
	{
		vector[i]=i+1;
	}
	MPI_Comm_size(MPI_COMM_WORLD, &numprocs);
	numero= (int)tamano/numprocs;
	//printf("%d\n",numero);
	int copia_v[numero];
	//printf("Se correrá el programa con %d procesos y %d elementos\n",numprocs,tamano);
	MPI_Comm_rank(MPI_COMM_WORLD, &rank);
	MPI_Scatter(&vector[0],numero,MPI_INT,&copia_v,numero,MPI_INT,0,MPI_COMM_WORLD);
	for (i = 1; i < numero; i++)
	{
		copia_v[i]=copia_v[i]+copia_v[i-1]+2;
	}
	
	MPI_Reduce(&copia_v[numero-1],&suma,1,MPI_INT,MPI_SUM,0,MPI_COMM_WORLD);
	if(rank==0)
	{
		printf("La suma es %d\n",suma);
	}
	MPI_Finalize();
}
