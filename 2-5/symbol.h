#pragma once

struct symbol {
    char* name;
    struct ref *reflist;
};

struct ref {
    struct ref *next;
    char *filename;
    int flags;
    int lineno;
};

struct symbol_table {
    unsigned long size;
    struct symbol *table;
};

extern struct symbol_table symtab;

struct symbol* lookup(char*);

void addref(int, char*, char*, int);
void printrefs(void);
void freerefs(void);
void init_table(struct symbol_table *stab, const unsigned long size);

extern char* curfilename;