%option noyywrap read batch never-interactive header-file="lex.yy.h" 8bit fast align yylineno
%x IFILE_LOCAL
%{
#include "buffuncs.h"
%}
%%
^"#"[ \t]*include[ \t]*\"    {   BEGIN IFILE_LOCAL;    }
<IFILE_LOCAL>[^ \t\n\"]+             {   
    {   
        int c;
        while((c=input()) && c != '\n');
    }
    if(!newfile(yytext)) yyterminate();
    BEGIN INITIAL;
}
<IFILE_LOCAL>.|\n                     { 
    fprintf(stderr, "%4d bad include line\n", yylineno);
    yyterminate();
}
<<EOF>> {   if(!popfile()) yyterminate();   }
^.  {   fprintf(yyout, "%4d %s", yylineno, yytext);     }
^\n {   fprintf(yyout, "%4d %s", yylineno-1, yytext);   }
\n  {   ECHO;   }
.   {   ECHO;   }
