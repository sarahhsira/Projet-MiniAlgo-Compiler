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

"PROGRAM" { insert("PROGRAM","KW","",0,0,1); return PROGRAM; }
"DECL" { insert("DECL","KW","",0,0,1); return DECL; }
"ENDDECL" { insert("ENDDECL","KW","",0,0,1); return ENDDECL; }

"BEGIN" { insert("BEGIN","KW","",0,0,1); return TBEGIN; }
"END" { insert("END","KW","",0,0,1); return TEND; }

"INTEGER" { insert("INTEGER","KW","",0,0,1); return ENTIER; }
"FLOAT" { insert("FLOAT","KW","",0,0,1); return REEL; }

"+" { insert("+","SEP","",0,0,2); return PLUS; }
"-" { insert("-","SEP","",0,0,2); return MOINS; }

[0-9]+ {
    yylval.integer = atoi(yytext);
    return CONST_ENTIERE;
}

[0-9]+\.[0-9]+ {
    yylval.float_val = atof(yytext);
    return CONST_REELLE;
}

[a-zA-Z][a-zA-Z0-9_]* {
    insert(yytext,"IDF","",0,0,0);
    yylval.str = strdup(yytext);
    return IDENTIFIANT;
}

[ \t]+ ;
\n { nb_ligne++; }

. {
    printf("Erreur Lexicale ligne %d\n", nb_ligne);
}

%%

int yywrap() { return 1; }