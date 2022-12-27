#pragma once
#include "symbol.h"
#include "ast.h"

void dodef(SYMBOL *name, SYMLIST *syms, AST *stmts);
double eval(AST *v);
void treeprint(AST const * const a);