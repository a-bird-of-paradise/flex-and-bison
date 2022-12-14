%code top {
#include "lex.yy.h"
}

%code requires {
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
#include "symbol.h"
}

%code provides {
void yyerror(const char *s, ...);
void emit(char *s, ...);
}

%define parse.error detailed
%define parse.trace

%glr-parser
%expect 2
%expect-rr 59

%union {
    int intval;
    double floatval;
    char *strval;
    int subtok;
}

%destructor { free($$); } <strval>

%token <strval> NAME STRING USERVAR
%token <intval> INTNUM BOOL
%token <floatval> APPROXNUM

%right ASSIGN
%left OR
%left XOR
%left ANDOP
%nonassoc IN IS LIKE REGEXP
%left NOT '!'
%left BETWEEN
%left <subtok> COMPARISON
%left '|' 
%left '&'
%left <subtok> SHIFT
%left '+' '-'
%left '*' '/' '%' MOD
%left '^'
%nonassoc UMINUS

%token ADD
%token ALL
%token ALTER
%token ANALYZE
%token AND
%token ANY
%token AS
%token ASC
%token AUTO_INCREMENT
%token BEFORE
%token BETWEEN
%token BIGINT
%token BINARY
%token BIT
%token BLOB
%token BOTH
%token BY
%token CALL
%token CASCADE
%token CASE
%token CHANGE
%token CHAR
%token CHECK
%token COLLATE
%token COLUMN
%token COMMENT
%token CONDIITON
%token CONSTRAINT
%token CONTINUE
%token CONVERT
%token CREATE
%token CROSS
%token CURRENT_DATE
%token CURRENT_TIME
%token CURRENT_TIMESTAMP
%token CURRENT_USER
%token CURSOR
%token DATABASE
%token DATABASES
%token DATE
%token DATETIME
%token DAY_HOUR
%token DAY_MICROSECOND
%token DAY_MINUTE
%token DAY_SECOND
%token DECIMAL
%token DECLARE
%token DEFAULT
%token DELAYED
%token DELETE
%token DESC
%token DESCRIBE
%token DETERMINISTIC
%token DISTINCT
%token DISTINCTROW
%token DIV
%token DOUBLE
%token DROP
%token DUAL
%token EACH
%token ELSE
%token ELSEIF
%token END
%token ENUM
%token ESCAPED
%token EXISTS
%token EXIT
%token EXPLAIN
%token FETCH
%token FLOAT
%token FOR
%token FORCE
%token FOREIGN
%token FROM
%token FULLTEXT
%token GRANT
%token GROUP
%token HAVING
%token HIGH_PRIORITY
%token HOUR_MICROSECOND
%token HOUR_MINUTE
%token HOUR_SECOND
%token IF
%token IGNORE
%token IN
%token INDEX
%token INFILE
%token INNER
%token INOUT
%token INSENSITIVE
%token INSERT
%token INT
%token INTEGER
%token INTERVAL
%token INTO
%token IS
%token ITERATE
%token JOIN
%token KEY
%token KEYS
%token KILL
%token LEADING
%token LEAVE
%token LEFT
%token LIKE
%token LIMIT
%token LINES
%token LOAD
%token LOCALTIME
%token LOCALTIMESTAMP
%token LOCK
%token LONG
%token LONGBLOB
%token LONGTEXT
%token LOOP
%token LOW_PRIORITY
%token MATCH
%token MEDIUMBLOB
%token MEDIUMINT
%token MEDIUMTEXT
%token MINUTE_MICROSECOND
%token MINUTE_SECOND
%token MOD
%token MODIFIES
%token NATURAL
%token NOT
%token NO_WRITE_TO_BINLOG
%token NULLX
%token NUMBER
%token ON
%token DUPLICATE
%token OPTIMIZE
%token OPTION
%token OPTIONALLY
%token OR
%token ORDER
%token OUT
%token OUTER
%token OUTFILE
%token PRECISION
%token PRIMARY
%token PROCEDURE
%token PURGE
%token QUICK
%token READ
%token READS
%token REAL
%token REFERENCES
%token REGEXP
%token RELEASE
%token RENAME
%token REPEAT
%token REPLACE
%token REQUIRE
%token RESTRICT
%token RETURN
%token REVOKE
%token RIGHT
%token ROLLUP
%token SCHEMA
%token SCHEMAS
%token SECOND_MICROSECOND
%token SELECT
%token SENSITIVE
%token SEPARATOR
%token SET
%token SHOW
%token SMALLINT
%token SOME
%token SONAME
%token SPATIAL
%token SPECIFIC
%token SQL
%token SQLEXCEPTION
%token SQLSTATE
%token SQLWARNING
%token SQL_BIG_RESULT
%token SQL_CALC_FOUND_ROWS
%token SQL_SMALL_RESULT
%token SSL
%token STARTING
%token STRAIGHT_JOIN
%token TABLE
%token TEMPORARY
%token TERMINATED
%token TEXT
%token THEN
%token TIME
%token TIMESTAMP
%token TINYINT
%token TINYTEXT
%token TINYBLOB
%token TO
%token TRAILING
%token TRIGGER
%token UNDO
%token UNION
%token UNIQUE
%token UNLOCK
%token UNSIGNED
%token UPDATE
%token USAGE
%token USE
%token USING
%token UTC_DATE
%token UTC_TIME
%token UTC_TIMESTAMP
%token VALUES
%token VARBINARY
%token VARCHAR
%token VARYING
%token WHEN
%token WHERE
%token WHILE
%token WITH
%token WRITE
%token XOR
%token YEAR
%token YEAR_MONTH
%token ZEROFILL

