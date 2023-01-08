Getting the C++ simple calculator built was very close to the book. Couple of minor snags (mostly as Bison has moved on since the book was published):

* Bison has now deprecated the book's way of naming classes, and now wants you to use 
`%define api.parser.class {cppcalc}` constructs

* The book's way of setting the initial filenames leaks a string on exit, which is not the biggest deal in the world here. However I didn't like it. 

    I added the string to the context object and initialised the location filenames by reference to this. Now it exits without an llvm sanitiser complaint.

* I had to tell Flex to generate its C outputs with C++ file extensions to stop llvm complaining about deprecated functionality

* I had to put in the Bison version number explicitly in the Bison grammar to stop it generating now-redundant header files `%require "3.8.2"`

From reading the Flex and Bison manuals, it is apparent that the C++ interfaces have moved on significantly since the book was published. 

As the final thing with this book, I am going to take the advanced calculator (from example 9-2) and rewrite it using the latest C++ functionality. Broadly speaking, this is making Flex return "complete symbols" i.e. an object with the symbol type, the symbol value, and the symbol's location; and using a Flex scanner class which now, apparently, works, kinda. I did eventually implement this, [read all about it](../misc/cppcalc/README.md). 