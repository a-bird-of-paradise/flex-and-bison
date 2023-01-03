%language "C++"
%defines
%locations

%define api.parser.class {cppcalc}
%require "3.8.2"
%code top {
#include <iostream>
#include "cppcalc-ctx.hpp"
}

%parse-param { cppcalc_ctx &ctx }
%lex-param { cppcalc_ctx &ctx }

%union { int ival; }

%token <ival> NUMBER
%token ADD SUB MUL DIV ABS
%token OP CP
%token EOL

%type <ival> exp factor term

%{
extern int yylex(yy::cppcalc::semantic_type *yylval,
                 yy::cppcalc::location_type *yylloc,
                 cppcalc_ctx &ctx);

void myout(int val, int radix);

%}

%initial-action {
    @$.begin.filename = @$.end.filename = ctx.get_filename();
}

%%

calclist:   %empty
    |   calclist exp EOL    {   std::cout << "="; myout(ctx.get_radix(), $2); std::cout << "\n> ";    }
    |   calclist EOL        {   std::cout << " >";  };

exp:    factor
    |   exp ADD factor      {   $$ = $1 + $3;   }
    |   exp SUB factor      {   $$ = $1 - $3;   };

factor: term
    |   factor MUL term     {   $$ = $1 * $3;   }
    |   factor DIV term     {   if(!$3) {   error(@3, "divide by zero");    YYABORT;    }
                                $$ = $1 / $3;   };

term:   NUMBER
    |   ABS term            {   $$ = $2 >= 0 ? $2 : -$2;    }
    |   OP  exp CP          {   $$ = $2;                    };

%%

int main(int argc, char **argv)
{
    cppcalc_ctx ctx(8);
    std::cout << "> ";
    yy::cppcalc parser(ctx);
    int v = parser.parse();

    return v;
}

void myout(int radix, int val)
{
    if(val<0) {
        std::cout << "-";
        val *= -1;
    }

    if(val > radix) {
        myout(radix,val/radix);
        val %= radix;
    }

    std::cout << val;
}

int myatoi(int radix, char *x)
{
    int v = 0;
    while(*x) v = v*radix + *x++ - '0';
    return v;
}

namespace yy {
    void cppcalc::error(location const &loc, const std::string& s) {
        std::cerr << "Error at " << loc << ": " << s << std::endl;
    }
}