%token FSUBSTRING FTRIM FDATE_ADD FDATE_SUB FCOUNT

%type <intval> select_opts select_expr_list
%type <intval> val_list opt_val_list case_list
%type <intval> group_by_list opt_with_rollup opt_asc_desc
%type <intval> table_references opt_inner_cross opt_outer
%type <intval> left_or_right opt_left_or_right_outer column_list
%type <intval> index_list opt_for_join

%type <intval> delete_opts delete_list
%type <intval> insert_opts insert_vals insert_vals_list
%type <intval> insert_asgn_list opt_if_not_exists update_opts update_asgn_list
%type <intval> opt_temporary opt_length opt_binary opt_uz enum_list
%type <intval> column_atts data_type opt_ignore_replace create_col_list

%start stmt_list

%%

stmt_list: stmt ';' 
    | stmt_list stmt ';' 
    | error ';'             { yyclearin; yyerrok; }
    | stmt_list error ';'   { yyclearin; yyerrok; };

stmt:   select_stmt     {   emit("STMT");   }
    |   delete_stmt     {   emit("STMT");   }
    |   insert_stmt     {   emit("STMT");   }
    |   update_stmt     {   emit("STMT");   }
    |   replace_stmt    {   emit("STMT");   }
    |   create_database_stmt {emit("STMT"); }
    |   create_table_stmt   {emit("STMT");  }
    |   set_stmt        {   emit("STMT");   };

