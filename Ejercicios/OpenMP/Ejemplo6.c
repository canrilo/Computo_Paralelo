/*
Parallel and Distributed Computing Class
OpenMP
Practice 6 : Matrix * Matrix
Name
 :
*/
#include <stdio.h>
#include <omp.h>
#include <stdlib.h>
#define SIZE 1000

int main ()
{
	// Counters
	int i, j, k;
	
	// Working matrix and vectors
	float* matrix1;
	float* matrix2;
	float* result;
	matrix1=malloc(SIZE*SIZE*sizeof(float));
	matrix2=malloc(SIZE*SIZE*sizeof(float));
	result=malloc(SIZE*SIZE*sizeof(float));
	// Initializing Matrix and Vector
	
	printf("\nInitializing Matrixes [%d][%d] ...\n",SIZE,SIZE);
		  
	for (i=0; i < SIZE; i++)
	{
		for (j=0; j < SIZE; j++)
		{
			matrix1[i*SIZE+j] = (i+1) * 2.0;
			matrix2[i*SIZE+j] = (i+1) * 3.0;
		}
	}
	printf("\nStarting Multiplication Matrix * Matrix ...\n");
	
	double start = omp_get_wtime();
	double sum;
		#pragma omp parallel for num_threads(2) private(i,j,k) reduction(+:sum)
		for (i=0; i < SIZE; i++)
		{	
			
			for (j=0; j < SIZE ; j++)
			{
				
				double sum=0;
				//#pragma omp parallel for num_threads(4) reduction(+:sum)
				for (k = 0; k < SIZE; k++)
				{
					sum+=matrix1[i*SIZE+k] * matrix2[k*SIZE+j];
				}
				result[i*SIZE+j]=sum;
			}
		}
	double end = omp_get_wtime();
	/*printf("result= \n");
	for (i=0; i < SIZE; i++)
	{
		for (j=0; j<SIZE;j++)
		{
			printf("%.1f \t",result[i*SIZE+j]);
		}
	}*/
	printf("\n\nMultiplication Matrix * Matrix has FINISHED\n");
	printf("\nExecution Time = %f\n",end - start);
	free(matrix1);
	free(matrix2);
	free(result);
	return 0;
}
