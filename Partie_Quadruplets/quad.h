#ifndef QUAD_H
#define QUAD_H

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#define MAX_QUAD 1000

typedef struct {
    char op[20];
    char arg1[50];
    char arg2[50];
    char result[50];
} Quadruplet;

extern Quadruplet quads[MAX_QUAD];
extern int qc;
extern int temp_count;

char* nouveau_temp();
int ajouter_quad(char* op, char* arg1, char* arg2, char* result);
void patcher(int index, char* cible);
void afficher_quads();

#endif