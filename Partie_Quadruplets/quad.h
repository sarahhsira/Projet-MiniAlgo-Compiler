#ifndef QUAD_H
#define QUAD_H

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#define MAX_QUAD 1000
#define MAX_TEMP 100

typedef struct {
    char op[20];
    char arg1[50];
    char arg2[50];
    char result[50];
} Quadruplet;

static Quadruplet quads[MAX_QUAD];
static int qc = 0;          // compteur quadruplets
static int temp_count = 0;  // compteur temporaires T1, T2...

// Générer un nouveau temporaire : T1, T2, ...
static char* nouveau_temp()
{
    char* t = (char*)malloc(20);
    sprintf(t, "T%d", ++temp_count);
    return t;
}

// Ajouter un quadruplet
static int ajouter_quad(char* op, char* arg1, char* arg2, char* result)
{
    strcpy(quads[qc].op,     op     ? op     : "-");
    strcpy(quads[qc].arg1,   arg1   ? arg1   : "-");
    strcpy(quads[qc].arg2,   arg2   ? arg2   : "-");
    strcpy(quads[qc].result, result ? result : "-");
    return qc++;
}

// Patcher l'adresse de saut d'un quadruplet (pour IF/WHILE)
static void patcher(int index, char* cible)
{
    strcpy(quads[index].result, cible);
}

static void afficher_quads()
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

#endif