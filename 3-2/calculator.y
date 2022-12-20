
%{
#include <stdio.h>
#include <stdlib.h>
#include "calc.h"
%}

%union {
    AST_NODE *a;
    double d;
}

%token <d> NUMBER
%token EOL

%type <a> exp 

%destructor {   treefree($$);   } <a>

%left '+' '-'
%left '*' '/'
%nonassoc '|' UMINUS

%%

calclist:   %empty
    |   calclist exp EOL    {   printf("= %4.4g\n", eval($2)); treefree($2); printf("> ");  }
    |   calclist EOL        {   printf("> ");                                               };

exp:    exp '+' exp             {   $$ = newast('+',$1,$3);     }
    |   exp '-' exp             {   $$ = newast('-',$1,$3);     }
    |   exp '*' exp             {   $$ = newast('*',$1,$3);     }
    |   exp '/' exp             {   $$ = newast('/',$1,$3);     }
    |   '|' exp                 {   $$ = newast('|',$2,NULL);   }
    |   '(' exp ')'             {   $$ = $2;                    }
    |   '-' exp %prec UMINUS    {   $$ = newast('M',$2,NULL);   }
    |   NUMBER                  {   $$ = newnum($1);            };