expr:   NAME                            {   emit("NAME %s", $1);    
                                            addref(yylineno, curfilename, $1, SYMTAB_REFER | SYMTAB_COL);    
                                            free($1);                                   }
    |   NAME '.' NAME                   {   emit("FIELDNAME %s.%s", $1, $3);    
                                            char* buffer = malloc(sizeof(char) * ( strlen($1) + strlen($3) + 4));
                                            strcpy(buffer, $1);
                                            strcat(buffer, ".");
                                            strcat(buffer, $3);
                                            addref(yylineno, curfilename, buffer, SYMTAB_REFER | SYMTAB_COL);
                                            free($1);   free($3);   free(buffer);       }   
    |   USERVAR                         {   emit("USERVAR %s", $1); free($1);           }
    |   STRING                          {   emit("STRING %s", $1); free($1);            }
    |   INTNUM                          {   emit("NUMBER %d", $1);                      }
    |   APPROXNUM                       {   emit("FLOAT %g", $1);                       }
    |   BOOL                            {   emit("BOOL %d", $1);                        }
    |   expr '+' expr                   {   emit("ADD");                                }
    |   expr '-' expr                   {   emit("SUB");                                }
    |   expr '*' expr                   {   emit("MUL");                                }
    |   expr '/' expr                   {   emit("DIV");                                }
    |   expr '%' expr                   {   emit("MOD");                                }
    |   expr MOD expr                   {   emit("MOD");                                }
    |   '-' expr %prec UMINUS           {   emit("UMINUS");                             }
    |   expr ANDOP expr                 {   emit("AND");                                }
    |   expr OR expr                    {   emit("OR");                                 }
    |   expr XOR expr                   {   emit("XOR");                                }
    |   expr '|' expr                   {   emit("BITOR");                              }
    |   expr '&' expr                   {   emit("BITAND");                             }
    |   expr '^' expr                   {   emit("BITNOT");                             }
    |   expr SHIFT expr                 {   emit("SHIFT %s", $2==1?"left":"right");     }
    |   NOT expr                        {   emit("NOT");                                } %dprec 1
    |   '!' expr                        {   emit("NOT");                                }
    |   expr COMPARISON expr            {   emit("CMP %d", $2);                         }
    |   expr COMPARISON      '(' select_stmt ')' { emit("CMPSELECT %s",$2);             }   
    |   expr COMPARISON ANY  '(' select_stmt ')' { emit("CMPANYSELECT %s",$2);          }
    |   expr COMPARISON SOME '(' select_stmt ')' { emit("CMPANYSELECT %s",$2);          }
    |   expr COMPARISON ALL  '(' select_stmt ')' { emit("CMPALLSELECT %s",$2);          }
    |   expr IS NULLX                   { emit("ISNULL");                               }
    |   expr IS NOT NULLX               { emit("ISNULL"); emit("NOT");                  }
    |   expr IS BOOL                    {   emit("ISBOOL %d", $3);                      }
    |   expr IS NOT BOOL                {   emit("ISBOOL %d", $4); emit("NOT");         }
    |   USERVAR ASSIGN expr             {   emit("ASSIGN @%s", $1);                     }
    |   expr BETWEEN expr AND expr %prec BETWEEN { emit("BETWEEN");                     }
    |   expr IN '(' val_list ')'        {   emit("ISIN %d",$4);                         }
    |   expr NOT IN '(' val_list ')'    {   emit("ISIN %d", $5); emit("NOT");           }
    |   expr IN '(' select_stmt ')'     {   emit("CMPANYSELECT 4");                     }
    |   expr NOT IN '(' select_stmt ')' {   emit("CMPANYSELECT 3");                     }
    |   EXISTS '(' select_stmt ')'      {   emit("EXISTS 1");                           }
    |   NOT EXISTS '(' select_stmt ')'  {   emit("EXISTS 0");                           } %dprec 2
    |   NAME '(' opt_val_list ')'       {   emit("CALL %d %s", $3, $1); free($1);       }
    |   FCOUNT '(' '*' ')'              {   emit("COUNTALL");                           }
    |   FCOUNT '(' DISTINCT expr ')'    {   emit("CALL DISTINCT COUNT");                }
    |   FCOUNT '(' expr ')'             {   emit("CALL 1 COUNT");                       }
    |   FSUBSTRING '(' val_list ')'     {   emit("CALL %d SUBSTR", $3);                 }
    |   FSUBSTRING '(' expr FROM expr ')'   { emit("CALL 2 SUBSTR");                    }
    |   FSUBSTRING '(' expr FROM expr FOR expr ')'  { emit("CALL 3 SUBSTR");            }
    |   FTRIM '(' val_list ')'          {   emit("CALL %d TRIM", $3);                   }
    |   FTRIM '(' trim_tlb expr FROM val_list ')'   { emit("CALL 3 TRIM");              }
    |   FDATE_ADD '(' expr ',' interval_exp ')' { emit("CALL 3 DATE_ADD");              }
    |   FDATE_SUB '(' expr ',' interval_exp ')' { emit("CALL 3 DATE_SUB");              }
    |   CASE expr case_list END         {   emit("CASEVAL %d 0", $3);                   }
    |   CASE expr case_list ELSE expr END { emit("CASEVAL %d 1", $3);                   }
    |   CASE case_list END              {   emit("CASE %d 0", $2);                      }
    |   CASE case_list ELSE expr END    {   emit("CASE %d 1, $2");                      }
    |   expr LIKE expr                  {   emit("LIKE");                               }
    |   expr NOT LIKE expr              {   emit("LIKE");   emit("NOT");                }
    |   expr REGEXP expr                {   emit("REGEXP");                             }
    |   expr NOT REGEXP expr            {   emit("REGEXP");   emit("NOT");              }
    |   CURRENT_TIMESTAMP               {   emit("NOW");                                }
    |   CURRENT_DATE                    {   emit("NOW");                                }
    |   CURRENT_TIME                    {   emit("NOW");                                };


val_list:   expr    {   $$ = 1;             }
    |   expr ',' val_list { $$ = 1 + $3;    };

opt_val_list:   %empty  {   $$ = 0; }
    |   val_list;

trim_tlb:   LEADING     {   emit("NUMBER 1");   }
    |   TRAILING        {   emit("NUMBER 2");   }
    |   BOTH            {   emit("NUMBER 3");   };

interval_exp:   INTERVAL expr DAY_HOUR      {   emit("NUMBER 1");   }
    |   INTERVAL expr DAY_MICROSECOND       {   emit("NUMBER 2");   }
    |   INTERVAL expr DAY_MINUTE            {   emit("NUMBER 3");   }
    |   INTERVAL expr DAY_SECOND            {   emit("NUMBER 4");   }
    |   INTERVAL expr YEAR_MONTH            {   emit("NUMBER 5");   }
    |   INTERVAL expr YEAR                  {   emit("NUMBER 6");   }
    |   INTERVAL expr HOUR_MICROSECOND      {   emit("NUMBER 7");   }
    |   INTERVAL expr HOUR_MINUTE           {   emit("NUMBER 8");   }
    |   INTERVAL expr HOUR_SECOND           {   emit("NUMBER 9");   };

case_list:  WHEN expr THEN expr             {   $$ = 1;             }
    |   case_list WHEN expr THEN expr       {   $$ = $1+1;          };

select_stmt:
    SELECT select_opts select_expr_list {   emit("SELECTNODATA %d %d",$2, $3);  }
    |   SELECT select_opts select_expr_list 
        FROM    table_references
        opt_where
        opt_groupby
        opt_having
        opt_orderby
        opt_limit
        opt_into_list { emit("SELECT %d %d %d", $2, $3, $5);};

opt_where:  %empty | WHERE expr {emit("WHERE");};

