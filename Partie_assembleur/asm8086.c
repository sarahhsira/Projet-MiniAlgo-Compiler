#include "asm8086.h"

#include "ts.h"
#include "quad.h"

/* ============================================================
   Utilitaires
   ============================================================ */

/* Retourne 1 si la chaine est un nombre (entier ou reel) */
static int est_nombre(const char* s)
{
    if (!s || s[0] == '\0') return 0;
    int i = 0;
    if (s[0] == '-' || s[0] == '+') i = 1;
    int a_chiffre = 0, a_point = 0;
    for (; s[i] != '\0'; i++) {
        if (s[i] >= '0' && s[i] <= '9') a_chiffre = 1;
        else if (s[i] == '.' && !a_point)  a_point  = 1;
        else return 0;
    }
    return a_chiffre;
}

/* Charge une valeur (variable, constante litterale, temporaire) dans AX
   Pour les reels on utilise AX comme registre generique (simplification pedagogique) */
static void charger_ax(FILE* f, const char* val)
{
    if (est_nombre(val))
        fprintf(f, "    MOV AX, %s\n", val);
    else
        fprintf(f, "    MOV AX, [%s]\n", val);
}

/* Charge une valeur dans BX */
static void charger_bx(FILE* f, const char* val)
{
    if (est_nombre(val))
        fprintf(f, "    MOV BX, %s\n", val);
    else
        fprintf(f, "    MOV BX, [%s]\n", val);
}

/* ============================================================
   Déclaration des variables dans le segment DATA
   ============================================================ */
static void generer_data(FILE* f)
{
    fprintf(f, ".DATA\n");
    fprintf(f, "    ; --- Variables et constantes ---\n");

    for (int i = 0; i < TAILLE; i++) {
        symbole* s = table[i];
        while (s) {
            if (strcmp(s->nature, "variable") == 0) {
                if (strcmp(s->type, "FLOAT") == 0)
                    fprintf(f, "    %s DW 0         ; FLOAT (simplifie en entier 16 bits)\n", s->nom);
                else
                    fprintf(f, "    %s DW 0\n", s->nom);
            }
            else if (strcmp(s->nature, "constante") == 0 &&
                     strcmp(s->type, "CONST") == 0) {
                /* constante utilisateur : CONST PI = 3.14 */
                fprintf(f, "    %s DW %d\n", s->nom, (int)s->valeur);
            }
            else if (strcmp(s->nature, "tableau") == 0) {
                fprintf(f, "    %s DW %d DUP(0)\n", s->nom, s->taille);
            }
            s = s->suivant;
        }
    }

    fprintf(f, "\n    ; --- Temporaires ---\n");
    /* on declare les temporaires T1..T999 qu'on rencontre dans les quadruplets */
    int deja[1000] = {0};
    for (int i = 0; i < qc; i++) {
        /* result */
        if (quad[i].result[0] == 'T') {
            int n = atoi(quad[i].result + 1);
            if (n > 0 && n < 1000 && !deja[n]) {
                fprintf(f, "    %s DW 0\n", quad[i].result);
                deja[n] = 1;
            }
        }
    }

    /* messages pour READ/WRITE (simplification : on affiche en hexa via DOS) */
    fprintf(f, "\n    msg_nl DB 13, 10, '$'\n");
    fprintf(f, "\n");
}

/* ============================================================
   Génération du code pour chaque quadruplet
   ============================================================ */
