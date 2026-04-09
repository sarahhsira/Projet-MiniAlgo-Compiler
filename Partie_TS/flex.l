%{
#include <stdio.h>
#include <string.h>
#include "bison.tab.h"

extern YYSTYPE yylval;

int nb_ligne=1;
int col=1;
char* token_courant=NULL;
%}

%%

"PROGRAM" { col+=strlen(yytext); token_courant=strdup(yytext); return PROGRAM; }
"DECL" { col+=strlen(yytext); token_courant=strdup(yytext); return DECL; }
"ENDDECL" { col+=strlen(yytext); token_courant=strdup(yytext); return ENDDECL; }

"BEGIN" { col+=strlen(yytext); token_courant=strdup(yytext); return TBEGIN; }
"END" { col+=strlen(yytext); token_courant=strdup(yytext); return TEND; }

"CONST" { col+=strlen(yytext); token_courant=strdup(yytext); return CONST; }
"INTEGER" { col+=strlen(yytext); token_courant=strdup(yytext); return ENTIER; }
"FLOAT" { col+=strlen(yytext); token_courant=strdup(yytext); return REEL; }

"IF" { col+=strlen(yytext); token_courant=strdup(yytext); return IF; }
"ELSE" { col+=strlen(yytext); token_courant=strdup(yytext); return ELSE; }
"FOR" { col+=strlen(yytext); token_courant=strdup(yytext); return FOR; }
"WHILE" { col+=strlen(yytext); token_courant=strdup(yytext); return WHILE; }

"WRITE" { col+=strlen(yytext); token_courant=strdup(yytext); return WRITE; }
"READ" { col+=strlen(yytext); token_courant=strdup(yytext); return READ; }

"+" { col+=strlen(yytext); token_courant=strdup(yytext); return PLUS; }
"-" { col+=strlen(yytext); token_courant=strdup(yytext); return MOINS; }
"*" { col+=strlen(yytext); token_courant=strdup(yytext); return FOIS; }
"/" { col+=strlen(yytext); token_courant=strdup(yytext); return DIVISE; }

"&&" { col+=strlen(yytext); token_courant=strdup(yytext); return ET; }
"||" { col+=strlen(yytext); token_courant=strdup(yytext); return OU; }
"!" { col+=strlen(yytext); token_courant=strdup(yytext); return NON; }

">=" { col+=strlen(yytext); token_courant=strdup(yytext); return SUP_EGAL; }
"<=" { col+=strlen(yytext); token_courant=strdup(yytext); return INF_EGAL; }
"==" { col+=strlen(yytext); token_courant=strdup(yytext); return EGAL_EGAL; }
"!=" { col+=strlen(yytext); token_courant=strdup(yytext); return DIFF; }
">" { col+=strlen(yytext); token_courant=strdup(yytext); return PLUS_GRAND; }
"<" { col+=strlen(yytext); token_courant=strdup(yytext); return PLUS_PETIT; }

"=" { col+=strlen(yytext); token_courant=strdup(yytext); return EGAL; }

"," { col+=strlen(yytext); token_courant=strdup(yytext); return VIRGULE; }
";" { col+=strlen(yytext); token_courant=strdup(yytext); return POINT_VIRGULE; }
":" { col+=strlen(yytext); token_courant=strdup(yytext); return DEUX_POINTS; }

"{" { col += strlen(yytext); token_courant = strdup(yytext); return ACCOLADE_OUVRANTE; }
"}" { col += strlen(yytext); token_courant = strdup(yytext); return ACCOLADE_FERMANTE;}
"(" { col+=strlen(yytext); token_courant=strdup(yytext); return PARENTHESE_OUVRANTE; }
")" { col+=strlen(yytext); token_courant=strdup(yytext); return PARENTHESE_FERMANTE; }

"[" { col+=strlen(yytext); token_courant=strdup(yytext); return CROCHET_OUVRANT; }
"]" { col+=strlen(yytext); token_courant=strdup(yytext); return CROCHET_FERMANT; }