opt_groupby: %empty | GROUP BY group_by_list opt_with_rollup {
    emit("GROUPBYLIST %d %d", $3, $4);
};

group_by_list:  expr opt_asc_desc {emit("GROUPBY %d", $2); $$=1;}
    |   group_by_list ',' expr opt_asc_desc {emit("GROUPBY %d", $4); $$ = $1+1;};

opt_asc_desc:   %empty {$$ = 0;} | ASC {$$=0;} | DESC {$$=1;};

opt_with_rollup: %empty {$$=0;} | WITH ROLLUP {$$=1;};

opt_having: %empty | HAVING expr { emit("HAVING");  };

opt_orderby: %empty | ORDER BY group_by_list { emit("ORDERBY %d", $3);  };

opt_limit: %empty 
    |   LIMIT expr          {   emit("LIMIT 1");    }
    |   LIMIT expr ',' expr {   emit("LIMIT 2");    };

opt_into_list:  %empty | INTO column_list { emit("INTO %d", $2);    };

column_list:    NAME        {   emit("COLUMN %s", $1); addref(yylineno, curfilename, $1, SYMTAB_REFER | SYMTAB_COL); free($1);    $$=1;   }
|   column_list ',' NAME    {   emit("COLUMN %s", $3); addref(yylineno, curfilename, $3, SYMTAB_REFER | SYMTAB_COL); free($3);    $$=1+$1;};

select_opts:    %empty {$$=0;}
|   select_opts ALL { 
    if($1 & 01) yyerror("Duplicate ALL option"); $$ = $1 | 01;  }
|   select_opts DISTINCT { 
    if($1 & 02) yyerror("Duplicate DISTINCT option"); $$ = $1 | 02;  }
|   select_opts DISTINCTROW { 
    if($1 & 04) yyerror("Duplicate DISTINCTROW option"); $$ = $1 | 04;  }
|   select_opts HIGH_PRIORITY { 
    if($1 & 010) yyerror("Duplicate HIGH_PRIORITY option"); $$ = $1 | 010;  }
|   select_opts STRAIGHT_JOIN { 
    if($1 & 020) yyerror("Duplicate STRAIGHT_JOIN option"); $$ = $1 | 020;  }
|   select_opts SQL_SMALL_RESULT { 
    if($1 & 040) yyerror("Duplicate SQL_SMALL_RESULT option"); $$ = $1 | 040;  }
|   select_opts SQL_BIG_RESULT { 
    if($1 & 0100) yyerror("Duplicate SQL_BIG_RESULT option"); $$ = $1 | 0100;  }
|   select_opts SQL_CALC_FOUND_ROWS { 
    if($1 & 0200) yyerror("Duplicate SQL_CALC_FOUND_ROWS option"); $$ = $1 | 0200;  };

select_expr_list:   select_expr {$$ = 1;    }
|   select_expr_list ',' select_expr { $$ = $1+1;   }
|   '*' { emit ("SELECTALL"); $$ = 1;};

select_expr: expr opt_as_alias;

opt_as_alias:   AS NAME {   emit ("ALIAS %s", $2);     
                            addref(yylineno, curfilename, $2, SYMTAB_DEFINE | SYMTAB_COL);    
                            free($2);   }
|   NAME {  emit("ALIAS %s", $1);    
            addref(yylineno, curfilename, $1, SYMTAB_DEFINE | SYMTAB_COL);    
            free($1);  }
|   %empty ;


opt_as_alias_tab: AS NAME { emit ("ALIAS %s", $2);     
                            addref(yylineno, curfilename, $2, SYMTAB_DEFINE | SYMTAB_TABLE);    
                            free($2);   }
|   NAME {  emit("ALIAS %s", $1);    
            addref(yylineno, curfilename, $1, SYMTAB_DEFINE | SYMTAB_TABLE);    
            free($1);  }
|   %empty ;

table_references:   table_reference         { $$ = 1;       }
|   table_references ',' table_reference    { $$ = $1+1;    };

table_reference: table_factor | join_table;

table_factor: 
    NAME opt_as_alias_tab index_hint            {   emit("TABLE %s", $1);      
                                                    addref(yylineno, curfilename, $1, SYMTAB_REFER | SYMTAB_TABLE);    
                                                    free($1);                   }
|   NAME '.' NAME opt_as_alias_tab index_hint   {   emit("TABLE %s.%s", $1, $3);   
                                                    char* buffer = malloc(sizeof(char) * ( strlen($1) + strlen($3) + 4));
                                                    strcpy(buffer, $1);
                                                    strcat(buffer, ".");
                                                    strcat(buffer, $3);
                                                    addref(yylineno, curfilename, buffer, SYMTAB_REFER | SYMTAB_TABLE);
                                                    free($1); free($3); free(buffer);  }
|   table_subquery opt_as NAME                  {   emit("SUBQUERYAS %s", $3);      
                                                    addref(yylineno, curfilename, $3, SYMTAB_DEFINE | SYMTAB_TABLE);    
                                                    free($3);              }
