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



typedef struct {
    int* data;
    int top;
    int capacity;
} PileControle;

void init_pile(PileControle* p);
void push_pile(PileControle* p, int val);
int pop_pile(PileControle* p);
int top_pile(PileControle* p);
int is_empty_pile(PileControle* p);


extern PileControle pile_if;
extern PileControle pile_while;

#endif