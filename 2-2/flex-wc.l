%option noyywrap read batch never-interactive header-file="lex.yy.h" 8bit fast align
%{
extern int chars, words, lines;
extern int totchars, totwords, totlines;
%}

WORD    [[:^space:]]+
WS      ([[:space:]]{-}[\n])+

%%

{WORD}                                      {   words += 1; chars += strlen(yytext);    }
{WORD}{WS}                                  {   words += 1; chars += strlen(yytext);    }
{WORD}{WS}{WORD}                            {   words += 2; chars += strlen(yytext);    }
{WORD}{WS}{WORD}{WS}{WORD}                  {   words += 3; chars += strlen(yytext);    }
{WORD}{WS}{WORD}{WS}{WORD}{WS}{WORD}        {   words += 4; chars += strlen(yytext);    }
{WORD}{WS}{WORD}{WS}{WORD}{WS}{WORD}{WS}{WORD}        {   
                                                words += 5; chars += strlen(yytext);    }
{WORD}{WS}{WORD}{WS}{WORD}{WS}{WORD}{WS}{WORD}{WS}{WORD}       {   
                                                words += 6; chars += strlen(yytext);    }
\n                                          {   chars++;    lines++;                    }
.                                           {   chars++;                                }
