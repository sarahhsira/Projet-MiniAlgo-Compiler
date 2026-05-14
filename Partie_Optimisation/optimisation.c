#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>

#include "quad.h"

int est_nombre(char *s)
{
    if(s == NULL || strlen(s) == 0)
        return 0;

    int i = 0;

    if(s[0] == '-')
        i++;

    for(; s[i]; i++)
    {
        if(!isdigit(s[i]) && s[i] != '.')
            return 0;
    }

    return 1;
}

void propagation_constantes()
{
    for(int i=0 ; i<qc ; i++)
    {
        if(strcmp(quad[i].op, "=")==0)
        {
            if(est_nombre(quad[i].arg1))
            {
                char var[100];
                strcpy(var, quad[i].result);

                char val[100];
                strcpy(val, quad[i].arg1);

                for(int j=i+1 ; j<qc ; j++)
                {
                    if(strcmp(quad[j].arg1, var)==0)
                        strcpy(quad[j].arg1, val);

                    if(strcmp(quad[j].arg2, var)==0)
                        strcpy(quad[j].arg2, val);
                }
            }
        }
    }
}

void simplification_constantes()
{
    for(int i=0 ; i<qc ; i++)
    {
        if(
            strcmp(quad[i].op, "+")==0 ||
            strcmp(quad[i].op, "-")==0 ||
            strcmp(quad[i].op, "*")==0 ||
            strcmp(quad[i].op, "/")==0
        )
        {
            if(est_nombre(quad[i].arg1) && est_nombre(quad[i].arg2))
            {
                float a = atof(quad[i].arg1);
                float b = atof(quad[i].arg2);

                float res;

                if(strcmp(quad[i].op, "+")==0)
                    res = a + b;

                else if(strcmp(quad[i].op, "-")==0)
                    res = a - b;

                else if(strcmp(quad[i].op, "*")==0)
                    res = a * b;

                else
                {
                    if(b == 0)
                        continue;

                    res = a / b;
                }

                sprintf(quad[i].op, "=");
                sprintf(quad[i].arg1, "%.2f", res);
                strcpy(quad[i].arg2, "");
            }
        }
    }
}

void elimination_code_inutile()
{
    for(int i=0 ; i<qc ; i++)
    {
        if(strcmp(quad[i].result, "") != 0)
        {
            int utilise = 0;

            for(int j=i+1 ; j<qc ; j++)
            {
                if(
                    strcmp(quad[j].arg1, quad[i].result)==0 ||
                    strcmp(quad[j].arg2, quad[i].result)==0
                )
                {
                    utilise = 1;
                    break;
                }
            }

            if(!utilise && quad[i].result[0]=='T')
            {
                strcpy(quad[i].op, "SUPPRIME");
            }
        }
    }
}

void sous_expressions_communes()
{
    for(int i=0 ; i<qc ; i++)
    {
        for(int j=i+1 ; j<qc ; j++)
        {
            if(
                strcmp(quad[i].op, quad[j].op)==0 &&
                strcmp(quad[i].arg1, quad[j].arg1)==0 &&
                strcmp(quad[i].arg2, quad[j].arg2)==0
            )
            {
                char ancien[100];
                strcpy(ancien, quad[j].result);

                for(int k=j+1 ; k<qc ; k++)
                {
                    if(strcmp(quad[k].arg1, ancien)==0)
                        strcpy(quad[k].arg1, quad[i].result);

                    if(strcmp(quad[k].arg2, ancien)==0)
                        strcpy(quad[k].arg2, quad[i].result);
                }

                strcpy(quad[j].op, "SUPPRIME");
            }
        }
    }
}

void optimiser()
{
    propagation_constantes();

    simplification_constantes();

    sous_expressions_communes();

    elimination_code_inutile();
}