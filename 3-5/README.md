The calculator as specified in the book has a memory leak in the `treefree()` function. When the node being freed is an assignment or a conditional, then if the RHS or the condition respectively is strucutred only its root node gets freed. 

Easy enough to fix: look at p73, replace calls to `free()` with `treefree()` and your memory leak detectors will be happy. 

Quite a tricky bug to track down although very obvious now I know about it. (The call to `free(a)` on p74 is correct). 