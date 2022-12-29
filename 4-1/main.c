#include "sql.tab.h"
#include "lex.yy.h" 

struct symbol_table symtab;
char* curfilename;

int main(int argc, char **argv)
{
    if(argc > 1 && !strcmp(argv[1], "-d")) {
        yydebug = 1; argc--; argv++;
    }

    if(argc > 1 && (yyin = fopen(argv[1],"r"))==NULL)
    {
        perror(argv[1]);
        exit(1);
    }

    init_table(&symtab, 9997);
    curfilename = argv[1];

    yyparse();

    printrefs();

    return 0;

}