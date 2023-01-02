#pragma once
#include "symbol.h"
#include "ast.h"

void dodef(PCDATA *pcdata, SYMBOL *name, SYMLIST *syms, AST *stmts);
double eval(PCDATA *pcdata, AST *v);
void treeprint(PCDATA *pcdata, AST const * const a);