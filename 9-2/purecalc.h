#pragma once
#include <stdbool.h>

#ifndef FLEX_SCANNER
typedef void *yyscan_t;
#endif

typedef struct pcdata {
    yyscan_t scaninfo;
    struct symbol *symtab;
    struct ast *ast;
    bool done;
} PCDATA;

