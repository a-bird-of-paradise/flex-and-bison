#pragma once
#include "Symbol-Table.hpp"
#include "location.hh"

namespace cppcalc {

    class Context // again more like a struct
    {
    public:
        Context() : done(false) { loc.initialize(); }
        Symbol_Table table;
        bool done;
        std::unique_ptr<AST::AST_Node> node;
        location loc;
    };

}