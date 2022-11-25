#include "lex.yy.h"

int chars = 0   , words = 0   , lines = 0   ;
int totchars = 0, totwords = 0, totlines = 0;

int main(int argc, char** argv)
{

    if(argc < 2) {
        yylex();
        printf("%8d%8d%8d\n", lines, words, chars);
        return 0;
    }

    for(int i = 1; i < argc; i++){
        FILE *f = fopen(argv[i], "r");

        if(!f){
            perror(argv[i]);
            return 1;
        }

        yyrestart(f);

        yylex();

        fclose(f);
        
        printf("%8d%8d%8d %s\n", lines, words, chars, argv[i]);
        
        totchars += chars; chars = 0;
        totwords += words; words = 0;
        totlines += lines; lines = 0;
    }

    if(argc > 2) {
        printf("%8d%8d%8d total\n", totlines, totwords, totchars);
    }
}