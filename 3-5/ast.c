#include "ast.h"
#include <stdlib.h>
#include "calculator.tab.h"
#include <stdio.h>

AST *newast(NODETYPE nodetype, AST *l, AST *r)
{
    AST *a = malloc(sizeof(AST));
    if(!a) { yyerror("Out of memory"); exit(0);   }

    a->nodetype = nodetype;
    a->l = l;
    a->r = r;
    return a;
}

AST *newnum(double d)
{
    NUMVAL *a = malloc(sizeof(NUMVAL));
    if(!a) { yyerror("Out of memory"); exit(0);   }

    a->nodetype = N_NUMBER;
    a->number = d;

    return (AST *)a;
}

AST *newcmp(NODETYPE nodetype, AST *l, AST *r)
{
    return newast(nodetype,l,r);
}

AST *newfunc(BUILTINS func, AST *l)
{
    FNCALL *a = malloc(sizeof(FNCALL));
    if(!a) { yyerror("Out of memory"); exit(0);   }

    a->nodetype = N_BUILTIN_FUNCCALL;
    a->func = func;
    a->l = l;

    return (AST *)a;
}

AST *newcall(SYMBOL *s, AST *l)
{
    UFNCALL *a = malloc(sizeof(UFNCALL));
    if(!a) { yyerror("Out of memory"); exit(0);   }

    a->nodetype = N_USER_FUNCCALL;
    a->l = l;
    a->s = s;
    return (AST *)a;

}

AST *newref(SYMBOL *s)
{
    SYMREF *a = malloc(sizeof(SYMREF));
    if(!a) { yyerror("Out of memory"); exit(0);   }

    a->nodetype = N_SYMREF;
    a->s = s;
    
    return (AST *)a;
}

AST *newasgn(SYMBOL *s, AST *v)
{
    SYMASGN *a = malloc(sizeof(SYMASGN));
    if(!a) { yyerror("Out of memory"); exit(0);   }

    a->nodetype = N_ASSIGNMENT;
    a->s = s;
    a->v = v;

    return (AST *)a;
}

AST *newflow(NODETYPE nodetype, AST* cond, AST *tl, AST *el)
{
    FLOW *a = malloc(sizeof(FLOW));
    if(!a) { yyerror("Out of memory"); exit(0);   }

    a->nodetype = nodetype;
    a->cond = cond;
    a->tl = tl;
    a->el = el;

    return (AST *)a;
}

void treefree(AST *a)
{
    switch(a->nodetype){
        case '+':
        case '-':
        case '/':
        case '*':
        case 'L':
        case 1:
        case 2:
        case 3:
        case 4:
        case 5:
        case 6:
            treefree(a->r);

        case '|':
        case 'M':
        case 'C':
        case 'F':
            treefree(a->l);

        case 'K':
        case 'N':
            break;

        case '=':
            free( ((SYMASGN *)a)->v);
            break;

        case 'I':
        case 'W':
            free( ((FLOW *)a)->cond);
            if(((FLOW *)a)->tl) treefree(((FLOW *)a)->tl);
            if(((FLOW *)a)->el) treefree(((FLOW *)a)->el);
            break;
        
        default:
            printf("Unknown node type %c\n", a->nodetype);
    }
    free(a);
}

SYMLIST *newsymlist(SYMBOL *sym, SYMLIST *next)
{
    SYMLIST *sl = malloc(sizeof(SYMLIST));
    if(!sl) { yyerror("Out of memory"); exit(0);   }

    sl->sym=sym;
    sl->next=next;

    return sl;
}

void symlistfree(SYMLIST *sl)
{
    SYMLIST *nsl;

    while(sl) {
        nsl = sl->next;
        free(sl);
        sl = nsl;
    }
}