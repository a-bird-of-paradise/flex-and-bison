# flex-and-bison
Working through Levine's book

## Chapter 1 exercises

1. To get comments accepted by the calculator, you have to add a flex rule `"//".*\n` and perform the same action for this as you would a regular `\n`. This treats everything from (and including) the `//` to (but not including) the end of the line as if it didn't exist. 

Another thing is getting Bison to accept a bare newline. You need to tell it that a bare EOL is acceptable by adding another rule: `calclist EOL`. 

Additionally this will break if there is an EOF in the comment. But this is an interactive app so it is OK. 

Could also have used trailing context to ignore the newline and let the usual newline handler deal with it. 

2. This is straightforward - add the pattern to the scanner and add the hex print to the bison action. Additionally I extended it to work with octal as well, by saying any digit string that starts with a leading zero is octal. So it will produce an octal and a decimal number in succession if you include an 8 or a 9 in a string with leading zeroes. 

3. This was a pain - Bison doesn't like ambiguous reuse of symbols. I ended up hacking in the absolute value operator so that if you do `3+|(12-24)` for example it will abs the value in brackets. (This also made me realise why programming languages always have `abs()` as a function call - the single token lookahead of many parsers means that you kind of have to if you want `|` available for bit twiddling). 

    Precendence matters for the bitwise ops - basically, `*/` beats `+-` beats `&` beats `|`. I borrowed the tactic from the book. Start with the lowest precedence and word upwards, and when you get to the actual number tokens include parens around the lowest precendce operator expression. So anything in parens gets evaluated to a bare number first. 

4. The trivial answer is no, as the handwritten one includes comments and the flex example given doesn't. Other things are EOF handling - mine only accepts newlines in comments not EOFs (or indeed any other statement). 

5. Languages you can't use flex for are languages that aren't regular in how they define tokens. Ancient versions of Fortran come to mind - whitespace could or could not be meaningful depending on characters far in the future. Natural languages are also way too ambiguous to be sensibly treated - you're basically doing a dictionary lookup. 

6. I didn't rewrite it in `C`. I did look at the GNU version. `wc` is fabulously complicated. Even if you strip it back to its core features it's still surprisingly tricky. So even if it does go faster, the flex version is way easier to think about. 

## Chapter 2 Exercises

1. This consumes characters one at a time because it needs to do special things with `#` and `\n`. So we can create a pattern that just dumps out lines with no `#` in them and handle the `\n` normally. I did this and it is just

    ````lex
    %%
    ^[^#\n].*   {   fprintf(yyout, "%4d %s", yylineno, yytext);     }
    ````

    This means that any line that starts with a `#`, or is an empty line, gets processed using existing character-by-character rules while other lines (which are actually most lines!) get processed all at once. 

2. I had actually done this already!

3. Oh boy. I'll have to look up hash table theory first...
