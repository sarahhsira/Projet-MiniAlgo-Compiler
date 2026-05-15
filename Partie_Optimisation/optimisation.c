#include "optimisation.h"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>

extern qdr quad[1000];
extern int qc;

static int nb_optimisations_appliquees = 0;

int est_temporaire(char* var) {
    if (var == NULL) return 0;
    return (var[0] == 'T' && strlen(var) > 1 && isdigit(var[1]));
}

int est_constante_litterale(char* var) {
    if (var == NULL) return 0;
    int i = 0;
    if (var[0] == '-') i = 1;
    for (; var[i]; i++) {
        if (!isdigit(var[i])) return 0;
    }
    return 1;
}

int valeur_constante(char* var) {
    if (var == NULL) return 0;
    return atoi(var);
}

int expressions_identiques(char* op1, char* a1, char* a2, char* op2, char* b1, char* b2) {
    if (strcmp(op1, op2) != 0) return 0;

    if (strcmp(op1, "+") == 0 || strcmp(op1, "*") == 0 ||
        strcmp(op1, "&&") == 0 || strcmp(op1, "||") == 0) {
        return (strcmp(a1, b1) == 0 && strcmp(a2, b2) == 0) ||
               (strcmp(a1, b2) == 0 && strcmp(a2, b1) == 0);
    }

    return (strcmp(a1, b1) == 0 && strcmp(a2, b2) == 0);
}

void optimiser_propagation_copie()
{
    int changements=1;

    while(changements)
    {
        changements=0;

        for(int i=0;i<qc;i++)
        {
            if(strcmp(quad[i].op,"=")==0)
            {
                char source[100];
                char destination[100];

                strcpy(source,quad[i].arg1);
                strcpy(destination,quad[i].result);

                /* IMPORTANT */
                if(est_constante_litterale(source))
                    continue;

                int propagation_faite=0;

                for(int j=i+1;j<qc;j++)
                {
                    if(strcmp(quad[j].result,destination)==0)
                        break;

                    if(strcmp(quad[j].result,source)==0)
                        break;

                    if(strcmp(quad[j].arg1,destination)==0)
                    {
                        strcpy(quad[j].arg1,source);

                        propagation_faite=1;
                        changements=1;
                    }

                    if(strcmp(quad[j].arg2,destination)==0)
                    {
                        strcpy(quad[j].arg2,source);

                        propagation_faite=1;
                        changements=1;
                    }
                }

                if(propagation_faite)
                {
                    strcpy(quad[i].op,"NOP");
                }
            }
        }

        int nv=0;

        for(int i=0;i<qc;i++)
        {
            if(strcmp(quad[i].op,"NOP")!=0)
            {
                quad[nv]=quad[i];
                nv++;
            }
        }

        qc=nv;
    }
}

void propagation_expression()
{
    for(int i=0;i<qc;i++)
    {
        if(strcmp(quad[i].result,"")==0)
            continue;

        for(int j=i+1;j<qc;j++)
        {
            if(strcmp(quad[j].arg1,quad[i].result)==0)
            {
                strcpy(quad[j].arg1,quad[i].arg1);
            }

            if(strcmp(quad[j].arg2,quad[i].result)==0)
            {
                strcpy(quad[j].arg2,quad[i].arg1);
            }
        }
    }
}

/* OPTIMISATION 3: ÉLIMINATION D'EXPRESSIONS REDONDANTES */
void optimiser_expressions_redondantes(void) {
    for (int i = 0; i < qc; i++) {
        if (strcmp(quad[i].op, "=") == 0) continue;

        for (int j = 0; j < i; j++) {
            if (strcmp(quad[j].op, "=") != 0 &&
                expressions_identiques(quad[i].op, quad[i].arg1, quad[i].arg2,
                                      quad[j].op, quad[j].arg1, quad[j].arg2)) {
                int modifie = 0;
                for (int k = j + 1; k < i; k++) {
                    if (strcmp(quad[k].result, quad[i].arg1) == 0 ||
                        strcmp(quad[k].result, quad[i].arg2) == 0) {
                        modifie = 1;
                        break;
                    }
                }

                if (!modifie) {
                    strcpy(quad[i].op, "=");
                    strcpy(quad[i].arg1, quad[j].result);
                    strcpy(quad[i].arg2, "");
                    nb_optimisations_appliquees++;
                    break;
                }
            }
        }
    }
}

