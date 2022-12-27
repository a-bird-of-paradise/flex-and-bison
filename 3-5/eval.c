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
        case B_print:   treeprint(fn->l); return v; // will be printed
        case B_debug:   if(v!=0) yydebug=1; else yydebug=0; return v;
        case B_quit:    exit(v);
        case B_abs:     return fabs(v);
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

void treeprint_inner(AST const * const a, const int l)
{
    int i = l;
    while(i-->0) printf("|");

    switch(a->nodetype) {

        case N_NUMBER:  
            printf("[%p] NUMBER %f\n", a, ((NUMVAL *)a)->number); 
            break;

        case N_SYMREF:  
            printf("[%p] SYMREF %s\n",a,((SYMREF *)a)->s->name); 
            if(((SYMREF *)a)->s->func) treeprint_inner(((SYMREF *)a)->s->func,l+1);
            break;

        case N_ASSIGNMENT:  
            printf("[%p] ASSIGNMENT %s\n",a,((SYMASGN *)a)->s->name);
            treeprint_inner(((SYMASGN *)a)->v, l+1);
            break;

        case N_PLUS:    
            printf("[%p] OPERATOR +\n",a);
            treeprint_inner(a->l,l+1);
            treeprint_inner(a->r,l+1);
            break;
        case N_MINUS:     
            printf("[%p] OPERATOR -\n",a);
            treeprint_inner(a->l,l+1);
            treeprint_inner(a->r,l+1);
            break;
        case N_MUL:      
            printf("[%p] OPERATOR *\n",a);
            treeprint_inner(a->l,l+1);
            treeprint_inner(a->r,l+1);
            break;
        case N_DIV:       
            printf("[%p] OPERATOR /\n",a);
            treeprint_inner(a->l,l+1);
            treeprint_inner(a->r,l+1);
            break;
        case N_ABS:       
            printf("[%p] UNARY OPERATOR |\n",a);
            treeprint_inner(a->l,l+1);
            break;
        case N_UMINUS:    
            printf("[%p] UNARY OPERATOR -\n",a);
            treeprint_inner(a->l,l+1);
            break;

        case N_GT:         
            printf("[%p] OPERATOR >\n",a);
            treeprint_inner(a->l,l+1);
            treeprint_inner(a->r,l+1);
            break;
        case N_LT:         
            printf("[%p] OPERATOR <\n",a);
            treeprint_inner(a->l,l+1);
            treeprint_inner(a->r,l+1);
            break;
        case N_NEQ:        
            printf("[%p] OPERATOR <>\n",a);
            treeprint_inner(a->l,l+1);
            treeprint_inner(a->r,l+1);
            break;
        case N_EQ:         
            printf("[%p] OPERATOR ==\n",a);
            treeprint_inner(a->l,l+1);
            treeprint_inner(a->r,l+1);
            break;
        case N_GEQ:        
            printf("[%p] OPERATOR >=\n",a);
            treeprint_inner(a->l,l+1);
            treeprint_inner(a->r,l+1);
            break;
        case N_LEQ:        
            printf("[%p] OPERATOR <=\n",a);
            treeprint_inner(a->l,l+1);
            treeprint_inner(a->r,l+1);
            break;

        case N_IF:  
            printf("[%p] IF\n",a);
            if(((FLOW *)a)->cond) treeprint_inner(((FLOW *)a)->cond,l+1);
            if(((FLOW *)a)->tl) treeprint_inner(((FLOW *)a)->tl,l+1);
            if(((FLOW *)a)->el) treeprint_inner(((FLOW *)a)->el,l+1);
            break;

        case N_WHILE:
            printf("[%p] WHILE\n",a);
            if(((FLOW *)a)->cond) treeprint_inner(((FLOW *)a)->cond,l+1);
            if(((FLOW *)a)->tl) treeprint_inner(((FLOW *)a)->tl,l+1);
            break;

        case N_LIST:
            printf("[%p] LIST\n", a);
            if(a->l) treeprint_inner(a->l,l+1);
            if(a->r) treeprint_inner(a->r,l+1); 
            break;

        case N_BUILTIN_FUNCCALL: 
            printf("[%p] BUILT IN FUNCTION %d\n",a, ((FNCALL *)a)->func);
            treeprint_inner( ((FNCALL *)a)->l, l+1);
            break;

        case N_USER_FUNCCALL:
            printf("[%p] USER FUNCTION %s\n",a,((UFNCALL *)a)->s->name);
            treeprint_inner(((UFNCALL *)a)->l,l+1);
            break;

        default:
            printf("Unprintable node\n");

    }
}

void treeprint(AST const * const a)
{
    treeprint_inner(a, 1);
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
        if( ((FLOW *)a)->tl) 
            while( eval( ((FLOW *)a)->cond) != 0) 
                v = eval( ((FLOW *)a)->tl);
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