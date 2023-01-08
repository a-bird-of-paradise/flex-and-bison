#pragma once
#include "Context.hpp"
#include "Parser.hpp"

namespace cppcalc {

    class Scanner : public cppcalcFlexLexer {
    public:
        Scanner(std::istream& arg_yyin, std::ostream& arg_yyout)
            : cppcalcFlexLexer(arg_yyin, arg_yyout) {}
        Scanner(std::istream* arg_yyin = nullptr, std::ostream* arg_yyout = nullptr)
            : cppcalcFlexLexer(arg_yyin, arg_yyout) {}
        Parser::symbol_type lex(Context *context); 
    };
}