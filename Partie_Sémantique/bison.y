%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ts.h"

extern int nb_ligne;
extern int col;
extern char* token_courant;
char* current_type = NULL;

void yyerror(const char *s);
int yylex();
%}

%union{
int integer;
float float_val;
char* str;
}

%start programme

%token PROGRAM DECL ENDDECL TBEGIN TEND
%token CONST ENTIER REEL
%token IF ELSE FOR WHILE
%token READ WRITE
%token PLUS MOINS FOIS DIVISE
%token ET OU NON
%token PLUS_GRAND PLUS_PETIT SUP_EGAL INF_EGAL EGAL_EGAL DIFF
%token EGAL

%token VIRGULE POINT_VIRGULE DEUX_POINTS
%token PARENTHESE_OUVRANTE PARENTHESE_FERMANTE
%token CROCHET_OUVRANT CROCHET_FERMANT
%token ACCOLADE_OUVRANTE ACCOLADE_FERMANTE

%token <integer> CONST_ENTIERE
%token <float_val> CONST_REELLE
%token <str> IDENTIFIANT
%type <float_val> expression
%type <str> type
%type <float_val> valeur

%left PLUS MOINS
%left FOIS DIVISE
%left ET OU
%left PLUS_GRAND PLUS_PETIT SUP_EGAL INF_EGAL
%left EGAL_EGAL DIFF
%right NON

%%

programme:
PROGRAM IDENTIFIANT DECL declarations ENDDECL TBEGIN instructions TEND{
    inserer($2, "IDF", "-", 0, 0);
}
;

declarations:
declarations declaration
|
;

declaration:
    type DEUX_POINTS liste_identifiants POINT_VIRGULE
    {
        current_type = NULL;
    }
|    type DEUX_POINTS IDENTIFIANT CROCHET_OUVRANT CONST_ENTIERE CROCHET_FERMANT POINT_VIRGULE
    {
        if($5 <= 0)
            printf("Erreur Semantique : taille tableau invalide pour %s\n", $3);
        else if(strcmp(current_type, "BOOLEAN") == 0)
            printf("Erreur Semantique : type de tableau non supporte BOOLEAN\n");
        else
            inserer($3, current_type, "tableau", 0, $5);
    }
|   CONST IDENTIFIANT EGAL valeur POINT_VIRGULE
    {
        inserer($2, "CONST", "constante", $4, 0);
    }
;

type:
ENTIER { current_type = "INTEGER"; $$ = "INTEGER"; }
| REEL { current_type = "FLOAT"; $$ = "FLOAT"; }
;

liste_identifiants:
IDENTIFIANT {
    if(estDeclare($1))
        printf("Erreur Semantique : double declaration de %s\n", $1);
    else
        inserer($1, current_type, "variable", 0, 0);
}
| liste_identifiants VIRGULE IDENTIFIANT {
    if(estDeclare($3))
        printf("Erreur Semantique : double declaration de %s\n", $3);
    else
        inserer($3, current_type, "variable", 0, 0);
}
;

valeur:
CONST_ENTIERE { $$ = (float)$1; }
| CONST_REELLE { $$ = $1; }
;

instructions:
instructions instruction
|
;

instruction:
IDENTIFIANT EGAL expression POINT_VIRGULE
{
    symbole* s = rechercher($1);

    if(!estDeclare($1))
        printf("Erreur Semantique : %s non declare\n", $1);

    else if(estConstante($1))
        printf("Erreur Semantique : modification de constante %s\n", $1);

    else if(s && strcmp(s->type, "INTEGER") == 0 && $3 != (int)$3)
        printf("Erreur Semantique : incompatibilite de type pour %s (reel affecte a un entier)\n", $1);
}
| IDENTIFIANT CROCHET_OUVRANT expression CROCHET_FERMANT EGAL expression POINT_VIRGULE
{
    symbole* s = rechercher($1);

    if(!estDeclare($1))
        printf("Erreur Semantique : tableau %s non declare\n", $1);

    else if(!estTableau($1))
        printf("Erreur Semantique : %s n'est pas un tableau\n", $1);

    else if($3 >= s->taille)
        printf("Erreur Semantique : indice hors limites pour %s\n", $1);
}
| IF PARENTHESE_OUVRANTE expression PARENTHESE_FERMANTE ACCOLADE_OUVRANTE instructions ACCOLADE_FERMANTE
| IF PARENTHESE_OUVRANTE expression PARENTHESE_FERMANTE ACCOLADE_OUVRANTE instructions ACCOLADE_FERMANTE ELSE ACCOLADE_OUVRANTE instructions ACCOLADE_FERMANTE
| FOR PARENTHESE_OUVRANTE IDENTIFIANT DEUX_POINTS expression DEUX_POINTS expression DEUX_POINTS expression PARENTHESE_FERMANTE ACCOLADE_OUVRANTE instructions ACCOLADE_FERMANTE
| WHILE PARENTHESE_OUVRANTE expression PARENTHESE_FERMANTE ACCOLADE_OUVRANTE instructions  ACCOLADE_FERMANTE
| READ PARENTHESE_OUVRANTE IDENTIFIANT PARENTHESE_FERMANTE POINT_VIRGULE
{
    if(!estDeclare($3))
        printf("Erreur Semantique : %s non declare\n", $3);
}
| WRITE PARENTHESE_OUVRANTE IDENTIFIANT PARENTHESE_FERMANTE POINT_VIRGULE
;

expression:
expression PLUS expression      { $$ = $1 + $3; }
| expression MOINS expression   { $$ = $1 - $3; }
| expression FOIS expression    { $$ = $1 * $3; }
| expression DIVISE expression
{
    if($3 == 0)
        printf("Erreur Semantique : division par zero\n");
    $$ = ($3 != 0) ? $1 / $3 : 0;
}
| expression ET expression      { $$ = $1 && $3; }
| expression OU expression      { $$ = $1 || $3; }
| expression PLUS_GRAND expression  { $$ = $1 > $3; }
| expression PLUS_PETIT expression  { $$ = $1 < $3; }
| expression SUP_EGAL expression    { $$ = $1 >= $3; }
| expression INF_EGAL expression    { $$ = $1 <= $3; }
| expression EGAL_EGAL expression   { $$ = $1 == $3; }
| expression DIFF expression        { $$ = $1 != $3; }
| NON expression                    { $$ = !$2; }
| CONST_ENTIERE { $$ = $1; }
| CONST_REELLE  { $$ = $1; }
| IDENTIFIANT
{
    symbole* s = rechercher($1);
    if(s && strcmp(s->nature, "constante") == 0)
        $$ = s->valeur;   // constante déclarée → on récupère sa valeur
    else
        $$ = -1;          // variable → valeur sentinelle "inconnue"
}
| PARENTHESE_OUVRANTE expression PARENTHESE_FERMANTE { $$ = $2; }
;

%%

void yyerror(const char *s)
{
    if (strcmp(s, "syntax error") == 0 && token_courant != NULL) {
        printf("Erreur Syntaxique : ligne %d colonne %d - Point-virgule manquant après '%s'\n",
            nb_ligne, col, token_courant);
    } else {
        printf("Erreur Syntaxique : ligne %d colonne %d element %s\n",
            nb_ligne, col, token_courant);
    }
}

int main()
{
    if(yyparse()==0)
    {
        printf("Analyse syntaxique terminée avec succès.\n");
        printf("Analyses lexicale et syntaxique réussies.\n");
        afficher();
    }
    else
    {
        printf("Erreur d'analyse.\n");
    }
    return 0;
}