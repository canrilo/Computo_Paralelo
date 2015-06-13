#include <mpi.h>
#include <stdio.h>
#include <stdlib.h>
int main(int argc, char** argv) {
	MPI_Init(NULL, NULL);

	// Get the number of processes //procesos
	int world_size1;
	MPI_Comm_size(MPI_COMM_WORLD, &world_size1);  
	// Get the rank of the process //
	int world_rank1;
	MPI_Comm_rank(MPI_COMM_WORLD, &world_rank1);
	// Get the name of the processor
	char processor_name1[MPI_MAX_PROCESSOR_NAME];
	int name_len;
	MPI_Get_processor_name(processor_name1, &name_len);
	// Print off a hello world message
	printf("Hola Mundo!!! desde el procesador %s, rank %d out of %d	processors\n",processor_name1, world_rank1, world_size1);
	// Finalize the MPI environment. No more MPI calls can be made after this
	MPI_Finalize();
}