|   '(' table_references ')'                    {   emit("TABLEREFERENCES %d", $2);                   };

opt_as: %empty | AS;

join_table:
    table_reference opt_inner_cross JOIN table_factor opt_join_condition 
    {   emit("JOIN %d", $2+100);    }
|   table_reference STRAIGHT_JOIN table_factor
    {   emit("JOIN %d", 200);       }
|   table_reference STRAIGHT_JOIN table_factor ON expr
    {   emit("JOIN %d", 200);       }
|   table_reference left_or_right opt_outer JOIN table_factor join_condition
    {   emit("JOIN %d", 300+$2+$3); }
|   table_reference NATURAL opt_left_or_right_outer JOIN table_factor
    {   emit("JOIN %d", 400+$3);    };

opt_inner_cross:   
    %empty  {   $$=0;   }
|   INNER   {   $$=1;   }
|   CROSS   {   $$=2;   }
;

opt_outer: %empty { $$=0; } | OUTER { $$=1; };

left_or_right: LEFT { $$ = 1; } | RIGHT { $$ = 2; };

opt_left_or_right_outer: %empty     { $$ = 0;      }
|   LEFT opt_outer                  { $$ = 1 + $2; }
|   RIGHT opt_outer                 { $$ = 2 + $2; };

opt_join_condition: %empty | join_condition;

join_condition: ON expr         { emit("ONEXPR");       }
|   USING '(' column_list ')'   { emit("USING %d", $3); };

index_hint: %empty 
|   USE KEY opt_for_join '(' index_list ')'
        {   emit("INDEXHINT %d %d", $5, $3+10); }
|   IGNORE KEY opt_for_join '(' index_list ')'
        {   emit("INDEXHINT %d %d", $5, $3+20); }
|   FORCE KEY opt_for_join '(' index_list ')'
        {   emit("INDEXHINT %d %d", $5, $3+30); };

opt_for_join: FOR JOIN { $$ = 1; } | %empty { $$ = 0; };

index_list: NAME        {   emit("INDEX %s", $1); free($1); $$ = 1; }
|   index_list ',' NAME {   emit("INDEX %s", $3); free($3); $$=1+$1;};

table_subquery: '(' select_stmt ')' { emit ("SUBQUERY"); };

delete_stmt:    
    DELETE  delete_opts
    FROM    NAME
    opt_where
    opt_orderby
    opt_limit   {   emit("DELETEONE %d %s", $2, $4); free($4);  }
|   DELETE delete_opts
    delete_list
    FROM    table_references
    opt_where   {   emit("DELETEMULTI %d %d %d", $2, $3, $5);   }
|   DELETE delete_opts
    FROM    delete_list
    USING   table_references
    opt_where   {   emit("DELETEMULTI %d %d %d", $2, $4, $6);   };

delete_opts:    %empty  {   $$  =   0;  }
    |   delete_opts LOW_PRIORITY    {   $$ = $1 + 01;   }
    |   delete_opts QUICK           {   $$ = $1 + 02;   }
    |   delete_opts IGNORE          {   $$ = $1 + 04;   };

delete_list:    NAME    opt_dot_star {  
        emit("TABLE %s", $1); 
        addref(yylineno, curfilename, $1, SYMTAB_REFER | SYMTAB_COL);
        free($1); $$ = 1; }
    |   delete_list ',' NAME opt_dot_star {
        emit("TABLE %s", $3); 
        addref(yylineno, curfilename, $3, SYMTAB_REFER | SYMTAB_COL);
        free($3); $$ = 1+$1;
    };

opt_dot_star:   %empty |    '.' '*';

insert_stmt:
    INSERT insert_opts opt_into NAME
    opt_col_names
    VALUES insert_vals_list
    opt_onudupupdate { emit("INSERTVALS %d %d %s", $2, $7, $4); free($4);   }
|   INSERT insert_opts opt_into NAME
    SET insert_asgn_list
    opt_onudupupdate { emit("INSERTASGN %d %d %s", $2, $6, $4); free($4);   }
|   INSERT insert_opts opt_into NAME opt_col_names
    select_stmt
    opt_onudupupdate { emit("INSERTSELECT %d %s", $2, $4); free($4);        };

opt_onudupupdate:   %empty
    |   ON DUPLICATE KEY UPDATE insert_asgn_list { emit("DUPUPDATE %d", $5); };

insert_opts:    %empty { $$ = 0; }
|   insert_opts LOW_PRIORITY    {   $$ = $1 | 01;   }
|   insert_opts DELAYED         {   $$ = $1 | 02;   }
|   insert_opts HIGH_PRIORITY   {   $$ = $1 | 04;   }
|   insert_opts IGNORE          {   $$ = $1 | 010;  };

opt_into:   %empty | INTO;

opt_col_names:  %empty | '(' column_list ')' { emit("INSERTCOLS %d", $2); };

