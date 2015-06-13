#include <stdio.h>
#include <mpi.h>

int main( argc, argv )
int argc;
char **argv;
{
	MPI_Init( &argc, &argv );
	printf( "Hello world with MPI\n" );
	MPI_Finalize();
	return 0;
}
