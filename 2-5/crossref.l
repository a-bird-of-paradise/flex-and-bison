%option header-file="lex.yy.h" yylineno noyywrap 8bit nodefault

UCN (\\u[0-9a-fA-F]{4})|(\\U[0-9a-fA-F]{8})
EXP ([Ee][-+]?[0-9]+)
ILEN    ([Uu](L|l|LL|ll)?|(L|l|LL|ll)[Uu]?)

%{
#include "buffuncs.h"
#include "symbol.h"
int defining;
%}

%x COMMENT IFILE

%%

"/*"    {   BEGIN COMMENT;  }

<COMMENT>"*/"    {   BEGIN INITIAL;  }
<COMMENT>([^*]|\n)+|.    

"//".*\n    

_Bool   |
_Complex    |
_Imaginary  |
auto    |
char    |
const   |
double  |
enum    |
extern  |
float   |
inline  |
int |
long    |
register    |
restrict    |
short   |
signed  |
static  |
struct  |
typedef |
union   |
unsigned    |
void    |
volatile    {   defining = 1;   }

break   
case    
continue    
default 
do  
else    
for 
goto    
if  
return  
sizeof  
switch  
while   

0[0-7]*{ILEN}?  
[1-9][0-9]*{ILEN}?  
0[Xx][0-9a-fA-F]+{ILEN}?    

([0-9]*\.[0-9]+|[0-9]+\.){EXP}?[flFL]?  
[0-9]+{EXP}[flFL]?  

0[Xx]([0-9a-fA-F]*\.[0-9a-fA-F]+|[0-9a-fA-F]+\.?)[Pp][-+]?[0-9]+[flFL]? 

\'([^'\\]|\\['"?\\abfnrtv]|\\[0-7]{1,3}|\\[Xx][0-9a-fA-F]+|{UCN})+\'    
L?\"([^"\\]|\\['"?\\abfnrtv]|\\[0-7]{1,3}|\\[Xx][0-9a-fA-F]+|{UCN})*\"  

"{"|"<%"|";"    {   defining = 0;   }
"["|"]"|"("|")"|"{"|"}"|"."|"->"        
"++"|"--"|"&"|"*"|"+"|"-"|"~"|"!"       
"/"|"%"|"<<"|">>"|"<"|">"|"<="|">="     
"=="|"!="|"^"|"|"|"&&"|"||"             
"?"|":"|";"|"..."                       
"="|"*="|"/="|"%="|"+="|"-="            
"<<="|">>="|"&="|"^="|"|="              
","|"#"|"##"|"<:"|":>"|"%>"|"%:"|"%:%:" 

[ \t\n]+    {   }
\\$       

([_a-zA-Z]|{UCN})([_a-zA-Z0-9]|{UCN})*  {   addref(yylineno, curfilename, yytext, defining);    }

"#"[ \t]*if.*\n   
"#"[ \t]*else.*\n 
"#"[ \t]*endif.*\n    
"#"[ \t]*define.*\n   
"#"[ \t]*pragma.*\n   
"#"[ \t]*line.*\n   

^"#"[ \t]*include[ \t]*[\"<] {   BEGIN IFILE;    }
<IFILE>[^>\"]+           {   
    {   
        int c;
        while((c=input()) && c != '\n');
    }
    newfile(yytext);
    BEGIN INITIAL;
}
<IFILE>.|\n                     { 
    fprintf(stderr, "%s:%d bad include line\n", curfilename, yylineno);
    BEGIN INITIAL;
}
<<EOF>> {   if(!popfile()) yyterminate();   }

.   {printf("%s:%d: Mystery character '%s'\n",  curfilename, yylineno, yytext); }

%%
