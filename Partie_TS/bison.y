%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ts.h"

extern int nb_ligne;
extern int col;
extern char* token_courant;

char type_courant[10];

void yyerror(const char *s);
int yylex();
%}

%union{
int integer;
float float_val;
char* str;
}

%type <float_val> valeur
%type <float_val> expression

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

%left PLUS MOINS
%left FOIS DIVISE
%left ET OU
%left PLUS_GRAND PLUS_PETIT SUP_EGAL INF_EGAL
%left EGAL_EGAL DIFF
%right NON

%%

programme:
PROGRAM IDENTIFIANT DECL declarations ENDDECL TBEGIN instructions TEND
;

declarations:
declarations declaration
|
;

declaration:
type DEUX_POINTS liste_identifiants POINT_VIRGULE
| type DEUX_POINTS IDENTIFIANT CROCHET_OUVRANT CONST_ENTIERE CROCHET_FERMANT POINT_VIRGULE
{
    inserer($3, type_courant, "tableau", 0, $5);
}
| CONST IDENTIFIANT EGAL valeur POINT_VIRGULE {
    inserer($2, type_courant, "constante", $4, 0);
}
;

type:
ENTIER { strcpy(type_courant, "ENTIER"); }
| REEL { strcpy(type_courant, "REEL"); }
;

liste_identifiants:
IDENTIFIANT  {
    inserer($1, type_courant, "variable", 0, 1);
}
| IDENTIFIANT VIRGULE liste_identifiants {
    inserer($1, type_courant, "variable", 0, 1);
}
;

valeur:
CONST_ENTIERE { $$ = $1; }
| CONST_REELLE { $$ = $1; }
;

instructions:
instructions instruction
|
;

instruction:
IDENTIFIANT EGAL expression POINT_VIRGULE  {
    symbole* s = rechercher($1);
if(s != NULL)
    s->valeur = $3;
}

| IDENTIFIANT CROCHET_OUVRANT expression CROCHET_FERMANT EGAL expression POINT_VIRGULE
| IF PARENTHESE_OUVRANTE expression PARENTHESE_FERMANTE ACCOLADE_OUVRANTE instructions ACCOLADE_FERMANTE
| IF PARENTHESE_OUVRANTE expression PARENTHESE_FERMANTE ACCOLADE_OUVRANTE instructions ACCOLADE_FERMANTE ELSE ACCOLADE_OUVRANTE instructions ACCOLADE_FERMANTE
| FOR PARENTHESE_OUVRANTE IDENTIFIANT DEUX_POINTS expression DEUX_POINTS expression DEUX_POINTS expression PARENTHESE_FERMANTE ACCOLADE_OUVRANTE instructions ACCOLADE_FERMANTE
| WHILE PARENTHESE_OUVRANTE expression PARENTHESE_FERMANTE ACCOLADE_OUVRANTE instructions  ACCOLADE_FERMANTE
| READ PARENTHESE_OUVRANTE IDENTIFIANT PARENTHESE_FERMANTE POINT_VIRGULE
| WRITE PARENTHESE_OUVRANTE IDENTIFIANT PARENTHESE_FERMANTE POINT_VIRGULE
;

expression:
expression PLUS expression { $$ = $1 + $3; }
| expression MOINS expression { $$ = $1 - $3; }
| expression FOIS expression { $$ = $1 * $3; }
| expression DIVISE expression { $$ = $1 / $3; }
| expression ET expression  { $$ = $1 && $3; }
| expression OU expression  { $$ = $1 || $3; }
| expression PLUS_GRAND expression { $$ = $1 > $3; }
| expression PLUS_PETIT expression  { $$ = $1 < $3; }
| expression SUP_EGAL expression { $$ = $1 >= $3; }
| expression INF_EGAL expression  { $$ = $1 <= $3; }
| expression EGAL_EGAL expression { $$ = $1 == $3; }
| expression DIFF expression { $$ = $1 != $3; }
| NON expression  { $$ = !$2; }
| CONST_ENTIERE { $$ = $1; }
| CONST_REELLE { $$ = $1; }
| IDENTIFIANT {
    symbole* s = rechercher($1);
    if(s != NULL)
        $$ = s->valeur;
    else
        $$ = 0;
}
| PARENTHESE_OUVRANTE expression PARENTHESE_FERMANTE { $$ = $2; }
;

%%

void yyerror(const char *s)
{
printf("Erreur Syntaxique : ligne %d colonne %d element %s\n",nb_ligne,col,token_courant);
}

int main()
{
for(int i=0;i<TAILLE;i++) table[i]=NULL;

     int res = yyparse();

    if(res == 0)
    {
        printf("Analyse syntaxique terminée avec succès.\n");
        printf("Analyses lexicale et syntaxique réussies.\n");
    }
    else
    {
        printf("Erreur d'analyse.\n");
    }

    afficher();

    return 0;
}