%define parse.error detailed
%define parse.trace
%define api.pure
%parse-param { PCDATA *pp }
%lex-param { void * scanner }

%code requires {
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include "ast.h"
#include "eval.h"
#include "purecalc.h"
}

%code provides { void yyerror(PCDATA *pp, const char *s, ...); }

%union {
    AST *a;
    double d;
    SYMBOL *s;
    SYMLIST *sl;
    int fn;
}

%destructor { treefree(pp, $$); } <a>
%destructor { symlistfree(pp, $$); } <sl>
%destructor { /* owned by symtab */ } <s>

%{
#include "lex.yy.h"
#define scanner pp->scaninfo
%}

%token <d> NUMBER
%token <s> NAME
%token <fn> FUNC
%token EOL

%token IF THEN ELSE WHILE DO LET

%nonassoc <fn> CMP
%right '='
%left '+' '-'
%left '*' '/'
%nonassoc '|' UMINUS

%nonassoc THEN
%nonassoc ELSE

%type <a> exp stmt explist compound_stmt stmt_list exp_stmt while_stmt if_stmt
%type <sl> symlist

%start calc

%%

stmt: compound_stmt | exp_stmt | while_stmt | if_stmt;

if_stmt: IF exp THEN stmt            { $$ = newflow(pp, N_IF,$2,$4,NULL);    } 
    |   IF exp THEN stmt ELSE stmt   { $$ = newflow(pp, N_IF,$2,$4,$6);      };

compound_stmt:  '{' '}'     { $$ = NULL;    }
    |   '{' stmt_list '}'   { $$ = $2;      };

stmt_list:  stmt        {   $$ = $1;    }
    |   stmt stmt_list  { if(!$2) $$=$1; else $$ = newast(pp, N_LIST,$1,$2);};

exp_stmt:   ';'                     { $$ = NULL;                        }
    |   exp ';'                     { $$ = $1;                          };

while_stmt: WHILE exp DO stmt       { $$ = newflow(pp, N_WHILE,$2,$4,NULL); };

exp: exp CMP exp                    { $$ = newcmp(pp, $2,$1,$3);            }
    |   exp '+' exp                 { $$ = newast(pp, N_PLUS,$1,$3);        }
    |   exp '-' exp                 { $$ = newast(pp, N_MINUS,$1,$3);       }
    |   exp '*' exp                 { $$ = newast(pp, N_MUL,$1,$3);         }
    |   exp '/' exp                 { $$ = newast(pp, N_DIV,$1,$3);         }
    |   '|' exp                     { $$ = newast(pp, N_ABS,$2,NULL);       }
    |   '(' exp ')'                 { $$ = $2;                              }
    |   '-' exp %prec UMINUS        { $$ = newast(pp, N_UMINUS,$2,NULL);    }
    |   NUMBER                      { $$ = newnum(pp, $1);                  }
    |   NAME                        { $$ = newref(pp, $1);                  }
    |   NAME '=' exp                { $$ = newasgn(pp, $1,$3);              }
    |   FUNC '(' explist ')'        { $$ = newfunc(pp, $1,$3);              }
    |   NAME '(' explist ')'        { $$ = newcall(pp, $1,$3);              };

explist: 
        exp                         {   $$ = $1;                            }
    |   exp ',' explist             {   $$ = newast(pp, N_LIST,$1,$3);      };

symlist:    NAME                    { $$ = newsymlist(pp, $1,NULL);         }
    |   NAME ',' symlist            { $$ = newsymlist(pp, $1,$3);           };

calc:   %empty          {   pp->ast = NULL; YYACCEPT;   }
    |   stmt EOL   { pp->ast = $1; YYACCEPT; }
    |   LET NAME '(' symlist ')' '=' stmt EOL {
            dodef(pp, $2,$4,$7); 
            printf("%d: Defined %s\n", yyget_lineno(pp->scaninfo), $2->name);
            pp->ast = NULL;
            YYACCEPT;
    }
    |   error EOL  {
            yyclearin; yyerrok; YYACCEPT;
    };

%%

void yyerror(PCDATA *pp, const char *s, ...)
{
    va_list ap;
    va_start(ap, s);
    fprintf(stderr, "%d: error: ", yyget_lineno(pp->scaninfo));
    vfprintf(stderr,s,ap);
    fprintf(stderr,"\n");
    va_end(ap);
}