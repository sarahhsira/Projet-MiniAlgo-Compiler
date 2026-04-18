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
    current_type = NULL; // reset after use
}
| type DEUX_POINTS IDENTIFIANT CROCHET_OUVRANT CONST_ENTIERE CROCHET_FERMANT POINT_VIRGULE
| CONST IDENTIFIANT EGAL valeur POINT_VIRGULE {
    inserer($2, "CONST", "constante", $4, 0);
}
;

type:
ENTIER { current_type = "INTEGER"; $$ = "INTEGER"; }
| REEL { current_type = "FLOAT"; $$ = "FLOAT"; }
;

liste_identifiants:
IDENTIFIANT {
    inserer($1, current_type, "variable", 0, 0);
}
| liste_identifiants VIRGULE IDENTIFIANT {
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
| IDENTIFIANT CROCHET_OUVRANT expression CROCHET_FERMANT EGAL expression POINT_VIRGULE
| IF PARENTHESE_OUVRANTE expression PARENTHESE_FERMANTE ACCOLADE_OUVRANTE instructions ACCOLADE_FERMANTE
| IF PARENTHESE_OUVRANTE expression PARENTHESE_FERMANTE ACCOLADE_OUVRANTE instructions ACCOLADE_FERMANTE ELSE ACCOLADE_OUVRANTE instructions ACCOLADE_FERMANTE
| FOR PARENTHESE_OUVRANTE IDENTIFIANT DEUX_POINTS expression DEUX_POINTS expression DEUX_POINTS expression PARENTHESE_FERMANTE ACCOLADE_OUVRANTE instructions ACCOLADE_FERMANTE
| WHILE PARENTHESE_OUVRANTE expression PARENTHESE_FERMANTE ACCOLADE_OUVRANTE instructions  ACCOLADE_FERMANTE
| READ PARENTHESE_OUVRANTE IDENTIFIANT PARENTHESE_FERMANTE POINT_VIRGULE
| WRITE PARENTHESE_OUVRANTE IDENTIFIANT PARENTHESE_FERMANTE POINT_VIRGULE
;

expression:
expression PLUS expression
| expression MOINS expression
| expression FOIS expression
| expression DIVISE expression
| expression ET expression
| expression OU expression
| expression PLUS_GRAND expression
| expression PLUS_PETIT expression
| expression SUP_EGAL expression
| expression INF_EGAL expression
| expression EGAL_EGAL expression
| expression DIFF expression
| NON expression
| CONST_ENTIERE
| CONST_REELLE
| IDENTIFIANT
| PARENTHESE_OUVRANTE expression PARENTHESE_FERMANTE
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