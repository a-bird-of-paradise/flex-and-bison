%option noyywrap nodefault 8bit reentrant
%{
struct pwc {
    unsigned long long chars;
    unsigned long long words;
    unsigned long long lines;
};
%}
%option extra-type="struct pwc *"

%%
%{
struct pwc *pp = yyextra;
%}

[^ \t\n\r\f\v]+ {   pp->words++; pp->chars += strlen(yytext);   }
\n              {   pp->chars++; pp->lines++;                   }
.               {   pp->chars++;                                }

%%

int main(int argc, char **argv)
{
    struct pwc mypwc = {0, 0, 0};
    yyscan_t scanner;

    if(yylex_init_extra(&mypwc, &scanner)){
        perror("Initial alloc failed");
        return 1;
    }

    if(argc > 1){
        FILE *f;
        if(!(f = fopen(argv[1],"r"))) {
            perror(argv[1]);
            return 1;
        }
        yyset_in(f, scanner);
    } else {
        yyset_in(stdin, scanner);
    }

    yylex(scanner);
    printf("%8llu%8llu%8llu\n", mypwc.lines, mypwc.words, mypwc.chars);

    if(argc>1) fclose(yyget_in(scanner));

    yylex_destroy(scanner);

    return 0;

}