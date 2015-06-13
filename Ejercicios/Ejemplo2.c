#include <omp.h>
#include <stdio.h>

int main()
{
	printf("Este es nuestro segundo ejemplo en openMP\n");
	#pragma omp parallel
	{
		//Initializing Parallel Region
		int NCores,tid,NPR,NTHR;
		NCores=omp_get_num_procs(); //get the number of available cores
		tid=omp_get_thread_num(); //get current thread ID
		NPR=omp_get_num_threads(); //get total number of threads. NPR
		NTHR=omp_get_max_threads(); //get number of threads requested.
		
		//Con estas condiciones if puedo definir qué instrucciones ejecuta qué procesador
		if(tid==0)
		{
			printf("%i : Number of available cores\t= %i\n",tid,NCores);
			printf("%i : Number of threads request\t= %i\n",tid,NTHR);
			printf("%i : Numero total de hilos \t= %i\n",tid,NPR);
		}
		printf("%i:Hello multicore user! I am thread %i out of %i\n",tid,tid,NPR);
	}
	return 0;
}