\([+-]?[0-9]+\.\) {
printf("Erreur Lexicale : ligne %d colonne %d\nType : reel mal forme\nElement : %s\n", nb_ligne, col, yytext);
col += strlen(yytext);
}

\([+-]?\.[0-9]+\) {
printf("Erreur Lexicale : ligne %d colonne %d\nType : reel mal forme\nElement : %s\n", nb_ligne, col, yytext);
col += strlen(yytext);
}


\([+-]?[0-9]+\) {
    int val = atoi(yytext + 1);

    if(val < -32768 || val > 32767)
        printf("Erreur Lexicale : ligne %d colonne %d\nType : entier hors limites\nElement : %s\n", nb_ligne, col, yytext);
    else {
        yylval.integer = val;
        token_courant = strdup(yytext);
        col += strlen(yytext);
        return CONST_ENTIERE;
    }
}


\([+-]?[0-9]+\.[0-9]+\) {
    float val = atof(yytext + 1);

    if(val < -32768 || val > 32767)
        printf("Erreur Lexicale : ligne %d colonne %d\nType : reel hors limites\nElement : %s\n", nb_ligne, col, yytext);
    else {

    yylval.float_val = val;
    token_courant = strdup(yytext);
    col += strlen(yytext);
     return CONST_REELLE;
    }
}


[-+][0-9]+ {
printf("Erreur Lexicale : ligne %d colonne %d\nType : entier signe sans parentheses\nElement : %s\n", nb_ligne, col, yytext);
col += strlen(yytext);
}

[0-9]+ {
    int val = atoi(yytext);
    if(val < 0 || val > 32767)
        printf("Erreur Lexicale : ligne %d colonne %d\nType : Entier hors limites\nElement : %s\n",nb_ligne,col,yytext);
    else {
        yylval.integer = val;
        token_courant=strdup(yytext);
        col+=strlen(yytext);
        return CONST_ENTIERE;
    }
}
[-+][0-9]+\.[0-9]+ {
printf("Erreur Lexicale : ligne %d colonne %d\nType : reel signe sans parentheses\nElement : %s\n", nb_ligne, col, yytext);
col += strlen(yytext);
}

[0-9]+\.[0-9]+ {
    float val = atof(yytext);
    yylval.float_val = val;
    token_courant=strdup(yytext);
    col+=strlen(yytext);
    return CONST_REELLE;
}

[0-9]+[a-zA-Z_]+[a-zA-Z0-9_]* {
printf("Erreur Lexicale : ligne %d colonne %d\nType : Identificateur invalide\nElement : %s\n",nb_ligne,col,yytext);
col+=strlen(yytext);
}

[a-zA-Z][a-zA-Z0-9_]*-[a-zA-Z0-9_]+ {
printf("Erreur Lexicale : ligne %d colonne %d\nType : Identificateur invalide (caractere interdit '-')\nElement : %s\n", nb_ligne, col, yytext);
col += strlen(yytext);
}

[a-zA-Z][a-zA-Z0-9_]{8,} {
printf("Erreur Lexicale : ligne %d colonne %d\nType : Identificateur trop long\nElement : %s\n",nb_ligne,col,yytext);
col+=strlen(yytext);
}

[a-zA-Z][a-zA-Z0-9_]{0,7} { col+=strlen(yytext); yylval.str=strdup(yytext); token_courant=strdup(yytext); return IDENTIFIANT; }

"//".* { }

"/*"([^*]|\*+[^*/])*\*+"/" { }

"/*"([^*]|\*+[^*/])* {
    printf("Erreur Lexicale : ligne %d colonne %d\nType : Commentaire non ferme\nElement : /*\n", nb_ligne, col);
     return 0;
}

[\n] { nb_ligne++; col=1; }

[ \t]+ { col+=strlen(yytext); }

. { printf("Erreur Lexicale : ligne %d colonne %d\nType : Symbole inconnu\nElement : %s\n",nb_ligne,col,yytext); }

%%

int yywrap()
{
printf("Analyse lexicale terminée avec succès.\n");
return 1;
}