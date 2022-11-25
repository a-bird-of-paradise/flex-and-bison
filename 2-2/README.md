The naïve wordcounter shown in the book systematically counts the following:

* One word at a time 
* One newline at a time
* One arbitrary character at a time

I improved it a little. First ones were to use the FLex speed options so it went a lot faster. 
Building it with full optimisations helped as well.

Main change though was to the structure of the lexer. There are two things you want the lexer to do
for performance:

* Match as many characters as possible per action (as jumping to an action is expensive)
* Avoid backtracking (don't know what that is yet)

In matching plain English text, you basically want to match sentence lines efficiently. 
This is a line (i.e. ends in `\n`) with whitepsace separated words in it. Punctuation counts as
part of the word it is attached to. 

Ultimately I settled on the following approach. Define character classes like
````flex
WORD    [[:^space:]]+
WS      ([[:space:]]{-}[\n])+
````
so that a `WORD` is 'any string of non white space characters', and `WS` is 'almost whitespace' i.e. 
newline characters are excluded. Then you can have a lot of rules like 
````flex
{WS}+                                         {               chars += yyleng;          }
{WORD}{WS}?                                   {   words += 1; chars += yyleng;          }
{WORD}{WS}?\n                                 {   words += 1; chars += yyleng; lines++; }
{WORD}{WS}{WORD}{WS}?\n                       {   words += 2; chars += yyleng; lines++; }
{WORD}({WS}{WORD}){2}{WS}?\n                  {   words += 3; chars += yyleng; lines++; }
{WORD}({WS}{WORD}){3}{WS}?\n                  {   words += 4; chars += yyleng; lines++; }
````
which specifically grab whitespace as the first one, and then move down sentence lines of incremental
lengths. I did this all the way to 25 words in a row, then stopped. I had a final rule that breaks
lines of more than 25 words into chunks of no
more than 25 words, and then handled solitary 
newlines specially. Finally a catchall non word
non newline rule to increment characters.
````flex
{WORD}({WS}{WORD}){24}{WS}?\n                 {   words +=25; chars += yyleng; lines++; }
{WORD}({WS}{WORD}){24}{WS}?                   {   words +=25; chars += yyleng;          }
\n+                                           {   chars += yyleng; lines+= yyleng;      }
.                                             {   chars += yyleng;                      }

````

This does go very fast. I downloaded some large text files from Project Gutenburg and did a race. 
Who would win? GNU `wc` or my `flex-wc`?. I win. Results match as well. 
So I beat the system! 

````
$ time wc ../pg145.txt ../pg1259.txt ../pg2641.txt 
   33655  319412 1865471 ../pg145.txt
   35296  245097 1473597 ../pg1259.txt
    9101   69639  415595 ../pg2641.txt
   78052  634148 3754663 total

real	0m0.034s
user	0m0.017s
sys	    0m0.008s
````
versus
````
$ time ./flex-wc ../pg145.txt ../pg1259.txt ../pg2641.txt 
   33655  319412 1865471 ../pg145.txt
   35296  245097 1473597 ../pg1259.txt
    9101   69639  415595 ../pg2641.txt
   78052  634148 3754663 total

real	0m0.019s
user	0m0.014s
sys	    0m0.003s
````