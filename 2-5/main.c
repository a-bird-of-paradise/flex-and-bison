#include "buffuncs.h"
#include "bufstack.h"
#include "symbol.h"

struct symbol_table symtab;

char* curfilename = 0;
struct bufstack *curbs = 0;

int main(int argc, char** argv)
{

    init_table(&symtab, 9997);

    if(argc < 2)    {
        fprintf(stderr, "need filename\n");
        return 1;
    }

    for(int i = 1; i < argc; i++) 
        if(newfile(argv[i]))
            yylex();

    printrefs();

    return 0;
}