#pragma once
#include "purecalc.h"

typedef struct symbol {
    char* name;
    double value;
    struct ast *func;
    struct symlist *syms;
} SYMBOL;

#define N_HASH 9997
extern SYMBOL symtab[N_HASH];

SYMBOL *lookup(PCDATA *pcdata, char *s);

typedef struct symlist {
    SYMBOL *sym;
    struct symlist *next;
} SYMLIST;

SYMLIST *newsymlist(PCDATA *pcdata, SYMBOL *sym, SYMLIST *next);
void symlistfree(PCDATA *pcdata, SYMLIST *sl);
void symtabfree(PCDATA *pcdata);