insert_vals_list: '(' insert_vals ')'           { emit("VALUES %d", $2); $$ = 1;        }
|   insert_vals_list ',' '(' insert_vals ')'    { emit("VALUES %d", $4); $$ = 1 + $1;   };

insert_vals:    expr { $$ = 1; }
|   DEFAULT { emit("DEFAULT"); $$ = 1; }
|   insert_vals ',' expr { $$ = $1 + 1; }
|   insert_vals ',' DEFAULT { emit("DEFAULT"); $$ = $1 + 1; };

insert_asgn_list:
    NAME COMPARISON expr {
        if($2 != 4) { yyerror("Bad insert assignment to %s", $1); YYERROR; }
        emit("ASSIGN %s", $1);
        addref(yylineno, curfilename, $1, SYMTAB_REFER | SYMTAB_COL);
        free($1);
        $$ = 1;
    }
|   NAME COMPARISON DEFAULT { 
        if($2 != 4) { yyerror("Bad insert assignment to %s", $1); YYERROR; }
        emit("DEFAULT");
        emit("ASSIGN %s", $1);
        addref(yylineno, curfilename, $1, SYMTAB_REFER | SYMTAB_COL);
        free($1);
        $$ = 1;
    }
|   insert_asgn_list ',' NAME COMPARISON expr {
        if($4 != 4) { yyerror("Bad insert assignment to %s", $3); YYERROR; }
        emit("ASSIGN %s", $3);
        addref(yylineno, curfilename, $3, SYMTAB_REFER | SYMTAB_COL);
        free($3);
        $$ = 1 + $1;
    }
|   insert_asgn_list ',' NAME COMPARISON DEFAULT { 
        if($4 != 4) { yyerror("Bad insert assignment to %s", $3); YYERROR; }
        emit("DEFAULT");
        emit("ASSIGN %s", $3);
        addref(yylineno, curfilename, $3, SYMTAB_REFER | SYMTAB_COL);
        free($3);
        $$ = 1 + $1;
    };

replace_stmt:
    REPLACE insert_opts opt_into NAME
    opt_col_names
    VALUES insert_vals_list
    opt_onudupupdate { emit("REPLACEVALS %d %d %s", $2, $7, $4); free($4);   }
|   REPLACE insert_opts opt_into NAME
    SET insert_asgn_list
    opt_onudupupdate { emit("REPLACEASGN %d %d %s", $2, $6, $4); free($4);   }
|   REPLACE insert_opts opt_into NAME opt_col_names
    select_stmt
    opt_onudupupdate { emit("REPLACESELECT %d %s", $2, $4); free($4);        };

update_stmt:
    UPDATE update_opts table_references
    SET update_asgn_list
    opt_where
    opt_orderby
    opt_limit 
    { emit("UPDATE %d %d %d", $2, $3, $5);  };

update_opts:    %empty          { $$ = 0;       }
|   update_opts LOW_PRIORITY    { $$ = $1 | 01; }
|   update_opts IGNORE          { $$ = $1 | 02; };

update_asgn_list:
    NAME COMPARISON expr {
        if($2 != 4) { yyerror("Bad update assignment to %s", $1); YYERROR; }
        emit("ASSIGN %s", $1);
        addref(yylineno, curfilename, $1, SYMTAB_REFER | SYMTAB_COL);
        free($1);
        $$ = 1;
    }
|   NAME '.' NAME COMPARISON expr {
        if($4 != 4) { yyerror("Bad update assignment to %s", $1); YYERROR; }
        emit("ASSIGN %s.%s", $1, $3);
        char* buffer = malloc(sizeof(char) * ( strlen($1) + strlen($3) + 4));
        strcpy(buffer, $1);
        strcat(buffer, ".");
        strcat(buffer, $3);
        addref(yylineno, curfilename, buffer, SYMTAB_REFER | SYMTAB_COL);
        free($1); free($3); free(buffer);
        $$ = 1;
    }
|   update_asgn_list ',' NAME COMPARISON expr {
        if($4 != 4) { yyerror("Bad update assignment to %s", $3); YYERROR; }
        emit("ASSIGN %s", $3);
        addref(yylineno, curfilename, $3, SYMTAB_REFER | SYMTAB_COL);
        free($3);
        $$ = 1 + $1;
    }
|   update_asgn_list ',' NAME '.' NAME COMPARISON expr {
        if($6 != 4) { yyerror("Bad update assignment to %s", $3); YYERROR; }
        emit("ASSIGN %s.%s", $3, $5);
        char* buffer = malloc(sizeof(char) * ( strlen($3) + strlen($5) + 4));
        strcpy(buffer, $3);
        strcat(buffer, ".");
        strcat(buffer, $5);
        addref(yylineno, curfilename, buffer, SYMTAB_REFER | SYMTAB_COL);
        free($3); free($5); free(buffer);
        $$ = 1 + $1;
    };

create_database_stmt:
    CREATE DATABASE opt_if_not_exists NAME
    { emit("CREATEDATABASE %d %s", $3, $4); 
        addref(yylineno, curfilename, $4, SYMTAB_DEFINE | SYMTAB_DB);
        free($4); }
