%option noyywrap read never-interactive header-file="lex.yy.h" 
%option 8bit fast align yylineno caseless batch

%{
#include "symbol.h"
%}

%%
a |
an |
are |
as |
at |
be |
but |
for |
in |
is |
it |
of |
on |
or |
that |
the |
this |
to  {   }

[a-z]+(\'(s|t))?    {   addref(yylineno, curfilename, yytext, 0);   }
.|\n    {   }
%%