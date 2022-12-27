#pragma once
#include "symbol.h"

// structs

typedef enum nodetype {
    N_PLUS = '+',
    N_MINUS = '-',
    N_MUL = '*',
    N_DIV = '/',
    N_ABS = '|',
    N_UMINUS = 'M',
    N_LIST = 'L',
    N_IF = 'I',
    N_WHILE = 'W',
    N_SYMREF = 'N',
    N_ASSIGNMENT = '=',
    N_SYMLIST = 'S',
    N_BUILTIN_FUNCCALL = 'F',
    N_USER_FUNCCALL = 'C',
    N_NUMBER = 'K',
    N_GT = 1,
    N_LT = 2,
    N_NEQ = 3,
    N_EQ = 4,
    N_GEQ = 5,
    N_LEQ = 6
} NODETYPE;

typedef enum bifs {
    B_sqrt = 1,
    B_exp,
    B_log,
    B_print,
    B_debug,
    B_quit,
    B_abs,
} BUILTINS;

typedef struct ast {
    NODETYPE nodetype;
    struct ast *l;
    struct ast *r;
} AST;

typedef struct fncall {
    NODETYPE nodetype;
    AST *l;
    BUILTINS func;
} FNCALL;

typedef struct ufncall {
    NODETYPE nodetype;
    AST *l;
    SYMBOL *s;
} UFNCALL;

typedef struct flow {
    NODETYPE nodetype;
    AST *cond; 
    AST *tl; // then or do
    AST *el; // else
} FLOW;

typedef struct numval {
    NODETYPE nodetype;
    double number;
} NUMVAL;

typedef struct symref {
    NODETYPE nodetype;
    SYMBOL *s;
} SYMREF;

typedef struct symasgn {
    NODETYPE nodetype;
    SYMBOL *s;
    AST *v;
} SYMASGN;

// node building

AST *newast(NODETYPE nodetype, AST *l, AST *r);
AST *newcmp(NODETYPE nodetype, AST *l, AST *r);
AST *newfunc(BUILTINS func, AST *l);
AST *newcall(SYMBOL *s, AST *l);
AST *newref(SYMBOL *s);
AST *newasgn(SYMBOL *s, AST *v);
AST *newnum(double d);
AST *newflow(NODETYPE nodetype, AST *cond, AST *tl, AST *tr);

void treefree(AST *t);