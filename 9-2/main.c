#include "purecalc.tab.h"
#include "lex.yy.h"

int main(int argc, char **argv)
{
    PCDATA p = { NULL, NULL, NULL };

    if(yylex_init_extra(&p, &p.scaninfo)){
        perror("Initial allocation failed");
        return 1;
    }

    if(!(p.symtab = calloc(N_HASH, sizeof(SYMBOL)))){
        perror("Could not allocate symbol table");
        return 1;
    }

    for(;;) {
        printf("> ");
        yyparse(&p);
        if(p.ast){
            printf("= %4.4g\n", eval(&p, p.ast));
            treefree(&p, p.ast);
            p.ast = NULL;
        }
    }

    return 0;

}