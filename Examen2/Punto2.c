#include <mpi.h>
#include <stdio.h>
#include <stdlib.h>


int main( argc, argv )
int argc;
char **argv;
{
	MPI_Init(NULL,NULL);
	int rank, suma;
	MPI_Comm_rank(MPI_COMM_WORLD, &rank);
	rank=rank+2;
	
	MPI_Reduce(&rank,&suma,1,MPI_INT,MPI_SUM,0,MPI_COMM_WORLD);
	if(rank==2)
	{
		printf("La suma es %d\n",suma);
	}
	MPI_Finalize();
}
