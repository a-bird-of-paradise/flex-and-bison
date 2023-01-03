#include "symbol.h"
#include <strings.h>
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include "purecalc.tab.h"

SYMBOL symtab[N_HASH];

static unsigned symhash(char* sym)
{
    unsigned int hash = 0;
    unsigned c; 

    while((c = *sym++)) hash = hash*9 + c;

    return hash;
}

SYMBOL* lookup(PCDATA *pcdata, char* sym)
{
    SYMBOL *sp = &(pcdata->symtab)[symhash(sym) % N_HASH];
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

        if(++sp >= pcdata->symtab + N_HASH) sp = pcdata->symtab;
    }

    yyerror(pcdata, "Symbol table overflow\n");
    abort();
}

SYMLIST *newsymlist(PCDATA *pcdata, SYMBOL *sym, SYMLIST *next)
{
    SYMLIST *sl = malloc(sizeof(SYMLIST));
    if(!sl) { yyerror(pcdata, "Out of memory"); exit(0);   }

    sl->sym=sym;
    sl->next=next;
    return sl;
}

void symlistfree(PCDATA *pcdata, SYMLIST *sl)
{
    SYMLIST *nsl;

    while(sl) {
        nsl = sl->next;
        free(sl);
        sl = nsl;
    }
}
void symtabfree(PCDATA *pcdata)
{
    for(int i = 0; i < N_HASH; i++){
       if(pcdata->symtab[i].name){
            symlistfree(pcdata,pcdata->symtab[i].syms);
            treefree(pcdata,pcdata->symtab[i].func);
            free(pcdata->symtab[i].name);
       }
    }
    free(pcdata->symtab);
}