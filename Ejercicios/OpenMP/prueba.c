#include <stdio.h>	
#include <omp.h>	
  
int	main(int argc, char* argv[])
{
	//Esta instrucción permite definir el número de procesadores
	//omp_set_num_threads(8);
	#pragma omp parallel /*O se puede poner directamente desde la directiva*/ num_threads(4)
	{
		int	ID;
		ID = omp_get_thread_num();
		printf("Hola soy el Thread %d.\n", ID);
	}
	return 0;
}
 	
 
