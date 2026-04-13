#ifndef TS_H
#define TS_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define TABLE_SIZE 1000

typedef struct {
    char name[20];
    char code[20];
    char type[20];
    float value;
    int is_array;
} Symbol;

extern Symbol idf_table[TABLE_SIZE];
extern Symbol kw_table[TABLE_SIZE];
extern Symbol sep_table[TABLE_SIZE];

int hash(char* str);
int insert(char entity[], char code[], char type[], float value, int is_array, int t);
int search(char entity[], int t);

void insert_type(char entity[], char type[]);
void insert_value(char entity[], float value);

void print_all_tables();

#endif