/*

19. Írjon programot mely beolvas integer számokat egy 10 elemű vektorba! Ezután definiáljunk egy 2x5-ös mátrixot. 
A program másolja be a vektor elmeit a mátrixba. Először az oszlopokat töltsük fel a mátrixban. Nyomtassuk ki a mátrixot.

*/
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <time.h>

void beolvasas(int *tomb);
void atoltes(int *tomb, int (*matrix)[5]);
void kiiras(int (*matrix)[5]);

int main()
{
	int tomb[10];
	int matrix[2][5];

	printf("Adjon meg 10 egesz szamot!\n");
	beolvasas(tomb);
	atoltes(tomb, matrix);
	kiiras(matrix);

	return 0;
}

void beolvasas(int *tomb)
{
	int i;
	for ( i = 0; i < 10; i++)
	{
		scanf_s("%d", (tomb + i));
	}

}

void atoltes(int *tomb, int(*matrix)[5])
{
	int i, j,k=0;
	for ( i = 0; i < 5; i++)
	{
		for ( j = 0; j < 2; j++)
		{
			*(*(matrix + j) + i) = *(tomb + k);
			k++;
		}
	}

}

void kiiras(int(*matrix)[5])
{
	int i, j;
	for (i = 0; i < 2; i++)
	{
		for (j = 0; j < 5; j++)
		{
			printf("%d\t", *(*(matrix + i) + j));
		}
		printf("\n");
	}
}
