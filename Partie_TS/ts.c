#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ts.h"

symbole* table[TAILLE];

int hash(char* nom) {
    int somme = 0;
    for(int i=0; nom[i]!='\0'; i++)
        somme += nom[i];
    return somme % TAILLE;
}

symbole* rechercher(char* nom) {
    int h = hash(nom);
    symbole* temp = table[h];

    while(temp) {
        if(strcmp(temp->nom, nom) == 0)
            return temp;
        temp = temp->suivant;
    }
    return NULL;
}

void inserer(char* nom, char* type, char* nature, float valeur, int taille) {
    if(rechercher(nom) != NULL) {
        printf("Erreur semantique : double declaration de %s\n", nom);
        return;
    }

    int h = hash(nom);
    symbole* nouv = malloc(sizeof(symbole));

    strcpy(nouv->nom, nom);
    strcpy(nouv->type, type);
    strcpy(nouv->nature, nature);
    nouv->valeur = valeur;
    nouv->taille = taille;

    nouv->suivant = table[h];
    table[h] = nouv;
}

void afficher() {
    printf("\n===== TABLE DES SYMBOLES =====\n");

    printf("\n--- CONSTANTES ---\n");
    printf("%-20s %-10s %-10s %-10s %-10s\n",
           "Nom", "Type", "Nature", "Valeur", "Taille");

    printf("-------------------------------------------------------------\n");

    for(int i=0; i<TAILLE; i++) {
        symbole* temp = table[i];
        while(temp) {

            if(strcmp(temp->nature, "constante") == 0) {

                if(temp->valeur == (int)temp->valeur)
                    printf("%-20s %-10s %-10s %-10.0f %-10d\n",
                           temp->nom, temp->type, temp->nature,
                           temp->valeur, temp->taille);
                else
                    printf("%-20s %-10s %-10s %-10.2f %-10d\n",
                           temp->nom, temp->type, temp->nature,
                           temp->valeur, temp->taille);
            }

            temp = temp->suivant;
        }
    }

    printf("\n--- VARIABLES ---\n");
    printf("%-20s %-10s %-10s %-10s %-10s\n",
           "Nom", "Type", "Nature", "Valeur", "Taille");

    printf("-------------------------------------------------------------\n");

    for(int i=0; i<TAILLE; i++) {
        symbole* temp = table[i];
        while(temp) {

            if(strcmp(temp->nature, "variable") == 0) {

                if(temp->valeur == 0)
                    printf("%-20s %-10s %-10s %-10s %-10d\n",
                           temp->nom, temp->type, temp->nature,
                           "-", temp->taille);
                else if(temp->valeur == (int)temp->valeur)
                    printf("%-20s %-10s %-10s %-10.0f %-10d\n",
                           temp->nom, temp->type, temp->nature,
                           temp->valeur, temp->taille);
                else
                    printf("%-20s %-10s %-10s %-10.2f %-10d\n",
                           temp->nom, temp->type, temp->nature,
                           temp->valeur, temp->taille);
            }

            temp = temp->suivant;
        }
    }

    printf("\n--- TABLEAUX ---\n");
    printf("%-20s %-10s %-10s %-10s %-10s\n",
           "Nom", "Type", "Nature", "Valeur", "Taille");

    printf("-------------------------------------------------------------\n");

    for(int i=0; i<TAILLE; i++) {
        symbole* temp = table[i];
        while(temp) {

            if(strcmp(temp->nature, "tableau") == 0) {

                printf("%-20s %-10s %-10s %-10s %-10d\n",
                       temp->nom,
                       temp->type,
                       temp->nature,
                       "-",
                       temp->taille);
            }

            temp = temp->suivant;
        }
    }
}