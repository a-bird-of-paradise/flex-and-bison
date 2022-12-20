#include "calc.h"
#include <stdlib.h>
#include <stdio.h>
#include <stdarg.h>
#include "calculator.tab.h"

AST_NODE *newast(int nodetype, AST_NODE *left, AST_NODE *right)
{
    AST_NODE *a = malloc(sizeof(AST_NODE));

    if(!a){
        yyerror("Memory exhausted");
        exit(0);
    }

    a->nodetype = nodetype;
    a->l = left;
    a->r = right;
    return a;
}

AST_NODE *newnum(double d)
{
    NUMVAL *a = malloc(sizeof(NUMVAL));

    if(!a){
        yyerror("Memory exhausted");
        exit(0);
    }

    a->nodetype = 'K'; // for Konstant
    a->number = d;

    return (AST_NODE *)a;
}

double eval(AST_NODE *a)
{
    double v;
    switch(a->nodetype) {
        case 'K':   v = ((NUMVAL *)a)->number;  break;

        case '+':   v = eval(a->l) + eval(a->r);    break;
        case '-':   v = eval(a->l) - eval(a->r);    break;
        case '*':   v = eval(a->l) * eval(a->r);    break;
        case '/':   v = eval(a->l) / eval(a->r);    break;
        case '|':   v = eval(a->l); if(v<0) v=-v;   break;
        case 'M':   v = -eval(a->l);                break;
        default:    printf("Unknown node type %c\n",a->nodetype);   
    }
    return v;
}

void treefree(AST_NODE *a)
{
    switch(a->nodetype){
        case '+':
        case '-':
        case '*':
        case '/':   treefree(a->r);

        case '|':
        case 'M':   treefree(a->l);

        case 'K':   free(a);
        break;

        default:    printf("Unknown node type %c\n",a->nodetype);   
    }
}

void yyerror(char *s, ...)
{
    va_list ap;
    va_start(ap,s);

    fprintf(stderr, "%d: error: ",yylineno);
    vfprintf(stderr,s,ap);
    fprintf(stderr,"\n");
}

int main(int argc, char **argv)
{
    printf("> ");
    return yyparse();
}