/* OPTIMISATION 4: SIMPLIFICATION ALGÉBRIQUE */
void optimiser_simplification_algebrique()
{
    for(int i=0;i<qc;i++)
    {

        /******** x+0=x ********/
        if(strcmp(quad[i].op,"+")==0)
        {
            if(strcmp(quad[i].arg2,"0")==0)
            {
                strcpy(quad[i].op,"=");
                strcpy(quad[i].arg2,"");

                nb_optimisations_appliquees++;
            }

            else if(strcmp(quad[i].arg1,"0")==0)
            {
                strcpy(quad[i].op,"=");
                strcpy(quad[i].arg1,quad[i].arg2);
                strcpy(quad[i].arg2,"");

                nb_optimisations_appliquees++;
            }
        }


        /******** x-0=x ********/

        if(strcmp(quad[i].op,"-")==0 &&
           strcmp(quad[i].arg2,"0")==0)
        {
            strcpy(quad[i].op,"=");
            strcpy(quad[i].arg2,"");

            nb_optimisations_appliquees++;
        }


        /******** x-x=0 ********/

        if(strcmp(quad[i].op,"-")==0 &&
           strcmp(quad[i].arg1,
                  quad[i].arg2)==0)
        {
            strcpy(quad[i].op,"=");
            strcpy(quad[i].arg1,"0");
            strcpy(quad[i].arg2,"");

            nb_optimisations_appliquees++;
        }


        /******** x*1=x ********/

        if(strcmp(quad[i].op,"*")==0)
        {
            if(strcmp(quad[i].arg2,"1")==0)
            {
                strcpy(quad[i].op,"=");
                strcpy(quad[i].arg2,"");

                nb_optimisations_appliquees++;
            }

            else if(strcmp(quad[i].arg1,"1")==0)
            {
                strcpy(quad[i].op,"=");
                strcpy(quad[i].arg1,
                       quad[i].arg2);

                strcpy(quad[i].arg2,"");

                nb_optimisations_appliquees++;
            }
        }



        /******** x*0=0 ********/

        if(strcmp(quad[i].op,"*")==0)
        {
            if(strcmp(quad[i].arg1,"0")==0 ||
               strcmp(quad[i].arg2,"0")==0)
            {
                strcpy(quad[i].op,"=");
                strcpy(quad[i].arg1,"0");
                strcpy(quad[i].arg2,"");

                nb_optimisations_appliquees++;
            }
        }



        /******** x*2=x+x ********/

        if(strcmp(quad[i].op,"*")==0)
        {

            if(strcmp(quad[i].arg2,"2")==0)
            {
                strcpy(quad[i].op,"+");

                strcpy(
                    quad[i].arg2,
                    quad[i].arg1
                );

                nb_optimisations_appliquees++;
            }

            else if(strcmp(
                    quad[i].arg1,"2")==0)
            {
                strcpy(quad[i].op,"+");

                strcpy(
                    quad[i].arg1,
                    quad[i].arg2
                );

                nb_optimisations_appliquees++;
            }

        }



        /******** x/1=x ********/

        if(strcmp(quad[i].op,"/")==0 &&
           strcmp(quad[i].arg2,"1")==0)
        {
            strcpy(quad[i].op,"=");
            strcpy(quad[i].arg2,"");

            nb_optimisations_appliquees++;
        }



        /******** x^1=x ********/

        if(strcmp(quad[i].op,"^")==0 &&
           strcmp(quad[i].arg2,"1")==0)
        {
            strcpy(quad[i].op,"=");
            strcpy(quad[i].arg2,"");

            nb_optimisations_appliquees++;
        }



        /******** x^0=1 ********/

        if(strcmp(quad[i].op,"^")==0 &&
           strcmp(quad[i].arg2,"0")==0)
        {
            strcpy(quad[i].op,"=");
            strcpy(quad[i].arg1,"1");
            strcpy(quad[i].arg2,"");

            nb_optimisations_appliquees++;
        }

    }
}

/* OPTIMISATION 5: ÉLIMINATION DE CODE MORT  */
void optimiser_code_mort()
{
for(int i=0;i<qc;i++)
{
int utilise=0;

for(int j=i+1;j<qc;j++)
{

if(
strcmp(quad[j].arg1,
quad[i].result)==0 ||

strcmp(quad[j].arg2,
quad[i].result)==0
)

utilise=1;
}

if(!utilise && quad[i].result[0]=='T')
{
 for(int k = i; k < qc - 1; k++)
            {
                quad[k] = quad[k + 1];
            }
            qc--;
            i--; // IMPORTANT pour ne pas sauter un quad
        }
    }
}



/* APPLIQUER TOUTES LES OPTIMISATIONS */
void optimiser_tout(void) {
    int avant = qc;
    nb_optimisations_appliquees = 0;

    /* Ne pas modifier le code si aucune optimisation n'est possible */
    int original_qc = qc;

    /* Première passe */
    optimiser_propagation_copie();
    optimiser_simplification_algebrique();
    optimiser_expressions_redondantes();
    optimiser_code_mort();

    /* Deuxième passe */
    optimiser_propagation_copie();
    optimiser_simplification_algebrique();
    optimiser_expressions_redondantes();
    optimiser_code_mort();

    int apres = qc;

    if (nb_optimisations_appliquees > 0 || avant != apres) {
        printf("\n╔════════════════════════════════════════════════════════════╗\n");
        printf("║                    OPTIMISATION EFFECTUÉE                   ║\n");
        printf("╚════════════════════════════════════════════════════════════╝\n");
        printf("  Quadruplets avant optimisation : %d\n", avant);
        printf("  Quadruplets après optimisation  : %d\n", apres);
        printf("  Réduction                       : %d quadruplets (%.1f%%)\n",
               avant - apres,
               (avant - apres) * 100.0 / avant);
    } else {
        printf("\n╔════════════════════════════════════════════════════════════╗\n");
        printf("║              AUCUNE OPTIMISATION NÉCESSAIRE                 ║\n");
        printf("╚════════════════════════════════════════════════════════════╝\n");
        printf("  Le code est déjà optimal.\n");
    }
}