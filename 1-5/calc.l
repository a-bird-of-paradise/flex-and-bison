%{
#include "calc.tab.h"
%}

%%

"+"     {   return ADD; }
"-"     {   return SUB; }
"*"     {   return MUL; }
"/"     {   return DIV; }
"("     {   return OP;  }
")"     {   return CP;  }
"|"     {   return OR;  }
"&"     {   return AND; }
[1-9][0-9]*                 {   yylval = atoi(yytext); return NUMBER;   }
(0[0-7]+)|(0x[a-fA-F0-9]+)  {   yylval = (int)strtol(yytext, NULL, 0); return NUMBER;   }
\n      {   return EOL; }
[ \t]   {   }
"//".*\n { return EOL;  }
.       {   printf("Unknown character %s\n", yytext);   }

%%