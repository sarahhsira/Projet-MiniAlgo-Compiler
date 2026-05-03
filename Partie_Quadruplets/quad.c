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


PileControle pile_if;
PileControle pile_while;

void init_pile(PileControle* p) {
    p->capacity = 100;
    p->data = (int*)malloc(p->capacity * sizeof(int));
    p->top = -1;
}

void push_pile(PileControle* p, int val) {
    if (p->top >= p->capacity - 1) {
        p->capacity *= 2;
        p->data = (int*)realloc(p->data, p->capacity * sizeof(int));
    }
    p->data[++p->top] = val;
}

int pop_pile(PileControle* p) {
    if (p->top >= 0) {
        return p->data[p->top--];
    }
    return -1;
}

int top_pile(PileControle* p) {
    if (p->top >= 0) {
        return p->data[p->top];
    }
    return -1;
}

int is_empty_pile(PileControle* p) {
    return (p->top == -1);
}