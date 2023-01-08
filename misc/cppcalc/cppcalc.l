%{
#include "Scanner-Internal.hpp"
#include "Parser.hpp"
#include "astnode.hpp"
#include <string>
#undef  YY_DECL
#define YY_DECL cppcalc::Parser::symbol_type cppcalc::Scanner::lex(cppcalc::Context *context)
#define YY_USER_ACTION context->loc.step(); context->loc.columns(yyleng);
%}
%option c++ noyywrap nodefault noyylineno 8bit align
%option outfile="Scanner.cpp"
%option interactive
%option yyclass="cppcalc::Scanner" 
%option prefix="cppcalc"

EXP [Ee][-+]?[0-9]+

%%
"+"     {   return cppcalc::Parser::make_ADD(context->loc);       }
"-"     {   return cppcalc::Parser::make_SUB(context->loc);       }
"*"     {   return cppcalc::Parser::make_MUL(context->loc);       }
"/"     {   return cppcalc::Parser::make_DIV(context->loc);       }
"="     {   return cppcalc::Parser::make_EQU(context->loc);       }
"|"     {   return cppcalc::Parser::make_ABS(context->loc);       }
","     {   return cppcalc::Parser::make_COMMA(context->loc);     }
";"     {   return cppcalc::Parser::make_SEMICOLON(context->loc); }
"("     {   return cppcalc::Parser::make_LPAREN(context->loc);    }
")"     {   return cppcalc::Parser::make_RPAREN(context->loc);    }
"{"     {   return cppcalc::Parser::make_LBRACE(context->loc);    }
"}"     {   return cppcalc::Parser::make_RBRACE(context->loc);    }

">"     {   return cppcalc::Parser::make_CMP(AST::Nodetype::N_GT,context->loc);   }
"<"     {   return cppcalc::Parser::make_CMP(AST::Nodetype::N_LT,context->loc);   }
"<>"    {   return cppcalc::Parser::make_CMP(AST::Nodetype::N_NEQ,context->loc);  }
"=="    {   return cppcalc::Parser::make_CMP(AST::Nodetype::N_EQ,context->loc);   }
">="    {   return cppcalc::Parser::make_CMP(AST::Nodetype::N_GEQ,context->loc);  }
"<="    {   return cppcalc::Parser::make_CMP(AST::Nodetype::N_LEQ,context->loc);  }

if      {   return cppcalc::Parser::make_IF(context->loc);    }
then    {   return cppcalc::Parser::make_THEN(context->loc);  }
else    {   return cppcalc::Parser::make_ELSE(context->loc);  }
while   {   return cppcalc::Parser::make_WHILE(context->loc); }
do      {   return cppcalc::Parser::make_DO(context->loc);    }
let     {   return cppcalc::Parser::make_LET(context->loc);   }

sqrt    {   return cppcalc::Parser::make_FUNC(AST::Builtin_Function::B_SQRT,context->loc);   }
exp     {   return cppcalc::Parser::make_FUNC(AST::Builtin_Function::B_EXP,context->loc);    }
log     {   return cppcalc::Parser::make_FUNC(AST::Builtin_Function::B_LOG,context->loc);    }
print   {   return cppcalc::Parser::make_FUNC(AST::Builtin_Function::B_PRINT,context->loc);  }
debug   {   return cppcalc::Parser::make_FUNC(AST::Builtin_Function::B_DEBUG,context->loc);  }
quit    {   return cppcalc::Parser::make_FUNC(AST::Builtin_Function::B_QUIT,context->loc);   }
abs     {   return cppcalc::Parser::make_FUNC(AST::Builtin_Function::B_ABS,context->loc);    }

[a-zA-Z][a-zA-Z0-9]*    {   return cppcalc::Parser::make_NAME(context->table.lookup(yytext), context->loc);  }

[0-9]+"."[0-9]*{EXP}?   |
"."?[0-9]+{EXP}?        {   return cppcalc::Parser::make_NUMBER(atof(yytext),context->loc);   }

"//".*
[ \t]+

\\\n    {   std::cout << "c> "; context->loc.lines();                                   }
\n      {   context->loc.lines();   return cppcalc::Parser::make_YYEOF(context->loc);   }

.       {   }

<<EOF>> {   context->done = true; return cppcalc::Parser::make_YYEOF(context->loc);     }
