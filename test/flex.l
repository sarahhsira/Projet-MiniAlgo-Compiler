%{
#include <stdio.h>
#include <string.h>
#include "bison.tab.h"
#include "ts.h"

extern YYSTYPE yylval;

int nb_ligne=1;
int col=1;
char* token_courant=NULL;
%}

%%

"PROGRAM" { inserer(yytext, "KW", "kw", 0, 0); token_courant=strdup(yytext); return PROGRAM; }
"DECL" { inserer(yytext, "KW", "kw", 0, 0);col+=strlen(yytext); token_courant=strdup(yytext); return DECL; }
"ENDDECL" { inserer(yytext, "KW", "kw", 0, 0);col+=strlen(yytext); token_courant=strdup(yytext); return ENDDECL; }

"BEGIN" { inserer(yytext, "KW", "kw", 0, 0); col+=strlen(yytext); token_courant=strdup(yytext); return TBEGIN; }
"END" { inserer(yytext, "KW", "kw", 0, 0); col+=strlen(yytext); token_courant=strdup(yytext); return TEND; }

"CONST" { inserer(yytext, "CONST", "kw", 0, 0); col+=strlen(yytext); token_courant=strdup(yytext); return CONST; }
"INTEGER" { inserer(yytext, "KW", "kw", 0, 0); col+=strlen(yytext); token_courant=strdup(yytext); return ENTIER; }
"FLOAT" { inserer(yytext, "KW", "kw", 0, 0); col+=strlen(yytext); token_courant=strdup(yytext); return REEL; }

"IF" { inserer(yytext, "KW", "kw", 0, 0); col+=strlen(yytext); token_courant=strdup(yytext); return IF; }
"ELSE" { inserer(yytext, "KW", "kw", 0, 0); col+=strlen(yytext); token_courant=strdup(yytext); return ELSE; }
"FOR" { inserer(yytext, "KW", "kw", 0, 0); col+=strlen(yytext); token_courant=strdup(yytext); return FOR; }
"WHILE" { inserer(yytext, "KW", "kw", 0, 0); col+=strlen(yytext); token_courant=strdup(yytext); return WHILE; }

"WRITE" { inserer(yytext, "KW", "kw", 0, 0); col+=strlen(yytext); token_courant=strdup(yytext); return WRITE; }
"READ" { inserer(yytext, "KW", "kw", 0, 0); col+=strlen(yytext); token_courant=strdup(yytext); return READ; }

"+" { inserer(yytext, "SEP", "sep", 0, 0); token_courant=strdup(yytext); return PLUS; }
"-" { inserer(yytext, "SEP", "sep", 0, 0); col+=strlen(yytext); token_courant=strdup(yytext); return MOINS; }
"*" { inserer(yytext, "SEP", "sep", 0, 0); col+=strlen(yytext); token_courant=strdup(yytext); return FOIS; }
"/" { inserer(yytext, "SEP", "sep", 0, 0); col+=strlen(yytext); token_courant=strdup(yytext); return DIVISE; }

"&&" { inserer(yytext, "SEP", "sep", 0, 0); col+=strlen(yytext); token_courant=strdup(yytext); return ET; }
"||" { inserer(yytext, "SEP", "sep", 0, 0); col+=strlen(yytext); token_courant=strdup(yytext); return OU; }
"!" { inserer(yytext, "SEP", "sep", 0, 0); col+=strlen(yytext); token_courant=strdup(yytext); return NON; }

">=" { inserer(yytext, "SEP", "sep", 0, 0); col+=strlen(yytext); token_courant=strdup(yytext); return SUP_EGAL; }
"<=" { inserer(yytext, "SEP", "sep", 0, 0); col+=strlen(yytext); token_courant=strdup(yytext); return INF_EGAL; }
"==" { inserer(yytext, "SEP", "sep", 0, 0); col+=strlen(yytext); token_courant=strdup(yytext); return EGAL_EGAL; }
"!=" { inserer(yytext, "SEP", "sep", 0, 0); col+=strlen(yytext); token_courant=strdup(yytext); return DIFF; }
">" { inserer(yytext, "SEP", "sep", 0, 0); col+=strlen(yytext); token_courant=strdup(yytext); return PLUS_GRAND; }
"<" { inserer(yytext, "SEP", "sep", 0, 0); col+=strlen(yytext); token_courant=strdup(yytext); return PLUS_PETIT; }

"=" { inserer(yytext, "SEP", "sep", 0, 0); col+=strlen(yytext); token_courant=strdup(yytext); return EGAL; }

"," { inserer(yytext, "SEP", "sep", 0, 0); col+=strlen(yytext); token_courant=strdup(yytext); return VIRGULE; }
";" { inserer(yytext, "SEP", "sep", 0, 0); col+=strlen(yytext); token_courant=strdup(yytext); return POINT_VIRGULE; }
":" { inserer(yytext, "SEP", "sep", 0, 0); col+=strlen(yytext); token_courant=strdup(yytext); return DEUX_POINTS; }

"{" { inserer(yytext, "SEP", "sep", 0, 0); col += strlen(yytext); token_courant = strdup(yytext); return ACCOLADE_OUVRANTE; }
"}" { inserer(yytext, "SEP", "sep", 0, 0); col += strlen(yytext); token_courant = strdup(yytext); return ACCOLADE_FERMANTE;}
"(" { inserer(yytext, "SEP", "sep", 0, 0); col+=strlen(yytext); token_courant=strdup(yytext); return PARENTHESE_OUVRANTE; }
")" { inserer(yytext, "SEP", "sep", 0, 0); col+=strlen(yytext); token_courant=strdup(yytext); return PARENTHESE_FERMANTE; }

"[" { inserer(yytext, "SEP", "sep", 0, 0); col+=strlen(yytext); token_courant=strdup(yytext); return CROCHET_OUVRANT; }
"]" { inserer(yytext, "SEP", "sep", 0, 0); col+=strlen(yytext); token_courant=strdup(yytext); return CROCHET_FERMANT; }

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
        inserer(yytext, "CONST", "constante", val, 0);
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
    inserer(yytext, "CONST", "constante", val, 0);
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
        printf("Erreur Lexicale : ligne %d colonne %d\nType : Entier hors limites\nElement : %s\n",
               nb_ligne, col, yytext);
    else {
        yylval.integer = val;

        /* insert only if not already inserted */
        inserer(yytext, "CONST", "constante", val, 0);

        token_courant = strdup(yytext);
        col += strlen(yytext);

        return CONST_ENTIERE;
    }
}
[-+][0-9]+\.[0-9]+ {
printf("Erreur Lexicale : ligne %d colonne %d\nType : reel signe sans parentheses\nElement : %s\n", nb_ligne, col, yytext);
col += strlen(yytext);
}

[0-9]+\.[0-9]+ {
    float val = atof(yytext);

    if(val < -32768 || val > 32767)
        printf("Erreur Lexicale : ligne %d colonne %d\nType : reel hors limites\nElement : %s\n",
               nb_ligne, col, yytext);
    else {
        yylval.float_val = val;

       inserer(yytext, "CONST", "constante", val, 0);

        token_courant = strdup(yytext);
        col += strlen(yytext);

        return CONST_REELLE;
    }
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

[a-zA-Z][a-zA-Z0-9_]{0,7} { inserer(yytext, "IDF", "variable", 0, 0);col+=strlen(yytext); yylval.str=strdup(yytext); token_courant=strdup(yytext); return IDENTIFIANT; }

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