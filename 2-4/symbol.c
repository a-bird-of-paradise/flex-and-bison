#include "symbol.h"
#include <strings.h>
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>

static unsigned symhash(char* sym)
{
    unsigned int hash = 0;
    unsigned c; 

    while((c = tolower(*sym++))) hash = hash*9 + c;

    return hash;
}

struct symbol* lookup(char* sym)
{
    struct symbol* sp = &symtab[symhash(sym) % NHASH];

    int scount = NHASH; 

    while(--scount >= 0) {
        if(sp->name && !strcasecmp(sp->name, sym)) return sp;

        if(!sp->name) {
            sp->name = strdup(sym);
            sp->reflist = 0;
            return sp;
        }

        if(++sp >= symtab+NHASH) sp = symtab;
    }

    fputs("Symbol table overflow!\n", stderr);
    abort();
}

void addref(int lineno, char* filename, char* word, int flags)
{
    struct ref *r;
    struct symbol* sp = lookup(word);

    if(sp->reflist &&
        sp->reflist->lineno == lineno &&
        sp->reflist->filename == filename) return;

    r = malloc(sizeof(struct ref)); 

    if(!r) { fputs("Out of memory!\n", stderr); abort();    }

    r->next = sp->reflist;
    r->filename = filename;
    r->lineno = lineno;
    r->flags = flags;
    sp->reflist = r;

}

static int symcompare(const void* xa, const void* xb)
{
    const struct symbol* a = xa;
    const struct symbol* b = xb;

    if(!a->name){
        if(!b->name) return 0;
        return 1;
    }

    if(!b->name) return -1;

    return strcasecmp(a->name, b->name);
}

void freerefs(void)
{
    // pick up anything malloc() or strdup() and free() it
    struct symbol* sp;
    struct ref* rp, *rpn;

    for(sp = symtab; sp < symtab + NHASH; sp++){
        rp = sp->reflist;
        while(rp) {
            rpn = rp->next;
            free(rp);
            rp = rpn;
        }
        if(sp->name) free(sp->name);
    }
}

void printrefs(void)
{
    struct symbol* sp;

    qsort(symtab, NHASH, sizeof(struct symbol), symcompare);

    for(sp = symtab; sp->name && sp < symtab + NHASH; sp++){
        char* prevfn = NULL;

        struct ref* rp = sp->reflist;
        struct ref* rpp = 0;
        struct ref* rpn; 

        do
        {
            rpn = rp->next;
            rp->next = rpp;
            rpp = rp;
            rp = rpn;
        } while (rp);

        sp->reflist = rpp; // bug in book: references except the last become inaccessible
        
        printf("%10s", sp->name);

        for(rp = rpp; rp; rp = rp->next){
            if(rp->filename == prevfn) printf(" %d", rp->lineno);
            else {
                printf(" %s:%d", rp->filename, rp->lineno);
                prevfn = rp->filename;
            }
        }
        printf("\n");
    }
}