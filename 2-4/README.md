Some issues with the code from the book:
* No clean up. 
We `malloc()` new references and `strdup()` names without ever `free()`ing them. 
Not really a problem here as we just exit at the end. 
Nonetheless bad style. 
I added a routine which walks the globals and calls `free()`. 
* Reversing the reference list to produce ascending order results in only the last reference to that symbol being accessible. 
Again not actually a problem here as we just exit.
But still, to avoid leaks and enable reuse, I make sure the symbol's first reference is the new first (was last) reference. 
* I also made it case insensitive as `AND` and `And` and `and` are really the same thing.

Also need to make it deal with hash table overflow gracefully. 