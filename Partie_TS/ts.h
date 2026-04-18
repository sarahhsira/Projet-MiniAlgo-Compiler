#ifndef TS_H
#define TS_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define TAILLE 1000

typedef struct symbole {
    char nom[50];
    char type[20];
    char nature[20];   // variable | constante | kw | sep
    float valeur;
    int taille;
    struct symbole* suivant;
} symbole;

extern symbole* table[TAILLE];

int hash(char* nom);
symbole* rechercher(char* nom);

void inserer(char* nom, char* type, char* nature, float valeur, int taille);

void afficher();

#endif