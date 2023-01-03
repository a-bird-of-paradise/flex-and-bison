# flex-and-bison
Working through Levine's book. There are a few typos which I noted in the individual folders.

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

3. So I now know what a hash table is and how they cope with overflows. There are two ways: you either change the table so that the table elements are pointers to entries with `next` members, or you grow the table when it runs out of space. 

    The chain approach is nicer and you can do things like track the tail as well as the head so inserts are quick. But lookups can get very slow if there are lots of collisions. One optimisation is to move the looked up object to the head every time so more common entries float to the top. 

    Regrowing the table seems like cheating but it does mean you still have exactly one thing in each table entry. 

    In this case we want to print out a sorted list of table entries at the end. This is a huge mess with the chain as we have to flatten the list of lists into one before sorting. But with an autogrowing hash table we just call `qsort` as always. 

    So you can either periodically double the hash table, or you can walk a chain more often and have to merge it at the end. So the growing table wins here.

## Chapter 3 Exercises

1. I ended up introducing the concept of compound statements to the grammar. So a list of one thing is just `x=1;` while a list of many things is `{x = 1; y = 2; }`. Just like `C`. Ideally would make terminal `;` optional (i.e. a newline will inject any single `;` needed) but this is a bit delicate. 

    This introduced very strange bison errors to do with the dangling else problem. I am not going to try and solve this now; I introduced sentinels like `fi` and `done` to explicitly close off certain constructs which obliterates this ambiguity. 

    I do have a memory leak somewhere. If a syntax error happens occasionally something doesn't get `free()`d. Need to track that down. (I ultimately traced this to calls to `free()` where `treefree()` was meant, e.g., assignments: the rvalue could be a structured expression so a full `treefree()` is needed.)

    Also introudced a couple more builtins, such as a tree printer and a quit function. 

    Having a thing which can do Newton-Raphson for me is pretty neat. The function is now defined as 

    `let sq(n) = { e = 1; while abs( ((t=n/e)-e) ) > 0.00001 do e = avg(e,t); done }`

2. The evaluation is done in this way to prevent scope pollution, I think. One of your later arguments could depend on some symbol you're about to modify in a complex way. So to avoid that we evaluate the arguments first, and only then update dummies. We also restore the dummies after for similar reasons - just in case something depended on them. 

## Chapter 4 Exercises

1. This is the kind of thing where the answer is It Depends. If you can easily restructure the grammar so that you can distinguish a bare column reference from other expressions then do that. In this case we have `NAME` or `NAME.NAME` already as columns so we can put those in. But you still have to be careful about whether it is a table or database or index `NAME` instead of a column one. 

    The most pragmatic one is to put in as narrow a thing as you easily can in the grammar, and then in the actions do symbol table lookups to make sure the thing exists and is of the right type. This is where syntax analysis (what Bison excels at) becomes semantic analysis (which you have to do). 

2. I borrowed the symbol table and referencer from a previous exercise and put it in. In the grammar, whenever we use a `NAME` we add a reference to it noting whether it is defining or refering to the symbol and what the symbol is in context. 

    I got lazy and didn't fully finish this. For example there is a hierarchy of names that should be tracked (DB -> Schema -> Table -> Column) but I didn't bother splitting these. And I don't print out whehter this reference is a table, column etc. And it's just jammed on to the RPN thing so we do things at once: calculate an RPN representation of the SQL and print out a cross reference. 

    But the astonishing thing is that it works!

3.  This was marked as a term project, and I don't have a term in which to do a project, so I didn't do it. 

## Chapter 5 Exercises

There aren't any; this chapter is just details of what Flex does. 

## Chapter 6 Exercises

There aren't any; this chapter is just details of what Bison does. 

## Chapter 7 exercises

1. Ambiguous grammars are bad because they are ambiguous. What is it you actually mean? 

    I've often thought this about English. "Bob went to visit Clive and they took his dog for a walk". Whose dog? This is quite a tortured example, but people say stuff like this all the time and it is your problem if you don't parse it correctly! 

    Another problem is that the fancy algo bison implements won't work if your grammar isn't sufficiently unambiguous. It relies on the fact that the next token tells it whether it is closing the current rule or extending it. 

2. There is the Willink C++ grammar and a couple of C grammars that I ran through Bison. They all went through OK!

    However on closer inspection this is because the grammars are full of `%left`/`%right`/`%nonassoc` etc to resolve ambiguous parses or feature really quite involved structures to prevent dangling else and friends from occurring. 

3.  So why are ambiguous grammars tolerated? 

    An ambiguous grammar is one that is not context free. And all human language isn't really context free - there are huge amounts of cultural and situational context to take into account. So to a certain extent it is only natural that computer programming languages have some manageable ambiguity in them. And in bison this additional context is provided via `%left`/`%right`/`%nonassoc`. 

    In the case of expressions, constructs like `a = x + y + z` are considered unambigious (even though they aren't) due to the associativity rules. You tell Bison that `%left '+'` is a thing and it will automatically reduce `x + y` first before doing the `+ z` later. Similar deal with dangling else, you tell it to prefer to shift `else` rather than reducing `if x then y` and it does the natural thing of matching `else`s to the nearest `if`. In fact Bison preferentially shifts anyway but the warnings are irritating. 

## Chapter 8 Exercises

1. This was already done in the book, and I added the `%destructor { free($$); } <type>` bit already as the sanitisers with clang were moaning about memory leaks. I had to add `yyclearin;` as the lookahead token was leaking. 

    It's a very simple error recovery process, really. If the user enters an incorrect command you basically ignore everything until the `\n` at which point you accept another. 

2. Again I don't do term projects as I don't have a term to do a term project in. However it did prompt me to look at the generated parser for 3-5 to see what undocumented features this is talking about. I think this is now just the `%define parse.error detailed` option which says "I was expecting a `;` and got an `EOL` so I am dying". 

    * RMS himself wrote parts of this. I feel like I'm profaning things even by looking. 
    * there is a hack in there to deal with a HPUX bug "probably can be removed in 2023"
    * some memory size allocation magic number "reasonable c. 2006"
    * a whole lot of tables that facilitate the actual parsing - would not like to generate these by hand
    * there is an off by one error in the `yydestruct()` line numbering, probably not the biggest deal in the world
    * the action code gets some string substitutions done and then it is copied verbatim into the parser

    Would be nice to be able to inject tokens but I can't figure out how to do that. 

## Chapter 9 Exercises 

2. We can break the LALR parser relatively easily with the `ON DUPLICATE` statement. As the scanner returns one token for `ON[ \t\n]+DUPLICATE` statements like
    ````sql
    INSERT INTO t1 (a,b,c) 
    VALUES (1,2,3)
    ON /* comment */ DUPLICATE KEY UPDATE c=c+1;
    ````
    cause an `ON` token to be returned, not the special `ON DUPLICATE` one, giving syntax errors like:
    ````
    error: syntax error, unexpected ON, expecting ONDUPLICATE or ';' or ','
    ````
    However the GLR parser just sees an `ON` token, then a `DUPLICATE` token, and the couple of branches it has after the `ON` are reduced to one when it sees `DUPLICATE`. So the following two statements are parsed correctly:
    ````sql
    INSERT INTO t1 (a,b,c) VALUES (1,2,3)
    ON DUPLICATE KEY UPDATE c=c+1;

    INSERT INTO t1 (a,b,c) VALUES (1,2,3)
    ON /* comment */ DUPLICATE KEY UPDATE c=c+1;
    ````