|   CREATE SCHEMA opt_if_not_exists NAME
    { emit("CREATEDATABASE %d %s", $3, $4); 
        addref(yylineno, curfilename, $4, SYMTAB_DEFINE | SYMTAB_DB);
        free($4); };

opt_if_not_exists:  %empty  { $$ = 0;   }
|   IF NOT EXISTS           { $$ = 1;   };

create_table_stmt:
    CREATE opt_temporary TABLE opt_if_not_exists NAME '(' create_col_list ')'
        { emit("CREATE %d %d %d %s", $2, $4, $7, $5);  
        addref(yylineno, curfilename, $5, SYMTAB_DEFINE | SYMTAB_TABLE);
        free($5); }
|   
    CREATE opt_temporary TABLE opt_if_not_exists NAME '.' NAME '(' create_col_list ')'
        { emit("CREATE %d %d %d %s.%s", $2, $4, $9, $5, $7); 
        char* buffer = malloc(sizeof(char) * ( strlen($5) + strlen($7) + 4));
        strcpy(buffer, $5);
        strcat(buffer, ".");
        strcat(buffer, $7);
        addref(yylineno, curfilename, buffer, SYMTAB_DEFINE | SYMTAB_TABLE);
        free($5); free($7); free(buffer);}
|
    CREATE opt_temporary TABLE opt_if_not_exists NAME '(' create_col_list ')' create_select_stmt
        { emit("CREATESELECT %d %d %d %s", $2, $4, $7, $5); ;  
        addref(yylineno, curfilename, $5, SYMTAB_DEFINE | SYMTAB_TABLE);
        free($5); }
|
    CREATE opt_temporary TABLE opt_if_not_exists NAME create_select_stmt
        { emit("CREATESELECT %d %d %d %s", $2, $4, 0, $5); ;  
        addref(yylineno, curfilename, $5, SYMTAB_DEFINE | SYMTAB_TABLE);
        free($5); }
|
    CREATE opt_temporary TABLE opt_if_not_exists NAME '.' NAME '(' create_col_list ')' create_select_stmt
        { emit("CREATESELECT %d %d %d %s.%s", $2, $4, $9, $5, $7); 
        char* buffer = malloc(sizeof(char) * ( strlen($5) + strlen($7) + 4));
        strcpy(buffer, $5);
        strcat(buffer, ".");
        strcat(buffer, $7);
        addref(yylineno, curfilename, buffer, SYMTAB_DEFINE | SYMTAB_TABLE);
        free($5); free($7); free(buffer);}
|
    CREATE opt_temporary TABLE opt_if_not_exists NAME '.' NAME create_select_stmt
        { emit("CREATESELECT %d %d %d %s.%s", $2, $4, 0, $5, $7); 
        char* buffer = malloc(sizeof(char) * ( strlen($5) + strlen($7) + 4));
        strcpy(buffer, $5);
        strcat(buffer, ".");
        strcat(buffer, $7);
        addref(yylineno, curfilename, buffer, SYMTAB_DEFINE | SYMTAB_TABLE);
        free($5); free($7); free(buffer);};

opt_temporary: %empty { $$ = 0; } | TEMPORARY { $$ = 1; };

create_col_list: create_definition          { $$ = 1;       }
    | create_col_list ',' create_definition { $$ = $1 + 1;  };

create_definition:   
    PRIMARY KEY '(' column_list ')'         {   emit("PRIKEY %d", $4);      }
|   KEY '(' column_list ')'                 {   emit("KEY %d", $3);         }
|   INDEX '(' column_list ')'               {   emit("KEY %d", $3);         }
|   FULLTEXT KEY '(' column_list ')'        {   emit("TEXTINDEX %d", $4);   }
|   FULLTEXT INDEX '(' column_list ')'      {   emit("TEXTINDEX %d", $4);   }
|   {   emit("STARTCOL");   } NAME data_type column_atts { emit("COLUMNDEF %d %s", $3, $2); 
        addref(yylineno, curfilename, $2, SYMTAB_DEFINE | SYMTAB_COL); 
        free($2);};

column_atts:    %empty { $$ = 0; }
|   column_atts NOT NULLX      {    emit("ATTR NOTNULL"), $$ = $1 + 1;                  }
|   column_atts NULLX 
|   column_atts DEFAULT STRING {    emit("ATTR DEFAULT %s", $3); free($3); $$ = $1 + 1; }
|   column_atts DEFAULT INTNUM {    emit("ATTR DEFAULT NUMBER %d", $3);    $$ = $1 + 1; }
|   column_atts DEFAULT APPROXNUM { emit("ATTR DEFAULT FLOAT %f", $3);     $$ = $1 + 1; }
|   column_atts DEFAULT BOOL   {    emit("ATTR DEFAULT BOOL %d", $3);      $$ = $1 + 1; }
|   column_atts AUTO_INCREMENT {    emit("ATTR AUTOINC");                  $$ = $1 + 1; }
|   column_atts UNIQUE '(' column_list ')' {emit("ATTR UNIQUEKEY %d", $4); $$ = $1 + 1; }
|   column_atts UNIQUE KEY     {    emit("ATTR UNIQUEKEY");                $$ = $1 + 1; }   
|   column_atts PRIMARY KEY    {    emit("ATTR PRIKEY");                   $$ = $1 + 1; }   
|   column_atts KEY            {    emit("ATTR PRIKEY");                   $$ = $1 + 1; }
|   column_atts COMMENT STRING {    emit("ATTR COMMENT %s", $3); free($3); $$ = $1 + 1; };

