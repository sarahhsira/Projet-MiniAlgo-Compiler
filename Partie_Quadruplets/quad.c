#include "quad.h"

Quadruplet quads[MAX_QUAD];
int qc = 0;
int temp_count = 0;

char* nouveau_temp()
{
    char* t = (char*)malloc(20);
    sprintf(t, "T%d", ++temp_count);
    return t;
}

int ajouter_quad(char* op, char* arg1, char* arg2, char* result)
{
    strcpy(quads[qc].op,     op     ? op     : "-");
    strcpy(quads[qc].arg1,   arg1   ? arg1   : "-");
    strcpy(quads[qc].arg2,   arg2   ? arg2   : "-");
    strcpy(quads[qc].result, result ? result : "-");
    return qc++;
}

void patcher(int index, char* cible)
{
    strcpy(quads[index].result, cible);
}

void afficher_quads()
{
    printf("\n********************* Les Quadruplets ***********************\n");
    for(int i = 0; i < qc; i++)
    {
        printf("\n%d - ( %s  ,  %s  ,  %s  ,  %s )",
               i, quads[i].op, quads[i].arg1, quads[i].arg2, quads[i].result);
        printf("\n------------------------------------------------------------");
    }
    printf("\n");
}