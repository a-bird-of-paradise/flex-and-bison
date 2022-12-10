Similar issues with previous entry.
* New one: `curbs` should be set to the null pointer when moving to the next `argv`. 
* Book has a call to `strdup(yytext)` in the `#include` handler, which causes a leak, so I removed it