opt_length: %empty { $$ = 0; }
    |   '(' INTNUM ')' { $$ = $2; }
    |   '(' INTNUM ',' INTNUM ')' { $$ = $2 + 1000*$4;  };

opt_binary: %empty { $$ = 0; } | BINARY { $$ = 4000; };

opt_uz: %empty { $$ = 0; }
    |   opt_uz UNSIGNED { $$ = $1 | 1000; }
    |   opt_uz ZEROFILL { $$ = $1 | 2000; };

opt_csc:    %empty
    |   opt_csc CHAR SET STRING { emit("COLCHARSET %s", $4); free($4); }
    |   opt_csc COLLATE STRING { emit("COLCOLLATE %s", $3); free($3); };

data_type:
    BIT opt_length { $$ = 10000 + $2;   }
|   TINYINT opt_length opt_uz { $$ = 10000 + $2;    }
|   SMALLINT opt_length opt_uz { $$ = 20000 + $2 + $3;  }
|   MEDIUMINT opt_length opt_uz { $$ = 30000 + $2 + $3; }
|   INT opt_length opt_uz { $$ = 40000 + $2 + $3;   }
|   INTEGER opt_length opt_uz { $$ = 50000 + $2 + $3; }
|   BIGINT opt_length opt_uz { $$ = 60000 + $2 + $3;    }
|   REAL opt_length opt_uz { $$ = 70000 + $2 + $3;  }
|   DOUBLE opt_length opt_uz { $$ = 80000 + $2 + $3;  }
|   FLOAT opt_length opt_uz { $$ = 90000 + $2 + $3;  }
|   DECIMAL opt_length opt_uz { $$ = 100000 + $2 + $3;  }
|   DATE { $$ = 100001; }
|   TIME { $$ = 100002; }
|   TIMESTAMP { $$ = 100003;}
|   DATETIME { $$ = 100004; }
|   YEAR    { $$ = 100005;  }
|   CHAR opt_length opt_csc { $$ = 120000 + $2;  }
|   VARCHAR '(' INTNUM ')' opt_csc { $$ = 130000 + $3;  }
|   BINARY opt_length { $$ = 140000 + $2;}
|   VARBINARY '(' INTNUM ')' { $$ = 150000 + $3;    }
|   TINYBLOB { $$ = 160001; }
|   BLOB { $$ = 160002; }
|   MEDIUMBLOB { $$ = 160003; }
|   LONGBLOB { $$ = 160004; }
|   TINYTEXT opt_binary opt_csc { $$ = 170000 + $2; }
|   TEXT opt_binary opt_csc { $$ = 170001 + $2; }
|   MEDIUMTEXT opt_binary opt_csc { $$ = 170002 + $2; }
|   LONGTEXT opt_binary opt_csc { $$ = 170003 + $2; }
|   ENUM '(' enum_list ')' opt_csc { $$ = 200000 + $3; }
|   SET '(' enum_list ')' opt_csc { $$ = 210000 + $3; };

enum_list:  STRING { emit("ENUMVAL %s", $1); free($1); $$ = 1; }
    |   enum_list ',' STRING { emit("ENUMVAL %s", $3); free($3); $$ = 1 + $1; };

create_select_stmt: opt_ignore_replace opt_as select_stmt { emit("CREATESELECT %d", $1); };

opt_ignore_replace: %empty { $$ = 0; }
    |   IGNORE { $$ = 1; }
    |   REPLACE { $$ = 2; };

set_stmt: SET set_list;

set_list: set_expr | set_list ',' set_expr;

set_expr: 
    USERVAR COMPARISON expr {
        if($2!=4) { yyerror("bad set to @%s", $1); YYERROR; }
        emit("SET %s", $1); 
        free($1);
    }
|   USERVAR ASSIGN expr {
        emit("SET %s", $1);
        free($1);
};

%%

void emit(char *s, ...)
{
    va_list ap;
    va_start(ap,s);
    printf("RPN: ");
    vfprintf(stdout,s,ap);
    printf("\n");
    va_end(ap);
}

void yyerror(const char *s, ...)
{
    va_list ap;
    va_start(ap,s);
    fprintf(stderr, "%d: error: ", yylineno);
    vfprintf(stderr,s,ap);
    fprintf(stderr,"\n");
    va_end(ap);
}