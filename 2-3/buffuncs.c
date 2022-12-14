#include "bufstack.h"

extern struct bufstack *curbs;
extern char* curfilename;

int newfile(char* fn){
    FILE* f = fopen(fn, "r");
    if(!f) { perror(fn); return 0;  }

    struct bufstack* bs = malloc(sizeof(struct bufstack));
    if(!bs) { perror("malloc"); exit(1);    }

    if(curbs) curbs->lineno = yylineno;
    bs->prev = curbs;

    bs->bs = yy_create_buffer(f, YY_BUF_SIZE);
    bs->f = f;
    bs->filename = strdup(fn);

    yy_switch_to_buffer(bs->bs);

    curbs = bs;
    yylineno=1;
    curfilename = bs->filename;

    return 1;

}

int popfile(void){
    struct bufstack* bs = curbs;
    struct bufstack* prevbs;

    if(!bs) return 0;

    fclose(bs->f);
    free(bs->filename);
    yy_delete_buffer(bs->bs);

    prevbs = bs->prev;
    free(bs);

    if(!prevbs) return 0;

    yy_switch_to_buffer(prevbs->bs);
    curbs = prevbs;
    yylineno = curbs->lineno;
    curfilename = curbs->filename;
    return 1;

}