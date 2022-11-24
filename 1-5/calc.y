%{
#include <stdio.h>
%}

%token NUMBER
%token ADD SUB MUL DIV
%token EOL
%token OP CP
%token AND OR

%%

calclist:   | calclist bitwise_or EOL { printf(" XXXXX = %d (0%o, 0x%X)\n", $2, $2, $2); } 
            | calclist EOL;

bitwise_or: bitwise_and
    |   bitwise_or OR bitwise_and   {   $$ = $1 | $3;   };

bitwise_and:    exp
    |   bitwise_and AND exp {   $$ = $1 & $3;   };

exp: factor 
    |   exp ADD factor { $$ = $1 + $3; }
    |   exp SUB factor { $$ = $1 - $3; }
    |   exp ADD OR factor { $$ = $1 + ($4 > 0 ? $4 : -$4); }
    |   exp SUB OR factor { $$ = $1 - ($4 > 0 ? $4 : -$4); };

factor: num
    |   factor MUL num { $$ = $1 * $3; }
    |   factor DIV num { $$ = $1 / $3; }
    |   factor MUL OR num { $$ = $1 * ($4 > 0 ? $4 : -$4); }
    |   factor DIV OR num { $$ = $1 / ($4 > 0 ? $4 : -$4); };

num: NUMBER
    |   OP bitwise_or CP { $$ = $2; };
%%

int main(int arg, char** argv)
{
    yydebug = 0;
    yyparse();
}

int yyerror(char* s)
{
    fprintf(stderr, "error: %s\n", s);
}