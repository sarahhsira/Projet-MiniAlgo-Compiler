#ifndef TS_H
#define TS_H

#define TAILLE 100

typedef struct symbole {
    char nom[20];
    char type[10];
    char nature[10];
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