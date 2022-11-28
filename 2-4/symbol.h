#pragma once

struct symbol {
    char* name;
    struct ref* reflist;
};

struct ref {
    struct ref* next;
    char* filename;
    int flags;
    int lineno;
};

#define NHASH 9997


extern struct symbol symtab[NHASH];

struct symbol* lookup(char*);

void addref(int, char*, char*, int);
void printrefs(void);
void freerefs(void);

extern char* curfilename;