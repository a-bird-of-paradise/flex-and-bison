#include "lex.yy.h"
#include "symbol.h"

struct symbol_table symtab;

char* curfilename;

int main(int argc, char** argv)
{
    int i;

    init_table(&symtab,9997);

    if(argc < 2) {
        curfilename = "(stdin)";
        yylineno = 1;
        yylex();
    } else {
        for(i = 1; i < argc; i++) {
            FILE* f = fopen(argv[i], "r");

            if(!f) {
                perror(argv[i]);
                return 1;
            }

            curfilename = argv[i];

            yyrestart(f);
            yylineno = 1;
            yylex();
            fclose(f);
        }
    }
    printrefs();
    // clean up
    freerefs();

    return 0;
}