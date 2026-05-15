#include "quad.h"

qdr quad[1000];
int qc = 0;
static int temp_count = 0;

void quadr(char op[], char arg1[], char arg2[], char result[])
{
    strcpy(quad[qc].op,     op);
    strcpy(quad[qc].arg1,   arg1);
    strcpy(quad[qc].arg2,   arg2);
    strcpy(quad[qc].result, result);
    qc++;
}

void update_quad(int index, int pos, char value[])
{
    if      (pos == 1) strcpy(quad[index].op,     value);
    else if (pos == 2) strcpy(quad[index].arg1,   value);
    else if (pos == 3) strcpy(quad[index].arg2,   value);
    else if (pos == 4) strcpy(quad[index].result, value);
}

char* nouveau_temp()
{
    char* t = (char*)malloc(20);
    sprintf(t, "T%d", ++temp_count);
    return t;
}

void print_quad()
{
    printf("\n********************* Les Quadruplets ***********************\n");
    for(int i = 0; i < qc; i++)
    {
        printf("\n%d - ( %s  ,  %s  ,  %s  ,  %s )",
               i, quad[i].op, quad[i].arg1, quad[i].arg2, quad[i].result);
        printf("\n------------------------------------------------------------");
    }
    printf("\n");
}
void print_quad_apres_opt()
{
    printf("\n********************* Quadruplets APRÈS Optimisation ***********************\n");
    for(int i = 0; i < qc; i++)
    {
        printf("\n%d - ( %s  ,  %s  ,  %s  ,  %s )",
               i, quad[i].op, quad[i].arg1, quad[i].arg2, quad[i].result);
        printf("\n------------------------------------------------------------");
    }
    printf("\n");
}