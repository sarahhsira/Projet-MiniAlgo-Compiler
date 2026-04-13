%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ts.h"

extern int nb_ligne;
extern char* token_courant;

void yyerror(const char *s);
int yylex();
%}

%union{
int integer;
float float_val;
char* str;
}

%token PROGRAM DECL ENDDECL TBEGIN TEND
%token ENTIER REEL
%token PLUS MOINS
%token <integer> CONST_ENTIERE
%token <float_val> CONST_REELLE
%token <str> IDENTIFIANT

%start programme

%%

programme:
PROGRAM IDENTIFIANT DECL declarations ENDDECL TBEGIN instructions TEND
;

declarations:
declarations declaration
|
;

declaration:
ENTIER ':' liste_identifiants ';'
{
    insert_type($3, "INTEGER");
}
| REEL ':' liste_identifiants ';'
{
    insert_type($3, "FLOAT");
}
;

liste_identifiants:
IDENTIFIANT
| IDENTIFIANT ',' liste_identifiants
;

instructions:
instructions instruction
|
;

instruction:
IDENTIFIANT '=' expression ';'
;

expression:
expression PLUS expression
| expression MOINS expression
| CONST_ENTIERE
| CONST_REELLE
| IDENTIFIANT
;

%%

void yyerror(const char *s)
{
    printf("Erreur syntaxique ligne %d\n", nb_ligne);
}

int main()
{
    if(yyparse()==0)
    {
        printf("Analyse OK\n");
        print_all_tables();   // 🔥 IMPORTANT
    }
    return 0;
}