static void generer_code(FILE* f)
{
    fprintf(f, ".CODE\n");
    fprintf(f, "MAIN PROC\n");
    fprintf(f, "    MOV AX, @DATA\n");
    fprintf(f, "    MOV DS, AX\n\n");

    for (int i = 0; i < qc; i++) {

        if (strcmp(quad[i].op, "SUPPRIME") == 0)
            continue;   /* quadruplet elimine par l'optimiseur */

        fprintf(f, "    ; --- Q%d : (%s, %s, %s, %s) ---\n",
                i, quad[i].op, quad[i].arg1, quad[i].arg2, quad[i].result);

        /* ---- Etiquette de saut ---- */
        fprintf(f, "L%d:\n", i);

        /* ======================================================
           AFFECTATION  result = arg1
           ====================================================== */
        if (strcmp(quad[i].op, "=") == 0) {
            charger_ax(f, quad[i].arg1);
            /* affectation tableau : result = "TAB[idx]" */
            if (strchr(quad[i].result, '[')) {
                char tab[50], idx[50];
                sscanf(quad[i].result, "%[^[][%[^]]", tab, idx);
                charger_bx(f, idx);
                fprintf(f, "    SHL BX, 1\n");          /* *2 car DW = 2 octets */
                fprintf(f, "    MOV [%s + BX], AX\n", tab);
            } else {
                fprintf(f, "    MOV [%s], AX\n", quad[i].result);
            }
        }

        /* ======================================================
           ADDITION
           ====================================================== */
        else if (strcmp(quad[i].op, "+") == 0) {
            charger_ax(f, quad[i].arg1);
            charger_bx(f, quad[i].arg2);
            fprintf(f, "    ADD AX, BX\n");
            fprintf(f, "    MOV [%s], AX\n", quad[i].result);
        }

        /* ======================================================
           SOUSTRACTION
           ====================================================== */
        else if (strcmp(quad[i].op, "-") == 0) {
            charger_ax(f, quad[i].arg1);
            charger_bx(f, quad[i].arg2);
            fprintf(f, "    SUB AX, BX\n");
            fprintf(f, "    MOV [%s], AX\n", quad[i].result);
        }

        /* ======================================================
           MULTIPLICATION
           ====================================================== */
        else if (strcmp(quad[i].op, "*") == 0) {
            charger_ax(f, quad[i].arg1);
            charger_bx(f, quad[i].arg2);
            fprintf(f, "    IMUL BX\n");                /* AX = AX * BX */
            fprintf(f, "    MOV [%s], AX\n", quad[i].result);
        }

        /* ======================================================
           DIVISION
           ====================================================== */
        else if (strcmp(quad[i].op, "/") == 0) {
            charger_ax(f, quad[i].arg1);
            fprintf(f, "    CWD\n");                    /* etend AX -> DX:AX */
            charger_bx(f, quad[i].arg2);
            fprintf(f, "    IDIV BX\n");               /* AX = quotient */
            fprintf(f, "    MOV [%s], AX\n", quad[i].result);
        }

        /* ======================================================
           NON LOGIQUE  !arg1 -> result
           ====================================================== */
        else if (strcmp(quad[i].op, "!") == 0) {
            charger_ax(f, quad[i].arg1);
            fprintf(f, "    CMP AX, 0\n");
            fprintf(f, "    JNE _not_false_%d\n", i);
            fprintf(f, "    MOV AX, 1\n");
            fprintf(f, "    JMP _not_end_%d\n", i);
            fprintf(f, "_not_false_%d:\n", i);
            fprintf(f, "    MOV AX, 0\n");
            fprintf(f, "_not_end_%d:\n", i);
            fprintf(f, "    MOV [%s], AX\n", quad[i].result);
        }

        /* ======================================================
           ET LOGIQUE  &&
           ====================================================== */
        else if (strcmp(quad[i].op, "&&") == 0) {
            charger_ax(f, quad[i].arg1);
            charger_bx(f, quad[i].arg2);
            fprintf(f, "    AND AX, BX\n");
            fprintf(f, "    MOV [%s], AX\n", quad[i].result);
        }

        /* ======================================================
           OU LOGIQUE  ||
           ====================================================== */
        else if (strcmp(quad[i].op, "||") == 0) {
            charger_ax(f, quad[i].arg1);
            charger_bx(f, quad[i].arg2);
            fprintf(f, "    OR AX, BX\n");
            fprintf(f, "    MOV [%s], AX\n", quad[i].result);
        }

        /* ======================================================
           COMPARAISONS  -> result vaut 0 ou 1
           ====================================================== */
        else if (strcmp(quad[i].op, ">")  == 0 ||
                 strcmp(quad[i].op, "<")  == 0 ||
                 strcmp(quad[i].op, ">=") == 0 ||
                 strcmp(quad[i].op, "<=") == 0 ||
                 strcmp(quad[i].op, "==") == 0 ||
                 strcmp(quad[i].op, "!=") == 0)
        {
            charger_ax(f, quad[i].arg1);
            charger_bx(f, quad[i].arg2);
            fprintf(f, "    CMP AX, BX\n");

            const char* jmp_vrai;
            if      (strcmp(quad[i].op, ">")  == 0) jmp_vrai = "JG";
            else if (strcmp(quad[i].op, "<")  == 0) jmp_vrai = "JL";
            else if (strcmp(quad[i].op, ">=") == 0) jmp_vrai = "JGE";
            else if (strcmp(quad[i].op, "<=") == 0) jmp_vrai = "JLE";
            else if (strcmp(quad[i].op, "==") == 0) jmp_vrai = "JE";
            else                                      jmp_vrai = "JNE";

            fprintf(f, "    %s _cmp_true_%d\n", jmp_vrai, i);
            fprintf(f, "    MOV AX, 0\n");
            fprintf(f, "    JMP _cmp_end_%d\n", i);
            fprintf(f, "_cmp_true_%d:\n", i);
            fprintf(f, "    MOV AX, 1\n");
            fprintf(f, "_cmp_end_%d:\n", i);
            fprintf(f, "    MOV [%s], AX\n", quad[i].result);
        }

        /* ======================================================
           SAUT CONDITIONNEL  BZ  (Branch if Zero)
           BZ  label  cond  ""
           arg1 = destination, arg2 = variable condition
           ====================================================== */
        else if (strcmp(quad[i].op, "BZ") == 0) {
            charger_ax(f, quad[i].arg2);
            fprintf(f, "    CMP AX, 0\n");
            fprintf(f, "    JE  L%s\n", quad[i].arg1);
        }

        /* ======================================================
           SAUT INCONDITIONNEL  BR  (Branch)
           BR  label  ""  ""
           ====================================================== */
        else if (strcmp(quad[i].op, "BR") == 0) {
            fprintf(f, "    JMP L%s\n", quad[i].arg1);
        }

        /* ======================================================
           READ  (lecture depuis stdin - interruption DOS 01h)
           ====================================================== */
        else if (strcmp(quad[i].op, "READ") == 0) {
            fprintf(f, "    ; READ %s\n", quad[i].arg1);
            fprintf(f, "    MOV AH, 01h\n");
            fprintf(f, "    INT 21h\n");
            fprintf(f, "    SUB AL, '0'\n");
            fprintf(f, "    CBW\n");
            fprintf(f, "    MOV [%s], AX\n", quad[i].arg1);
        }

        /* ======================================================
           WRITE  (affichage vers stdout - interruption DOS 02h)
           On affiche les chiffres un par un (valeur 0-9 pour simplifier)
           ====================================================== */
        else if (strcmp(quad[i].op, "WRITE") == 0) {
            fprintf(f, "    ; WRITE %s\n", quad[i].arg1);
            fprintf(f, "    MOV AX, [%s]\n", quad[i].arg1);
            fprintf(f, "    ADD AL, '0'\n");
            fprintf(f, "    MOV DL, AL\n");
            fprintf(f, "    MOV AH, 02h\n");
            fprintf(f, "    INT 21h\n");
            /* saut de ligne */
            fprintf(f, "    LEA DX, msg_nl\n");
            fprintf(f, "    MOV AH, 09h\n");
            fprintf(f, "    INT 21h\n");
        }

        fprintf(f, "\n");
    }

    /* ---- Fin du programme ---- */
    fprintf(f, "    ; --- FIN DU PROGRAMME ---\n");
    fprintf(f, "L%d:\n", qc);
    fprintf(f, "    MOV AH, 4Ch\n");
    fprintf(f, "    INT 21h\n");
    fprintf(f, "MAIN ENDP\n");
    fprintf(f, "END MAIN\n");
}

/* ============================================================
   Point d'entrée public
   ============================================================ */
void generer_asm(const char* nom_fichier)
{
    FILE* f = fopen(nom_fichier, "w");
    if (!f) {
        printf("Erreur : impossible de creer le fichier %s\n", nom_fichier);
        return;
    }

    fprintf(f, "; ============================================================\n");
    fprintf(f, ";  Code assembleur 8086 genere par le compilateur MiniAlgo\n");
    fprintf(f, "; ============================================================\n\n");
    fprintf(f, ".MODEL SMALL\n");
    fprintf(f, ".STACK 100h\n\n");

    generer_data(f);
    generer_code(f);

    fclose(f);
    printf("\nCode assembleur 8086 genere dans : %s\n", nom_fichier);
}