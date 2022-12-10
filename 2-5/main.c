#include "buffuncs.h"
#include "bufstack.h"
#include "symbol.h"

struct symbol symtab[NHASH];
char* curfilename = 0;
struct bufstack *curbs = 0;

int main(int argc, char** argv)
{
    int i;

    if(argc < 2)    {
        fprintf(stderr, "need filename\n");
        return 1;
    }

    for(i = 1; i < argc; i++) 
        if(newfile(argv[i]))
            yylex();

    printrefs();

    return 0;
}