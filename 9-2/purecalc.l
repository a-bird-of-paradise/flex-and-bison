%option noyywrap nodefault yylineno 8bit
%option header-file="lex.yy.h"
%option outfile="lex.yy.c"
%option interactive reentrant bison-bridge
%option extra-type="PCDATA *"

%{
#include "purecalc.tab.h"
%}

EXP [Ee][-+]?[0-9]+

%%
"+" |
"-" |
"*" |
"/" |
"=" |
"|" |
"," |
";" |
"(" |
")" |
"{" |
"}" {   return  *yytext;                }

">"     {   yylval->fn=1; return CMP;   }
"<"     {   yylval->fn=2; return CMP;   }
"<>"    {   yylval->fn=3; return CMP;   }
"=="    {   yylval->fn=4; return CMP;   }
">="    {   yylval->fn=5; return CMP;   }
"<="    {   yylval->fn=6; return CMP;   }

if      {   return IF;      }
then    {   return THEN;    }
else    {   return ELSE;    }
while   {   return WHILE;   }
do      {   return DO;      }
let     {   return LET;     }

sqrt    {   yylval->fn = B_sqrt; return FUNC;   }
exp     {   yylval->fn = B_exp;  return FUNC;   }
log     {   yylval->fn = B_log;  return FUNC;   }
print   {   yylval->fn = B_print;return FUNC;   }
debug   {   yylval->fn = B_debug;return FUNC;   }
quit    {   yylval->fn = B_quit; return FUNC;   }
abs     {   yylval->fn = B_abs;  return FUNC;   }

[a-zA-Z][a-zA-Z0-9]*    {   yylval->s = lookup((PCDATA *)yyextra, yytext);  return NAME;   }

[0-9]+"."[0-9]*{EXP}?   |
"."?[0-9]+{EXP}?        {   yylval->d = atof(yytext);    return NUMBER; }

"//".*
[ \t]+

\\\n    {   printf("c> ");  }
\n      {   return EOL;     }

.   {   yyerror(yyextra, "Unrecognised character %c", *yytext);  }

<<EOF>> {   exit(0);    }
