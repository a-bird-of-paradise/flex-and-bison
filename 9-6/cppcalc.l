%option noyywrap
%option outfile="lex.yy.cc"
%option header-file="lex.yy.hh"
%{
#include <cstdlib>
#include "cppcalc-ctx.hpp"
#include "cppcalc-parser.tab.hh"

#define YY_DECL int yylex(yy::cppcalc::semantic_type *yylval,   \
                 yy::cppcalc::location_type *yylloc,            \
                 cppcalc_ctx &ctx)

#define YY_USER_ACTION yylloc->columns(yyleng);
extern int myatoi(int radix, char *s);
%}

%%
%{
    yylloc->step();
%}

"+"     {   return yy::cppcalc::token::ADD; }
"-"     {   return yy::cppcalc::token::SUB; }
"*"     {   return yy::cppcalc::token::MUL; }
"/"     {   return yy::cppcalc::token::DIV; }
"|"     {   return yy::cppcalc::token::ABS; }
"("     {   return yy::cppcalc::token::OP;  }
")"     {   return yy::cppcalc::token::CP;  }
[0-9]+  {   yylval->ival = myatoi(ctx.get_radix(),yytext); return yy::cppcalc::token::NUMBER;   }
\n      {   yylloc->lines(1);   return yy::cppcalc::token::EOL; }

"//".*  {   }
[ \t]   {   yylloc->step(); }
.       {   std::cout << "Mystery character" << *yytext << std::endl;   }
