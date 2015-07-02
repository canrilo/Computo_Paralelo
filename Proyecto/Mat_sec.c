#include <stdio.h>
#include <stdlib.h>
#include <time.h>

void mult_mat(int *a, int *b, int *c, int N)
{
	int i,j,k,suma;
	for (i=0; i < N; i++)
	{
		for (j=0; j < N; j++)
		{	
			suma=0;
			for (k=0; k < N; k++)
				suma += a[k+i*N] * b[j+k*N];
			c[j+i*N] =suma;
		}	
	}
}

	

int main (void){
	//Creación de variables del sistema
	int *a, *b, *c, N;
	int i,j;
	int iteraciones=100,ind=0;
	
	printf("Ingrese el tamano deseado para las matrices:\n");
	scanf("%d",&N);
	
	printf("Creando espacio e inicializando matrices...\n");
	
	//Asignación e inicialización de memoria
	a=(int*)malloc(N*N*sizeof(int));
	b=(int*)malloc(N*N*sizeof(int));
	c=(int*)malloc(N*N*sizeof(int));
	
	for(i=0;i<N;i++)
	{
		for(j=0;j<N;j++)
		{
			a[i*N+j]=i*j;
			b[i*N+j]=i*j;
			c[i*N+j]=0;
		}
	}
	
	//Cálculo de bloques e hilos
	
	printf("Se va a realizar %d iteraciones de matrices %dx%d\n",iteraciones,N,N);
	
	//Ejecución de kernel
	clock_t start = clock();
	while(ind<iteraciones)
	{
		mult_mat(a,b,c,N);
		ind++;
	}
	clock_t end = clock();
	float seconds = (float)(end - start) / CLOCKS_PER_SEC;
	printf("El tiempo tomado para %d iteraciones fue de %3.5f ms\n",iteraciones,seconds*10);

	/*
	for(i=0;i<N;i++)
	{	
		printf("\n");
		for(j=0;j<N;j++)
		{
			printf("\t%d",a[i*N+j]);
		}
		//printf("\t");
		for(j=0;j<N;j++)
		{
			printf("\t%d",b[i*N+j]);
		}
		//printf("\t");
		for(j=0;j<N;j++)
		{
			printf("\t%d",c[i*N+j]);
		}
	}*/
	
	
	free(a);
	free(b);
	free(c);
	
	return 0;
}