#include "ts.h"

Symbol idf_table[TABLE_SIZE] = {0};
Symbol kw_table[TABLE_SIZE] = {0};
Symbol sep_table[TABLE_SIZE] = {0};

int hash(char* str) {
    int h = 0;
    while (*str)
        h = (h * 31 + *str++) % TABLE_SIZE;
    return h;
}

int insert(char entity[], char code[], char type[], float value, int is_array, int t) {
    Symbol* table;

    switch (t) {
        case 0: table = idf_table; break;
        case 1: table = kw_table; break;
        case 2: table = sep_table; break;
        default: return -1;
    }

    int index = hash(entity);

    while (table[index].name[0] != '\0') {
        if (strcmp(table[index].name, entity) == 0)
            return -1;
        index = (index + 1) % TABLE_SIZE;
    }

    strcpy(table[index].name, entity);
    strcpy(table[index].code, code);
    strcpy(table[index].type, type);
    table[index].value = value;
    table[index].is_array = is_array;

    return index;
}

int search(char entity[], int t) {
    Symbol* table;

    switch (t) {
        case 0: table = idf_table; break;
        case 1: table = kw_table; break;
        case 2: table = sep_table; break;
        default: return -1;
    }

    int index = hash(entity);

    while (table[index].name[0] != '\0') {
        if (strcmp(table[index].name, entity) == 0)
            return index;
        index = (index + 1) % TABLE_SIZE;
    }

    return -1;
}

void insert_type(char entity[], char type[]) {
    int pos = search(entity, 0);
    if (pos != -1)
        strcpy(idf_table[pos].type, type);
}

void insert_value(char entity[], float value) {
    int pos = search(entity, 0);
    if (pos != -1)
        idf_table[pos].value = value;
}

void print_all_tables() {
    int i;

    printf("\n===== TABLE IDF =====\n");
    for (i = 0; i < TABLE_SIZE; i++) {
        if (idf_table[i].name[0] != '\0') {
            printf("%s | %s | %s | %f | %d\n",
                idf_table[i].name,
                idf_table[i].code,
                idf_table[i].type,
                idf_table[i].value,
                idf_table[i].is_array);
        }
    }

    printf("\n===== TABLE KW =====\n");
    for (i = 0; i < TABLE_SIZE; i++) {
        if (kw_table[i].name[0] != '\0') {
            printf("%s | %s\n", kw_table[i].name, kw_table[i].code);
        }
    }

    printf("\n===== TABLE SEP =====\n");
    for (i = 0; i < TABLE_SIZE; i++) {
        if (sep_table[i].name[0] != '\0') {
            printf("%s | %s\n", sep_table[i].name, sep_table[i].code);
        }
    }
}