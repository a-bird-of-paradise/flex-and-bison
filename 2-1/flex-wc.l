%option noyywrap
%{
int chars = 0, words = 0, lines = 0;
%}

%%

[a-zA-Z]+   {   words++;    chars += strlen(yytext);    }
\n          {   chars++;    lines++;                    }
.           {   chars++;                                }

%%

int main(int argc, char** argv)
{
    if(argc > 1){
        if(!(yyin = fopen(argv[1], "r"))) {
            perror(argv[1]);
            return 1;
        }
    }

    yylex();

    printf("%8d%8d%8d\n", lines, words, chars);

    return 0;
}