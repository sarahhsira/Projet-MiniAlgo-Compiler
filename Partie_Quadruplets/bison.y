%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ts.h"
#include "quad.h"   

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
%type <str> expression // résultat = nom du temporaire ou identifiant
%type <str> type
%type <float_val> valeur

%left OU
%left ET
%left EGAL_EGAL DIFF
%left PLUS_GRAND PLUS_PETIT SUP_EGAL INF_EGAL
%left PLUS MOINS
%left FOIS DIVISE
%right NON
%nonassoc THEN
%nonassoc ELSE
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
marqueur_if:
  IF PARENTHESE_OUVRANTE expression PARENTHESE_FERMANTE ACCOLADE_OUVRANTE
  {
      int q = ajouter_quad("BRFALSE", $3, "-", "?");
      $<integer>$ = q;
  }
;
instruction:
IDENTIFIANT EGAL expression POINT_VIRGULE
{
    symbole* s = rechercher($1);
    if(!estDeclare($1))
        printf("Erreur Semantique : %s non declare\n", $1);
    else if(estConstante($1))
        printf("Erreur Semantique : modification de constante %s\n", $1);
    else if(s && strcmp(s->type, "INTEGER") == 0 && atof($3) != (int)atof($3))
        printf("Erreur Semantique : incompatibilite de type pour %s (reel affecte a un entier)\n", $1);
    else
        ajouter_quad("=", $3, "-", $1);
}

| IDENTIFIANT CROCHET_OUVRANT expression CROCHET_FERMANT EGAL expression POINT_VIRGULE
{
    symbole* s = rechercher($1);
    if(!estDeclare($1))
        printf("Erreur Semantique : tableau %s non declare\n", $1);
    else if(!estTableau($1))
        printf("Erreur Semantique : %s n'est pas un tableau\n", $1);
    else if((int)atof($3) >= s->taille)
        printf("Erreur Semantique : indice hors limites pour %s\n", $1);
    else {
        char index_result[50];
        sprintf(index_result, "%s[%s]", $1, $3);
        ajouter_quad("=", $6, "-", index_result);
    }
}

| marqueur_if instructions ACCOLADE_FERMANTE %prec THEN
{
    char cible[10];
    sprintf(cible, "%d", qc);
    patcher($<integer>1, cible);
}

| marqueur_if instructions ACCOLADE_FERMANTE ELSE
{
    int q_br = ajouter_quad("BR", "-", "-", "?");
    char cible[10];
    sprintf(cible, "%d", qc);
    patcher($<integer>1, cible);
    $<integer>$ = q_br;
}
ACCOLADE_OUVRANTE instructions ACCOLADE_FERMANTE
{
    char cible[10];
    sprintf(cible, "%d", qc);
    patcher($<integer>5, cible);
}

| FOR PARENTHESE_OUVRANTE IDENTIFIANT DEUX_POINTS expression DEUX_POINTS expression DEUX_POINTS expression PARENTHESE_FERMANTE
{
    ajouter_quad("=", $5, "-", $3);
    $<integer>$ = qc;
}
ACCOLADE_OUVRANTE instructions ACCOLADE_FERMANTE
{
    char* t = nouveau_temp();
    ajouter_quad("+", $3, $9, t);
    ajouter_quad("=", t, "-", $3);
    char debut[10];
    sprintf(debut, "%d", $<integer>11);
    ajouter_quad("BR", "-", "-", debut);
}

| WHILE
{
    $<integer>$ = qc;
}
PARENTHESE_OUVRANTE expression PARENTHESE_FERMANTE
ACCOLADE_OUVRANTE
{
    int q = ajouter_quad("BRFALSE", $4, "-", "?");
    $<integer>$ = q;
}
instructions ACCOLADE_FERMANTE
{
    char debut[10];
    sprintf(debut, "%d", $<integer>2);
    ajouter_quad("BR", "-", "-", debut);
    char cible[10];
    sprintf(cible, "%d", qc);
    patcher($<integer>7, cible);
}

| READ PARENTHESE_OUVRANTE IDENTIFIANT PARENTHESE_FERMANTE POINT_VIRGULE
{
    if(!estDeclare($3))
        printf("Erreur Semantique : %s non declare\n", $3);
    else
        ajouter_quad("READ", $3, "-", "-");
}

| WRITE PARENTHESE_OUVRANTE IDENTIFIANT PARENTHESE_FERMANTE POINT_VIRGULE
{
    ajouter_quad("WRITE", $3, "-", "-");
}
;


expression:
  expression PLUS expression
  {
      char* t = nouveau_temp();
      ajouter_quad("+", $1, $3, t);
      $$ = t;
  }
| expression MOINS expression
  {
      char* t = nouveau_temp();
      ajouter_quad("-", $1, $3, t);
      $$ = t;
  }
| expression FOIS expression
  {
      char* t = nouveau_temp();
      ajouter_quad("*", $1, $3, t);
      $$ = t;
  }
| expression DIVISE expression
  {
      if(strcmp($3, "0") == 0) {
          // verifier constante 0 explicite
          symbole* s = rechercher($3);
          if(s == NULL || (s && strcmp(s->nature,"constante")==0 && s->valeur == 0))
              printf("Erreur Semantique : division par zero\n");
      }
      char* t = nouveau_temp();
      ajouter_quad("/", $1, $3, t);
      $$ = t;
  }
| expression ET expression
  {
      char* t = nouveau_temp();
      ajouter_quad("&&", $1, $3, t);
      $$ = t;
  }
| expression OU expression
  {
      char* t = nouveau_temp();
      ajouter_quad("||", $1, $3, t);
      $$ = t;
  }
| expression PLUS_GRAND expression
  {
      char* t = nouveau_temp();
      ajouter_quad(">", $1, $3, t);
      $$ = t;
  }
| expression PLUS_PETIT expression
  {
      char* t = nouveau_temp();
      ajouter_quad("<", $1, $3, t);
      $$ = t;
  }
| expression SUP_EGAL expression
  {
      char* t = nouveau_temp();
      ajouter_quad(">=", $1, $3, t);
      $$ = t;
  }
| expression INF_EGAL expression
  {
      char* t = nouveau_temp();
      ajouter_quad("<=", $1, $3, t);
      $$ = t;
  }
| expression EGAL_EGAL expression
  {
      char* t = nouveau_temp();
      ajouter_quad("==", $1, $3, t);
      $$ = t;
  }
| expression DIFF expression
  {
      char* t = nouveau_temp();
      ajouter_quad("!=", $1, $3, t);
      $$ = t;
  }
| NON expression
  {
      char* t = nouveau_temp();
      ajouter_quad("!", $2, "-", t);
      $$ = t;
  }
| CONST_ENTIERE
  {
      char* s = (char*)malloc(20);
      sprintf(s, "%d", $1);
      $$ = s;
  }
| CONST_REELLE
  {
      char* s = (char*)malloc(20);
      sprintf(s, "%.2f", $1);
      $$ = s;
  }
| IDENTIFIANT
  {
      $$ = strdup($1);
  }
| PARENTHESE_OUVRANTE expression PARENTHESE_FERMANTE
  {
      $$ = $2;
  }
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
        afficher_quads();
    }
    else
    {
        printf("Erreur d'analyse.\n");
    }
    return 0;
}