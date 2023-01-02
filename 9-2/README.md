# Thread safe parser and lexer with extra data

Boy getting this working was a pain. The book was written in 2009 and both software products have moved on, so things like the `#define` used in the Bison grammar to pass a thing to the lexer no longer work. 

If you are reading this, then this is how you pass a context struct to the lexer via the parser in a thread safe / reentrant / pure manner. 

## Lexer include files

One thing to watch out for - if you, by chance, `#include` the Flex generated header file in the Flex generated .c file then you get a thousand confusing messages about symbols. Don't do this. You have to prototype a couple of Flex things manually. This sucks. You just have to deal with it. 

## Context object 

In this case, we want to pass (a pointer to) a symbol table to the scanner so it can return a pointer to a symbol table entry to the parser when it sees a symbol. 

### Defining it

This is easy enough. The context object is `typedef`ed as 

````C
typedef struct pcdata {
    yyscan_t scaninfo;
    struct symbol *symtab;
    struct ast *ast;
} PCDATA;
````

This has the Flex context `yyscam_t`, as well as pointers to the symbol table and the current `ast` node. This will be returned by the parser to our code for us to do with as we please. 

`yyscan_t` is one of the Flex things. You can use a horrible mess of include guards to bring in the Flex generated header, or you can just prototype it as 
````C
#ifndef FLEX_SCANNER
typedef void *yyscan_t;
#endif
````
which avoids clobbering flex things. 

### Initialising it 
You have to call a Flex function to initialise the `yyscan_t` element. Nice and easy:

````C
PCDATA p = { NULL, NULL, NULL };

if(yylex_init_extra(&p, &p.scaninfo)){
    perror("Initial allocation failed");
    return 1;
}
````
At the same time you have to initialise the symbol table, just use `calloc()` to zero out a big enough array. 

## Getting Bison to expect the context object

This isn't too bad. You tell Bison you want a pure parser and that it will be passed a pointer to a context object in the call to `yyparse()`:

````bison
%define api.pure
%parse-param { PCDATA *pp }
````

You also need to provide a context-aware error reporter:
````bison
%code provides { void yyerror(PCDATA *pp, const char *s, ...); }
````
The error function itself is easy enough (include in the epilogue, after the final `%%`):
````C
void yyerror(PCDATA *pp, const char *s, ...)
{
    va_list ap;
    va_start(ap, s);
    fprintf(stderr, "%d: error: ", yyget_lineno(pp->scaninfo));
    vfprintf(stderr,s,ap);
    fprintf(stderr,"\n");
    va_end(ap);
}
````
Here is a delicacy. The `yyget_lineno()` function comes from Flex, so you need to include its header in the Bison file, but only after stuff that gets prototyped in the Bison generated header is done, otherwise you end up including the Flex header in the Flex scanner which causes problems. 

So you need to do this as late as you can in the prologue of the Bison grammar. 
````C
%{
#include "lex.yy.h"
%}
````
### Passing the context to Flex
This is a real pain. 

You first need to tell Flex that a) it is to generate a reentrant scanner and b) that it will receive additional data which c) Bison will provide when it calls you.

This boils down to coercing Flex to generate a `yylex()` with a particular signature, and coercing Bison to generate `yylex()` calls with that signature. 

Flex is easier. You basically tell it that Bison will call it and that it should be reentrant. The following Flex options will do the right thing:
````flex
%option noyywrap nodefault yylineno 8bit
%option header-file="lex.yy.h"
%option outfile="lex.yy.c"
%option interactive reentrant bison-bridge
%option extra-type="PCDATA *"
````
This includes `reentrant`, `bison-bridge` (i.e., expect to be called from Bison in a particular way) and `extra-type` which says, well, what the extra type is. 

When you want to use the extra type in a Flex action, you have to cast the `yyextra` thing to `your type` and then use it. For example, 
````flex
%%
[a-zA-Z][a-zA-Z0-9]*    {   yylval->s = lookup((PCDATA *)yyextra, yytext);  return NAME;   }
````
Fine. But how to get Bison to call it like this? Well. You tell Bison to create `yylex()` calls with an extra parameter:
````bison
%lex-param { void * scanner }
````
and then, immediately after including the Flex generated header in your grammar, you have to `#define` what `scanner` is:
````C
%{
#include "lex.yy.h"
#define scanner pp->scaninfo
%}
````
Now this means that bison will call `yylex()` with the right arguments to pass a pointer to a Flex scanner context. This has already been initialised to have extra data of... your context, which includes the scanner context. Urgh. But when `yylex()` processes its context, it can access your context (including the pointer to the symbol table) via `yyextra`. 
## cleanup
After concluding a parse, don't forget to destroy the scanner context. Or don't, if your program immediately exits afterwards, like this one does. 