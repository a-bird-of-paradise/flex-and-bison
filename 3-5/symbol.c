#include "symbol.h"
#include <strings.h>
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include "calculator.tab.h"

SYMBOL symtab[N_HASH];

static unsigned symhash(char* sym)
{
    unsigned int hash = 0;
    unsigned c; 

    while((c = *sym++)) hash = hash*9 + c;

    return hash;
}

SYMBOL* lookup(char* sym)
{
    SYMBOL *sp = &symtab[symhash(sym) % N_HASH];
    int scount = N_HASH;

    while(--scount >= 0)
    {
        if(sp->name &&!strcmp(sp->name,sym)) return sp;

        if(!sp->name){
            sp->name = strdup(sym);
            sp->value = 0;
            sp->func = NULL;
            sp->syms = NULL;
            return sp;
        }

        if(++sp >= symtab + N_HASH) sp = symtab;
    }

    yyerror("Symbol table overflow\n");
    abort();
}
