%code requires {
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include "ast.h"
#include "eval.h"

extern int yylineno;
int yylex();
}

%code provides { void yyerror(const char *s, ...); }

%define parse.error detailed
%define parse.trace

%union {
    AST *a;
    double d;
    SYMBOL *s;
    SYMLIST *sl;
    int fn;
}

%destructor { treefree($$); } <a>
%destructor { symlistfree($$); } <sl>
%destructor { /* owned by symtab */ } <s>

%token <d> NUMBER
%token <s> NAME
%token <fn> FUNC
%token EOL

%token IF THEN ELSE WHILE DO LET FI DONE

%nonassoc <fn> CMP
%right '='
%left '+' '-'
%left '*' '/'
%nonassoc '|' UMINUS

%type <a> exp stmt explist compound_stmt stmt_list exp_stmt while_stmt if_stmt
%type <sl> symlist

%start calclist

%%

stmt: compound_stmt | exp_stmt | while_stmt | if_stmt;

if_stmt: IF exp THEN stmt FI            { $$ = newflow(N_IF,$2,$4,NULL);    } 
    |   IF exp THEN stmt ELSE stmt FI   { $$ = newflow(N_IF,$2,$4,$6);      };

compound_stmt:  '{' '}'     { $$ = NULL;    }
    |   '{' stmt_list '}'   { $$ = $2;      };

stmt_list:  stmt        {   $$ = $1;    }
    |   stmt stmt_list  { if(!$2) $$=$1; else $$ = newast(N_LIST,$1,$2);};

exp_stmt:   ';'     { $$ = NULL; }
    |   exp ';'     { $$ = $1;   };

while_stmt: WHILE exp DO stmt DONE  { $$ = newflow(N_WHILE,$2,$4,NULL); };

exp: exp CMP exp                    { $$ = newcmp($2,$1,$3);            }
    |   exp '+' exp                 { $$ = newast(N_PLUS,$1,$3);        }
    |   exp '-' exp                 { $$ = newast(N_MINUS,$1,$3);       }
    |   exp '*' exp                 { $$ = newast(N_MUL,$1,$3);         }
    |   exp '/' exp                 { $$ = newast(N_DIV,$1,$3);         }
    |   '|' exp                     { $$ = newast(N_ABS,$2,NULL);       }
    |   '(' exp ')'                 { $$ = $2;                          }
    |   '-' exp %prec UMINUS        { $$ = newast(N_UMINUS,$2,NULL);    }
    |   NUMBER                      { $$ = newnum($1);                  }
    |   NAME                        { $$ = newref($1);                  }
    |   NAME '=' exp                { $$ = newasgn($1,$3);              }
    |   FUNC '(' explist ')'        { $$ = newfunc($1,$3);              }
    |   NAME '(' explist ')'        { $$ = newcall($1,$3);              };

explist: 
        exp             {   $$ = $1;                    }
    |   exp ',' explist {   $$ = newast(N_LIST,$1,$3);  };

symlist:    NAME            { $$ = newsymlist($1,NULL); }
    |   NAME ',' symlist    { $$ = newsymlist($1,$3);   };

calclist:   %empty
    |   calclist stmt EOL   {
            printf("= %4.4g\n>",    eval($2));
            treefree($2);
    }
    |   calclist LET NAME '(' symlist ')' '=' stmt EOL {
            dodef($3,$5,$8); 
            printf("Defined %s\n> ",$3->name);
    }
    |   calclist error EOL  {
            yyerrok; printf("> ");
    };

%%

void yyerror(const char *s, ...)
{
    va_list ap;
    va_start(ap, s);
    fprintf(stderr, "%d: error: ", yylineno);
    vfprintf(stderr,s,ap);
    fprintf(stderr,"\n");
    va_end(ap);
}