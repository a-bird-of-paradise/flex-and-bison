%language "C++"
%require "3.8"
%defines "Parser.hpp"
%output "Parser.cpp"
%define api.token.raw
%define api.token.constructor
%define api.value.type variant
%define api.value.automove
%define parse.assert
%define parse.trace
%define parse.error detailed
%define parse.lac full
%locations
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

compound_stmt:  LBRACE RBRACE       { $$ = nullptr; }
    |   LBRACE stmt_list RBRACE     { $$ = $2;      }
    ;

stmt_list:  stmt                    { $$ = $1;                          }
    |   stmt stmt_list              { $$ = AST::single_or_list($1,$2);  } 
    ;

exp_stmt:   SEMICOLON               { $$ = nullptr; }
    |   exp SEMICOLON               { $$ = $1;      }
    ;

while_stmt: WHILE exp DO stmt       { $$ = std::make_unique<AST::While_Node>($2,$4,nullptr);    }
    ;

exp: exp CMP exp                    { $$ = std::make_unique<AST::CMP_Node>($2,$1,$3);   }
    |   exp ADD exp                 { $$ = std::make_unique<AST::Add_Node>($1,$3);      }
    |   exp SUB exp                 { $$ = std::make_unique<AST::Sub_Node>($1,$3);      }
    |   exp MUL exp                 { $$ = std::make_unique<AST::Mul_Node>($1,$3);      }
    |   exp DIV exp                 { $$ = std::make_unique<AST::Div_Node>($1,$3);      }
    |   ABS exp                     { $$ = std::make_unique<AST::Abs_Node>($2);         }
    |   LPAREN exp RPAREN           { $$ = $2;                                          }
    |   SUB exp %prec UMINUS        { $$ = std::make_unique<AST::Minus_Node>($2);       }
    |   NUMBER                      { $$ = std::make_unique<AST::Number_Node>($1);      }
    |   NAME                        { $$ = std::make_unique<AST::Ref_Node>($1);         }
    |   NAME EQU exp                { $$ = std::make_unique<AST::Assign_Node>($1,$3);   }
    |   FUNC LPAREN explist RPAREN  { $$ = std::make_unique<AST::Builtin_Node>($1,$3);  }
    |   NAME LPAREN explist RPAREN  { $$ = std::make_unique<AST::User_Node>($1,$3,ctx); }
    ;

explist: 
        exp                 {   $$ = $1;                                        }
    |   exp COMMA explist   {   $$ = std::make_unique<AST::List_Node>($1,$3);   }
    ;

symlist:    NAME                { $$.push_back($1);             }
    |       NAME COMMA symlist  { $$ = $3; $$.push_back($1);    }
    ;

calc:   %empty  {   ctx->node = nullptr;    }
    |   stmt    {   ctx->node = $1;         }
    |   LET NAME LPAREN symlist RPAREN EQU stmt {
            define_userfunc(ctx,$2,$4,$7); 
            ctx->node = nullptr;  }
    |   error   {   yyclearin; 
                    yyerrok; 
                    ctx->node = nullptr; }
    |   error SEMICOLON  {  yyclearin; 
                            yyerrok; 
                            ctx->node = nullptr; }
    ;

%%

void define_userfunc(cppcalc::Context *ctx, Symbol *sym, std::vector<Symbol *>&& symlist, std::unique_ptr<AST::AST_Node>&& func)
{
    sym->symlist = std::move(symlist);
    sym->func = std::move(func);

    std::cout << ctx->loc << ": defined " << sym->Name << std::endl;
}

void cppcalc::Parser::error(cppcalc::location const& loc, std::string const& msg)
{
    std::cerr << loc << ": " << msg << std::endl;
}
