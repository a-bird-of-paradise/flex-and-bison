%{
int chars = 0, words = 0, lines = 0;
%}

%%

[^ \t\n\r\f\v]+ {   words++; chars += strlen(yytext);   }
\n              {   chars++; lines++;                   }
.               {   chars++;                            }

%%

int main(int argc, char** argv)
{
    yylex();
    printf("%8d%8d%8d\n",   lines,  words,  chars);
}
