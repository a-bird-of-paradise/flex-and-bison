#pragma once

typedef struct symbol {
    char* name;
    double value;
    struct ast *func;
    struct symlist *syms;
} SYMBOL;

#define N_HASH 9997
extern SYMBOL symtab[N_HASH];

SYMBOL *lookup(char *s);

typedef struct symlist {
    SYMBOL *sym;
    struct symlist *next;
} SYMLIST;

SYMLIST *newsymlist(SYMBOL *sym, SYMLIST *next);
void symlistfree(SYMLIST *sl);