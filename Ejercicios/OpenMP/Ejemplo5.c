/*
Parallel and Distributed Computing Class
OpenMP
Practice 5 : Vector * Matrix
Name
 :
*/
#include <stdio.h>
#include <omp.h>
#include <stdlib.h>
#define SIZE 300

int main ()
{
	// Counters
	int i, j;
	
	// Working matrix and vectors
	float* matrix;
	float* vector;
	float* result;
	matrix=malloc(SIZE*SIZE*sizeof(float));
	vector=malloc(SIZE*sizeof(float));
	result=malloc(SIZE*sizeof(float));
	// Initializing Matrix and Vector
	
	printf("\nInitializing Matrix [%d][%d] and Vector[%d] ...\n",SIZE,SIZE,SIZE);
	for (i=0; i<SIZE; i++)
	{
	vector[i] = i + 1.0;
	}
		  
	for (i=0; i < SIZE; i++)
	{
		for (j=0; j < SIZE; j++)
		{
			matrix[i*SIZE+j] = i * 2.0;
		}
	}
	printf("\nStarting Multiplication Vector * Matrix ...\n");
	
	double start = omp_get_wtime();
	#pragma omp parallel for num_threads(2)
		for (i=0; i < SIZE; i++)
		{
			double sum=0;
			
			for (j=0;j< SIZE; j++)
			{
				sum+=matrix[i*SIZE+j] * vector[j];
			}
			result[i]=sum;
		}
	double end = omp_get_wtime();
	/*printf("result= \n");
	for (i=0; i < SIZE; i++)
	{
		printf("%.1f \t",result[i]);
	}*/
	printf("\n\nMultiplication Vector * Matrix has FINISHED\n");
	printf("\nExecution Time = %f\n",end - start);
	free(matrix);
	free(vector);
	free(result);
	return 0;
}
