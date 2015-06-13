/*
Parallel and Distributed Computing Class
MPI
Practice 4 : Envío y Recepción bloqueante de un número entre dos procesos
Name
 :
*/
#include <mpi.h>
#include <stdio.h>
#include <stdlib.h>

int main(int argc, char** argv) {
	// Initialize the MPI environment
	MPI_Init(NULL, NULL);
	
	// Find out rank, size
	int world_rank;
	MPI_Comm_rank(MPI_COMM_WORLD, &world_rank);
	int world_size;
	MPI_Comm_size(MPI_COMM_WORLD, &world_size);
	
	// We are assuming at least 2 processes for this task
	if (world_size < 2) 
	{
		printf("World size must be greater than 1 for %s\n", argv[0]);
		MPI_Abort(MPI_COMM_WORLD, 1);
	}
	MPI_Request req;
	int number,number2,flag;
	if (world_rank == 0) 
	{	
		// If we are rank 0, set the number to -1 and send it to process 1
		number = -1;
		MPI_Isend(&number, 1, MPI_INT, 1, 0, MPI_COMM_WORLD,&req);
		MPI_Request_free(&req);
		printf("Lo envié\n");
	} else if (world_rank == 1) 
	{
		number2=3;
		MPI_Irecv(&number2, 1, MPI_INT, 0, 0, MPI_COMM_WORLD, &req);
		printf("Process 1 received number %d from process 0\n", number2);
		printf("lo recibí\n");
	}
	MPI_Finalize();
}
