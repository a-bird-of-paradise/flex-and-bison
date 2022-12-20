extern int yylineno;
void yyerror(char *s, ...);
int yylex(void);

typedef struct ast_node_t {
    int nodetype;
    struct ast_node_t *l; 
    struct ast_node_t *r;
} AST_NODE;

typedef struct numval_t {
    int nodetype;
    double number;
} NUMVAL;

AST_NODE *newast(int nodetype, AST_NODE *l, AST_NODE *r);
AST_NODE *newnum(double d);

double eval(AST_NODE *x);
void treefree(AST_NODE *x);
