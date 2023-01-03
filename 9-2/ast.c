#include "ast.h"
#include <stdlib.h>
#include "purecalc.tab.h"
#include <stdio.h>

AST *newast(PCDATA *pcdata, NODETYPE nodetype, AST *l, AST *r)
{
    AST *a = malloc(sizeof(AST));
    if(!a) { yyerror(pcdata, "Out of memory"); exit(0);   }

    a->nodetype = nodetype;
    a->l = l;
    a->r = r;
    return a;
}

AST *newnum(PCDATA *pcdata, double d)
{
    NUMVAL *a = malloc(sizeof(NUMVAL));
    if(!a) { yyerror(pcdata, "Out of memory"); exit(0);   }

    a->nodetype = N_NUMBER;
    a->number = d;

    return (AST *)a;
}

AST *newcmp(PCDATA *pcdata, NODETYPE nodetype, AST *l, AST *r)
{
    AST *a = malloc(sizeof(AST));
    if(!a) { yyerror(pcdata, "Out of memory"); exit(0);   }

    a->nodetype = nodetype;
    a->l = l;
    a->r = r;
    return a;
}

AST *newfunc(PCDATA *pcdata, BUILTINS func, AST *l)
{
    FNCALL *a = malloc(sizeof(FNCALL));
    if(!a) { yyerror(pcdata, "Out of memory"); exit(0);   }

    a->nodetype = N_BUILTIN_FUNCCALL;
    a->func = func;
    a->l = l;

    return (AST *)a;
}

AST *newcall(PCDATA *pcdata, SYMBOL *s, AST *l)
{
    UFNCALL *a = malloc(sizeof(UFNCALL));
    if(!a) { yyerror(pcdata, "Out of memory"); exit(0);   }

    a->nodetype = N_USER_FUNCCALL;
    a->l = l;
    a->s = s;
    return (AST *)a;

}

AST *newref(PCDATA *pcdata, SYMBOL *s)
{
    SYMREF *a = malloc(sizeof(SYMREF));
    if(!a) { yyerror(pcdata, "Out of memory"); exit(0);   }

    a->nodetype = N_SYMREF;
    a->s = s;
    
    return (AST *)a;
}

AST *newasgn(PCDATA *pcdata, SYMBOL *s, AST *v)
{
    SYMASGN *a = malloc(sizeof(SYMASGN));
    if(!a) { yyerror(pcdata, "Out of memory"); exit(0);   }

    a->nodetype = N_ASSIGNMENT;
    a->s = s;
    a->v = v;

    return (AST *)a;
}

AST *newflow(PCDATA *pcdata, NODETYPE nodetype, AST* cond, AST *tl, AST *el)
{
    FLOW *a = malloc(sizeof(FLOW));
    if(!a) { yyerror(pcdata, "Out of memory"); exit(0);   }

    a->nodetype = nodetype;
    a->cond = cond;
    a->tl = tl;
    a->el = el;

    return (AST *)a;
}

void treefree(PCDATA *pcdata, AST *a)
{
    if(!a) return;
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
            treefree(pcdata, a->r);

        case '|':
        case 'M':
        case 'C':
        case 'F':
            treefree(pcdata, a->l);

        case 'K':
        case 'N':
            break;

        case '=':
            treefree(pcdata, ((SYMASGN *)a)->v);
            break;

        case 'I':
        case 'W':
            treefree(pcdata, ((FLOW *)a)->cond);
            if(((FLOW *)a)->tl) treefree(pcdata, ((FLOW *)a)->tl);
            if(((FLOW *)a)->el) treefree(pcdata, ((FLOW *)a)->el);
            break;
        
        default:
            printf("Unknown node type %c\n", a->nodetype);
    }
    free(a);
}
