#ifndef QUAD_H
#define QUAD_H

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

typedef struct qdr {
    char op[100];
    char arg1[100];
    char arg2[100];
    char result[100];
} qdr;

extern qdr quad[1000];
extern int qc;

void quadr(char op[], char arg1[], char arg2[], char result[]);
void update_quad(int index, int pos, char value[]);
void print_quad();
char* nouveau_temp();

#endif