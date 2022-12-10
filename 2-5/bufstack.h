#pragma once
#include "lex.yy.h"

struct bufstack {
    struct bufstack* prev;
    YY_BUFFER_STATE bs;
    int lineno;
    char* filename;
    FILE* f;
};
