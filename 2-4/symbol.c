#include "symbol.h"
#include <strings.h>
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>

void init_table(struct symbol_table *stab, const unsigned long size)
{
    stab->size = size;
    stab->table = malloc(size * sizeof(struct symbol));

    for(unsigned long i = 0; i < size; i++)
    {
        stab->table[i].name = NULL;
        stab->table[i].reflist = NULL;
    }
}

static unsigned symhash(char* sym)
{
    unsigned int hash = 0;
    unsigned c; 

    while((c = tolower(*sym++))) hash = hash*9 + c;

    return hash;
}

struct symbol* lookup(char* sym)
{
    long long tab_size = symtab.size;

    struct symbol* sp = &symtab.table[symhash(sym) % tab_size];

    while(--tab_size >= 0) {
        if(sp->name && !strcasecmp(sp->name, sym)) return sp;

        if(!sp->name) {
            sp->name = strdup(sym);
            sp->reflist = NULL;
            return sp;
        }

        if(++sp >= symtab.table+symtab.size) sp = symtab.table;    
    }

    // table is full, so make a new one that is doubled in size and free the old one

    struct symbol *old_table = symtab.table, *old_it, *new_sp;
    unsigned long old_size = symtab.size, new_size;
    unsigned new_hash;

    init_table(&symtab,old_size*2);

    for(old_it = old_table; old_it < old_table + old_size; old_it++)
    {
        if(!old_it->name) continue;

        new_size = 2 * old_size;
        new_hash = symhash(old_it->name) % new_size;
        new_sp = &symtab.table[new_hash];

        while(--new_size)
        {
            if(!new_sp->name)
            {
                new_sp->name = old_it->name;
                new_sp->reflist = old_it->reflist;
                break;
            }
            // go back to the beginning if needed to find a blank
            if(++new_sp >= symtab.table + 2 * old_size) new_sp = symtab.table;
        }
    }

    free(old_table);

    return lookup(sym);
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

    for(sp = symtab.table; sp < symtab.table + symtab.size; sp++){
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

    qsort(symtab.table, symtab.size, sizeof(struct symbol), symcompare);

    for(sp = symtab.table; sp->name && sp < symtab.table+ symtab.size; sp++){
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