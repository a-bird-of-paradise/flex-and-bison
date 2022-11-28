Couple of issues with the code that came in the book. 

* There is a memory leak in the `newfile` in the book. 
If it can't find the file, it'll leak a buffer stack item. 
Not the biggest deal in the world as it then terminates, but still.
Resolved by exiting without allocating in this instance.  

* The `yylineno` handling in the lexer actions is also wrong. 
Flex will increment this if your rule matches a `\n` so you don't need `yylineno++` all over the place. 
Only place you need to do anything with it is matching the singleton newline row `^\n`. 
As you need to print out a row number that is one less than the autoincremented `yylineno`. 

* I also adapted it so it only `#include`s local header files. 
One thing to come back to - make it look at global includes like an actual compiler. 
However it is neat seeing your `#include "file.h"` actually get included. 