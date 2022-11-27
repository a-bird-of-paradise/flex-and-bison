#include "bufstack.h"
#include "buffuncs.h"

struct bufstack *curbs = 0;
char* curfilename;

int main(int argc, char** argv)
{
    if(argc < 2) {
        fprintf(stderr, "need filenane\n");
        return 1;
    }

    if(newfile(argv[1])) yylex();
}
