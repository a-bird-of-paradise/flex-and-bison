%{
#include "calc.tab.h"
%}

%%

"+"     {   return ADD; }
"-"     {   return SUB; }
"*"     {   return MUL; }
"/"     {   return DIV; }
"("     {   return OP; }
")"     {   return CP; }
"|"     {   return ABS; }
[0-9]+  {   yylval = atoi(yytext); return NUMBER;   }
\n      {   return EOL; }
[ \t]   {   }
\/\/.*  /* drop comment */
.       {   printf("Unknown character %s\n", yytext);   }

%%