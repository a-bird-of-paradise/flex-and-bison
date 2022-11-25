%option noyywrap read batch never-interactive header-file="lex.yy.h" 8bit fast align
%{
extern int chars, words, lines;
extern int totchars, totwords, totlines;
%}

WORD    [[:^space:]]+
WS      ([[:space:]]{-}[\n])+

%%

{WS}+                                         {               chars += yyleng;          }
{WORD}{WS}?                                   {   words += 1; chars += yyleng;          }
{WORD}{WS}?\n                                 {   words += 1; chars += yyleng; lines++; }
{WORD}{WS}{WORD}{WS}?\n                       {   words += 2; chars += yyleng; lines++; }
{WORD}({WS}{WORD}){2}{WS}?\n                  {   words += 3; chars += yyleng; lines++; }
{WORD}({WS}{WORD}){3}{WS}?\n                  {   words += 4; chars += yyleng; lines++; }
{WORD}({WS}{WORD}){4}{WS}?\n                  {   words += 5; chars += yyleng; lines++; }
{WORD}({WS}{WORD}){5}{WS}?\n                  {   words += 6; chars += yyleng; lines++; }
{WORD}({WS}{WORD}){6}{WS}?\n                  {   words += 7; chars += yyleng; lines++; }
{WORD}({WS}{WORD}){7}{WS}?\n                  {   words += 8; chars += yyleng; lines++; }
{WORD}({WS}{WORD}){8}{WS}?\n                  {   words += 9; chars += yyleng; lines++; }
{WORD}({WS}{WORD}){9}{WS}?\n                  {   words +=10; chars += yyleng; lines++; }
{WORD}({WS}{WORD}){10}{WS}?\n                 {   words +=11; chars += yyleng; lines++; }
{WORD}({WS}{WORD}){11}{WS}?\n                 {   words +=12; chars += yyleng; lines++; }
{WORD}({WS}{WORD}){12}{WS}?\n                 {   words +=13; chars += yyleng; lines++; }
{WORD}({WS}{WORD}){13}{WS}?\n                 {   words +=14; chars += yyleng; lines++; }
{WORD}({WS}{WORD}){14}{WS}?\n                 {   words +=15; chars += yyleng; lines++; }
{WORD}({WS}{WORD}){15}{WS}?\n                 {   words +=16; chars += yyleng; lines++; }
{WORD}({WS}{WORD}){16}{WS}?\n                 {   words +=17; chars += yyleng; lines++; }
{WORD}({WS}{WORD}){17}{WS}?\n                 {   words +=18; chars += yyleng; lines++; }
{WORD}({WS}{WORD}){18}{WS}?\n                 {   words +=19; chars += yyleng; lines++; }
{WORD}({WS}{WORD}){19}{WS}?\n                 {   words +=20; chars += yyleng; lines++; }
{WORD}({WS}{WORD}){20}{WS}?\n                 {   words +=21; chars += yyleng; lines++; }
{WORD}({WS}{WORD}){21}{WS}?\n                 {   words +=22; chars += yyleng; lines++; }
{WORD}({WS}{WORD}){22}{WS}?\n                 {   words +=23; chars += yyleng; lines++; }
{WORD}({WS}{WORD}){23}{WS}?\n                 {   words +=24; chars += yyleng; lines++; }
{WORD}({WS}{WORD}){24}{WS}?\n                 {   words +=25; chars += yyleng; lines++; }
{WORD}({WS}{WORD}){24}{WS}?                   {   words +=25; chars += yyleng;          }
\n+                                           {   chars += yyleng; lines+= yyleng;      }
.                                             {   chars += yyleng;                      }
