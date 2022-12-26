#include "eval.h"
#include <math.h>
#include <stdlib.h>
#include <stdio.h>
#include "calculator.tab.h"

static double callbultin(FNCALL *fn)
{
    double v = eval(fn->l);

    switch(fn->func) {
        case B_exp:     return exp(v);  
        case B_sqrt:    return sqrt(v); 
        case B_log:     return log(v);  
        case B_print:   printf("= %4.4g\n", v); return v;
        default:    yyerror("Unknown internal function %d\n",fn->func);
                    return 0.0;
    }
}

static double calluser(UFNCALL *f)
{
    SYMBOL *fn = f->s;
    SYMLIST *sl;
    AST *args = f->l;
    double *oldval, *newval;
    double v;
    int nargs;
    int i;

    if(!fn->func) {
        yyerror("Call to undefined function %s\n",fn->name);
        return 0.0;
    }

    sl = fn->syms;
    for(nargs = 0; sl; sl = sl->next) nargs++;

    oldval = (double *)malloc(nargs * sizeof(double));
    newval = (double *)malloc(nargs * sizeof(double));

    if(!oldval || !newval) {
        yyerror("Out of memory in %s\n", fn->name);
        return 0.0;
    }

    for(i = 0; i < nargs; i++) {
        if(!args) {
            yyerror("Too few arguments in call to %s\n",fn->name);
            free(oldval);
            free(newval);
            return 0.0;
        }

        if(args->nodetype == N_LIST) {
            newval[i] = eval(args->l);
            args = args->r;
        } else {
            newval[i] = eval(args);
            args = NULL;
        }
    }

    sl = fn->syms;

    for(i = 0; i < nargs; i++) {
        SYMBOL *s = sl->sym;
        oldval[i] = s->value;
        s->value = newval[i];
        sl = sl->next;
    }

    free(newval);

    v = eval(fn->func);

    sl = fn->syms;

    for(i = 0; i < nargs; i++) {
        SYMBOL *s = sl->sym;
        s->value = oldval[i];
        sl = sl->next;
    }

    free(oldval);

    return v;
    

}

double eval(AST *a)
{
    double v;

    if(!a) { yyerror("Cannot evaluate null node"); return 0.0;    }

    switch(a->nodetype) {

        case N_NUMBER:  v = ((NUMVAL *)a)->number; break;

        case N_SYMREF:  v = ((SYMREF *)a)->s->value; break;

        case N_ASSIGNMENT:  
            v = ((SYMASGN *)a)->s->value = eval(((SYMASGN *)a)->v); break;

        case N_PLUS:    v = eval(a->l) + eval(a->r);    break;
        case N_MINUS:   v = eval(a->l) - eval(a->r);    break;
        case N_MUL:     v = eval(a->l) * eval(a->r);    break;
        case N_DIV:     v = eval(a->l) / eval(a->r);    break;
        case N_ABS:     v = fabs(eval(a->l));           break;
        case N_UMINUS:  v = -eval(a->l);                break;

        case N_GT:  v = (eval(a->l) > eval(a->r))? 1 : 0; break;
        case N_LT:  v = (eval(a->l) < eval(a->r))? 1 : 0; break;
        case N_NEQ: v = (eval(a->l) !=eval(a->r))? 1 : 0; break;
        case N_EQ:  v = (eval(a->l) ==eval(a->r))? 1 : 0; break;
        case N_GEQ: v = (eval(a->l) >=eval(a->r))? 1 : 0; break;
        case N_LEQ: v = (eval(a->l) <=eval(a->r))? 1 : 0; break;

        case N_IF:  
        if( eval( ((FLOW *)a)->cond) != 0) { // evaluate condition
            if( ((FLOW *)a)->tl) {           // if true then ...
                v = eval( ((FLOW *)a)->tl);
            } else {                         // null branch handling
                v = 0.0;
            }
        } else {                             // if not true then...
            if( ((FLOW *)a)->el) {           // else condition
                v = eval( ((FLOW *)a)->el);
            } else {
                v = 0.0;
            }
        }

        case N_WHILE:
        v = 0.0; 
        if( ((FLOW *)a)->tl) {
            while( eval( ((FLOW *)a)->cond) != 0)
                v = eval( ((FLOW *)a)->tl);
        }
        break;

        case N_LIST: eval(a->l); v = eval(a->r); break;

        case N_BUILTIN_FUNCCALL: v = callbultin((FNCALL *)a); break;

        case N_USER_FUNCCALL: v = calluser((UFNCALL *)a); break;

        default: printf("Bad eval() nodetype: %c\n", a->nodetype);
    }

    return v;
}

void dodef(SYMBOL *name, SYMLIST *syms, AST *func)
{
    if(name->syms) symlistfree(name->syms);
    if(name->func) treefree(name->func);

    name->syms = syms;
    name->func = func;
}