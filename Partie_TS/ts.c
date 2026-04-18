#include "ts.h"

symbole* table[TAILLE] = {NULL};

int hash(char* nom)
{
    int somme = 0;
    for(int i = 0; nom[i] != '\0'; i++)
        somme += nom[i];
    return somme % TAILLE;
}

symbole* rechercher(char* nom)
{
    int h = hash(nom);
    symbole* temp = table[h];

    while(temp)
    {
        if(strcmp(temp->nom, nom) == 0)
            return temp;
        temp = temp->suivant;
    }
    return NULL;
}

void inserer(char* nom, char* type, char* nature, float valeur, int taille)
{
    symbole* exist = rechercher(nom);
    if(exist != NULL) {
    // update if it's array
    if(strcmp(nature, "tableau") == 0) {
        strcpy(exist->nature, "tableau");
        exist->taille = taille;
    }
    return;
}
    int h = hash(nom);

    symbole* nouv = (symbole*)malloc(sizeof(symbole));

    strcpy(nouv->nom, nom);
    strcpy(nouv->type, type);
    strcpy(nouv->nature, nature);

    nouv->valeur = valeur;
    nouv->taille = taille;

    nouv->suivant = table[h];
    table[h] = nouv;
}

void afficher()
{
    printf("\n===== TABLE DES SYMBOLES =====\n");

    printf("\n--- IDFS ---\n");
    printf("%-15s %-10s %-12s %-10s\n", "Nom", "Type", "Nature", "Valeur");
    printf("--------------------------------------------------\n");

    for(int i = 0; i < TAILLE; i++)
    {
        symbole* t = table[i];
        while(t)
        {
            if(strcmp(t->nature, "variable") == 0 || strcmp(t->nature, "-") == 0)
            {
                printf("%-15s %-10s %-12s %-10s\n",
       t->nom,
       t->type,
       t->nature,
       strcmp(t->nature,"variable")==0 ? "-" : "-");
            }
            t = t->suivant;
        }
    }

    printf("\n--- CONSTANTES ---\n");
    printf("%-15s %-10s %-12s %-10s\n", "Nom", "Type", "Nature", "Valeur");
    printf("--------------------------------------------------\n");

    for(int i = 0; i < TAILLE; i++)
    {
        symbole* t = table[i];
        while(t)
        {
            if(strcmp(t->nature, "constante") == 0)
            {
                printf("%-15s %-10s %-12s %-10.2f\n",
                       t->nom,
                       t->type,
                       t->nature,
                       t->valeur);
            }
            t = t->suivant;
        }
    }

    printf("\n--- TABLEAUX ---\n");
printf("%-15s %-10s %-12s %-10s\n", "Nom", "Type", "Nature", "Taille");
printf("--------------------------------------------------\n");

for(int i = 0; i < TAILLE; i++)
{
    symbole* t = table[i];
    while(t)
    {
        if(strcmp(t->nature, "tableau") == 0)
        {
            printf("%-15s %-10s %-12s %-10d\n",
                   t->nom,
                   t->type,
                   t->nature,
                   t->taille);
        }
        t = t->suivant;
    }
}
    printf("\n--- KEYWORDS ---\n");
    printf("%-15s %-10s\n", "Nom", "Nature");

    for(int i = 0; i < TAILLE; i++)
    {
        symbole* t = table[i];
        while(t)
        {
            if(strcmp(t->nature, "kw") == 0)
                printf("%-15s %-10s\n", t->nom, t->nature);
            t = t->suivant;
        }
    }

    printf("\n--- SEPARATEURS ---\n");
    printf("%-15s %-10s\n", "Nom", "Nature");

    for(int i = 0; i < TAILLE; i++)
    {
        symbole* t = table[i];
        while(t)
        {
            if(strcmp(t->nature, "sep") == 0)
                printf("%-15s %-10s\n", t->nom, t->nature);
            t = t->suivant;
        }
    }
}