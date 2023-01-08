# Flex, Bison, and `C++`

Well. I got the calculator working in `C++` using the latest features in both flex and bison. It was a bit of a journey but I got there. 

## Node stuff

My nodes are now `std::unique_ptr<AST_Node>`, where `AST_Node` is an abstract base class. Which is great as I can just `std::move()` payloads around. The class has an `eval()` member that is called. I don't have to worry about memory management nearly as much as C++'s scoping rules will delete things at appropriate moments. 

I tried to keep it as a header only node definition but some things needed to be an a formal cpp file (e.g. anything that throws). 

I do like the object way of doing things. e.g. I could quickly add a `x % y` feature by adding a token, a scanning rule, a token rule, and a class. I could condense binary operations like I have done comparisons so I wouldn't need to touch the grammar - this is the case with builtins, where you add a scanning rule, an element of an enum and a row in a switch statement to put a new one in. 

There are some instances where you can tell a syntax error only during node construction. For example, when creating a call to a user function two problems are 

1. Symbol might not be defined as a function
2. Function call doesn't contain at least enough arguments (extra args are just ignored, I haven't implemented variadic args)

So now the constructor throws a syntax error which bison captures. The language grammar means Bison won't attempt to create wrong objects in other circumstances. 

I'd like to add a `print()` member function which would pretty print an AST. But I will do that later (i.e. never). 

## Bison delicacies

You really want to use what Bison calls "complete symbols". This means instead of `yylex()` returning an int with a global variable (or context object) used to store the semantic value and location, you get `yylex()` to return an object with these things included (i.e., token kind, token value, and location). 

They're easy enough to generate. Just `%define api.value.type variant` and `%define api.token.constructor`. This means bison now generates a bunch of functions like `make_NUMBER()` you can call from Flex actions that return a complete symbol. 

I also used `%define api.token.raw` for a modest speed improvement (you cannot use character literals as tokens, but it does make parsing a bit quicker). I don't think I'd use this again unless performance was critical.

Finally I enabled `%define api.value.automove`. This means that any `$1`, `$3` etc in bison actions are actually `std::move($1)` etc. Combined with how I wrote the node code this makes things efficient as no copies are needed. 

Overall it's not too different to the reentrant C implementation, but there are a lot of `%define`s and a reasonably delicate amount of `%code`s :
````bison

%define api.token.prefix {TOK_}
%define api.parser.class {Parser}
%define api.namespace {cppcalc}
%parse-param { Scanner *scanner } { Context *ctx }
%lex-param { Context *ctx }
%code requires 
{
namespace cppcalc {class Scanner; class Context; } 
#include "astnode.hpp"
#include "Symbol-Table.hpp"
} 
%code provides {
void define_userfunc(cppcalc::Context *ctx, Symbol *sym, std::vector<Symbol *>&& symlist, std::unique_ptr<AST::AST_Node>&& func);
}
%code
{
#include "Scanner.hpp"
#define yylex scanner->lex
}
````
Potentially some redundancy in there, but it works, so I don't dare try and reduce it any further. Bison rules are very similar to the C implementation though, and being able to use objects as (non)terminal values is great.
````bison

%token <double> NUMBER
%token <Symbol*> NAME
%token <AST::Builtin_Function> FUNC

%token IF THEN ELSE WHILE DO LET LBRACE RBRACE LPAREN RPAREN SEMICOLON COMMA

%nonassoc <AST::Nodetype> CMP
%right EQU
%left ADD SUB
%left MUL DIV
%nonassoc ABS UMINUS
%nonassoc THEN
%nonassoc ELSE

%type <std::unique_ptr<AST::AST_Node>> exp stmt explist compound_stmt stmt_list exp_stmt while_stmt if_stmt
%type <std::vector<Symbol*>> symlist

%start calc

%%

stmt: compound_stmt | exp_stmt | while_stmt | if_stmt;

if_stmt: IF exp THEN stmt           { $$ = std::make_unique<AST::If_Node>($2,$4,nullptr);   } 
    |   IF exp THEN stmt ELSE stmt  { $$ = std::make_unique<AST::If_Node>($2,$4,$6);        }
    ;
/* continues */
````

## Flex things

The scanning object itself is reasonably sensitive to include files and orders. I ended up creating a `Scanner-Internal.hpp` file that is consumed by the scanner itself and the `Scanner.hpp` file other things eat. This is because the system `FlexLexer.h` include file is `#define` sensitive in a complicated way. The `Scanner.hpp` file is
````C++
#pragma once
#define yyFlexLexer cppcalcFlexLexer
#include <FlexLexer.h>
#undef yyFlexLexer
#include "Scanner-Internal.hpp"
````
which allows multiple user lexers to produced by repeating lines 2-4 as needed.  

Interface involved definition of `YY_DECL` to return a Bison complete symbol and accept a context object that stores the location and symbol table. Also custom user action code to advance the location in the context. Figuring out exactly what was needed was a bit of a pain but I got there. In the preamble I used 
````flex
#undef  YY_DECL
#define YY_DECL cppcalc::Parser::symbol_type cppcalc::Scanner::lex(cppcalc::Context *context)
#define YY_USER_ACTION context->loc.step(); context->loc.columns(yyleng);
````
and also included the bison generated `Parser.hpp` and my `Scanner-Internal.hpp`:
````C++
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
````
Note how the `Scanner` object interacts with the `Scanner.hpp` header defines. Actions in the Flex file look like
````flex
%%
"+"     {   return cppcalc::Parser::make_ADD(context->loc);       }
````
Anything which matches a `\n` also has `context->loc.lines()` in it to bump the line counter. I think I need to return a preincremented copy of the location object in the complete symbol but I don't want to touch it any more. 

Overall not too bad but figuring out what to put in which include file in which order is delicate. 

## Context

This is really a struct but I call it a class. Basically holds a symbol table and location. Also used by the scanner to report an end of file to the `main()` loop. Finally the parser returns the constructed AST for evaluation by `main()`. 

````C++
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
````

## Symbol table

Much easier as I can use an STL container to store key-value pairs of symbol names and `Symbol` objects. The latter are very similar to the C `struct Symbol` but make use of vectors of names etc instead of linked lists.

````C++
class Symbol_Table
{
public:
    Symbol *lookup(const std::string& Name) {
        auto it = table.find(Name);
        if(it == table.end()) it = table.emplace(std::make_pair(Name,Symbol(Name))).first;
        return &(it->second);
    }
protected:
    std::unordered_map<std::string,Symbol> table;
};
````

## Main

Putting it all together lets us have the following simple `main()`:
````C++
#include "Scanner.hpp"
#include "Parser.hpp"

int main(int argc, char **argv)
{

    cppcalc::Context ctx;
    cppcalc::Scanner scanner(std::cin,std::cerr);
    cppcalc::Parser parser(&scanner,&ctx);

    while(!ctx.done)
    {
        std::cout << "> ";
        parser.parse();
        if(ctx.node.get()) std::cout << " = " << ctx.node->eval() << std::endl;
    }

    return 0;

}
````
I'd like to remove use of pointers (use references or smart pointers) and generally cleanup the code a little, but the above works. I built it with memory and address instrumentation and there are no leaks even if I try and generate awkward syntax errors. 