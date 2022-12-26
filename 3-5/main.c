#include <stdio.h>
#include "calculator.tab.h"

int main(int argc, char **argv)
{
    printf("> ");
    return yyparse();
}