%{
// Read https://raw.githubusercontent.com/reginaldford/sms/main/LICENSE.txt for license information

#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <math.h>
#include <string.h>
#include "../main/sms.h"

extern int yylex();
extern int yylineno;
void       yyerror(const char *msg);

FILE* _lex_file(char *fpath);
void _done_lexing_file(FILE* f);
void _lex_cstr(char * cstr,int len);

%}

%define parse.error verbose

%union {
  sm_double        *num;
  sm_symbol        *sym;
  sm_expr          *expr;
  sm_string        *str;
  sm_cx            *context;
  sm_meta          *meta;
  sm_fun           *fun;
  sm_expr          *param_list;
  sm_fun_param_obj *param;
};

%type <fun> FUN
%type <fun> FUN_INTRO
%type <expr> FUN_CALL
%type <expr> FUN_CALL_OPEN
%type <param_list> PARAM_LIST
%type <expr> PARAM_LIST_OPEN
%type <expr> IF_STATEMENT
%type <meta> META_EXPR
%type <expr> ASSIGNMENT
%type <expr> INDEX_ASSIGNMENT
%type <expr> DOT_ASSIGNMENT
%type <context> CONTEXT
%type <context> CONTEXT_LIST
%type <expr> EXPR
%type <expr> ARRAY
%type <expr> ARRAY_LIST
%type <expr> EQ
%type <expr> ASSOCIATION
%type <expr> TEST_LT
%type <expr> TEST_GT
%type <expr> TEST_LT_EQ
%type <expr> TEST_GT_EQ
%type <expr> BLOCK
%type <expr> OPEN_BLOCK
%type <expr> COMMAND

%token SELF
%token LS
%token CD
%token PWD
%token CLEAR

%token EXIT
%token HELP

%token IS
%token DOT
%token <num> NUM
%token <expr> PIPE
%token <expr> EQEQ
%token <expr> ASSOCIATE
%token <sym> SYM
%token <str> STRING
%token <expr> SIN
%token <expr> COS
%token <expr> TAN
%token <expr> ASIN
%token <expr> ACOS
%token <expr> ATAN
%token <expr> SINH
%token <expr> COSH
%token <expr> TANH
%token <expr> ASINH
%token <expr> ACOSH
%token <expr> ATANH
%token <expr> SECH
%token <expr> CSCH
%token <expr> COTH
%token <expr> ASECH
%token <expr> ACSCH
%token <expr> ACOTH
%token <expr> SEC
%token <expr> CSC
%token <expr> COT
%token <expr> ASEC
%token <expr> ACSC
%token <expr> ACOT
%token <expr> LN
%token <expr> LOG
%token <expr> EXP
%token <expr> SQRT
%token <expr> ABS

%token <expr> RM
%token <expr> LET

%token <expr> DIFF
%token <expr> SIMP
%token <expr> INT

%token IF
%token ELSE
%token <expr> WHILE
%token <expr> FOR
%token <expr> DO_WHILE
%token <expr> RETURN
%token <expr> PARENT
%token <expr> EVAL
%token <expr> CX_EVAL
%token <expr> EVAL_FAST
%token <expr> EVAL_FAST_IN_CX
%token <expr> FAILS
%token <expr> PARSE
%token <expr> RUNTIME_META

%token <expr> NEW_ARR
%token <expr> MAP
%token <expr> REDUCE
%token <expr> SIZE
%token <expr> ARR_PLUS
%token <expr> PART
%token <expr> ARR_TOCSV
%token <expr> ARR_REPEAT
%token <expr> ARR_CAT


%token <expr> STR_SIZE
%token <expr> STR_CAT
%token <expr> STR_GET
%token <expr> STR_SET
%token <expr> STR_MAP
%token <expr> STR_FIND
%token <expr> STR_FINDR
%token <expr> STR_SPLIT
%token <expr> STR_PART
%token <expr> STR_UNESCAPE
%token <expr> STR_ESCAPE
%token <expr> STR_SETCHAR
%token <expr> STR_GETCHAR
%token <expr> STR_TONUMS
%token <expr> STR_CMP
%token <expr> STR_REPEAT
%token <expr> STR_TOMEM
%token <expr> NEW_STR
%token <expr> TO_STR
%token <expr> TO_STRFMT

%token <expr> NEW_MEM
%token <expr> MEM_MAP
%token <expr> MEM_UNITE
%token <expr> MEM_PART
%token <expr> MEM_TONUMS
%token <expr> NUMS_TOMEM
%token <expr> MEM_TOFILE
%token <expr> MEM_PRINT
%token <expr> MEM_SET
%token <expr> MEM_GET
%token <expr> MEM_TOSTR
%token <expr> MEM_SIZE

%token <expr> PUT
%token <expr> PUTLN
%token <expr> INPUT

%token <expr> FILE_PARSE
%token <expr> FILE_READ
%token <expr> FILE_RUN
%token <expr> FILE_PART
%token <expr> FILE_WRITE
%token <expr> FILE_EXISTS
%token <expr> FILE_STAT
%token <expr> FILE_APPEND
%token <expr> FILE_TOMEM
%token <expr> FILE_CP
%token <expr> FILE_MV
%token <expr> FILE_RM
%token <expr> FILE_SIZE
%token <expr> CSV_TOFILE
%token <expr> CSV_TOARR
%token <expr> FILE_TOCSV

%token <expr> RANDOM
%token <expr> SEED
%token <expr> ROUND
%token <expr> FLOOR
%token <expr> CEIL
%token <expr> MOD
%token <expr> LT
%token <expr> GT
%token <expr> LT_EQ
%token <expr> GT_EQ
%token <expr> NOTEQ
%token <expr> NOT
%token <expr> OR
%token <expr> AND
%token <expr> XOR

%token <expr> NEW_CX
%token <expr> CX_DOT
%token <expr> CX_KEYS
%token <expr> CX_VALUES
%token <expr> CX_LET
%token <expr> CX_SET
%token <expr> CX_GET
%token <expr> CX_HAS
%token <expr> CX_GET_FAR
%token <expr> CX_HAS_FAR
%token <expr> CX_CLEAR
%token <expr> CX_IMPORT
%token <expr> CX_MAP
%token <expr> CX_REDUCE
%token <expr> CX_CONTAINING
%token <expr> CX_SIZE
%token <expr> CX_RM

%token <expr> NEW_FN
%token <fun>  ARROW
%token <expr> FN_XP
%token <expr> FN_SETXP
%token <expr> FN_PARAMS
%token <expr> FN_SETPARAMS
%token <expr> FN_PARENT
%token <expr> FN_SETPARENT

%token <expr> NEW_XP
%token <expr> XP_OP
%token <expr> XP_SETOP
%token <expr> XP_OPSTR

%token <expr> NUMS_TOSTR
%token <expr> NEW_NUMS

%token <expr> MALLOC_OBJ
%token <expr> FREE_OBJ
%token <expr> COPY
%token <expr> DEEP_COPY

%token <expr> SYM_NAME

%token <expr> MEM_SAVEFILE
%token <expr> MEM_READFILE
%token <expr> MEM_CHECKFILE

%token <expr> DATE_STR
%token <expr> DATE
%token <expr> TIME
%token <expr> SLEEP
%token <expr> EXEC
%token <expr> OS_GETENV
%token <expr> OS_SETENV
%token <expr> FORK
%token <expr> WAIT
%token <expr> ARGS
%token <expr> GETOPTIONS
%token <expr> SETOPTIONS
%token <expr> RESETOPTIONS
%token <expr> GC
%token <expr> THISPROCESS

%token DONE
%token ENDOFFILE

%nonassoc SYM
%nonassoc '<' '>' LT_EQ GT_EQ EQEQ IS
%left ':'
%left  '='
%nonassoc ','
%left IF WHILE FOR DOWHILE
%left OR AND NOT
%left DOT '+' '-'
%left '*' '/'
%left '^'
%left ';'

%%

COMMAND : EXPR ';' {
  sm_global_parser_output((sm_object *)($1));
  YYACCEPT;
}
| error     { YYABORT; return 4; }
| DONE      { YYACCEPT; }
| ENDOFFILE {
  sm_global_parser_output((sm_object*)sm_new_expr(SM_EXIT_EXPR,(sm_object*) sm_new_double(0)));  
 YYACCEPT;}

EXPR : SELF { $$ = (sm_expr*)sm_new_self(); }
| EXIT '(' EXPR ')' { $$ = sm_new_expr(SM_EXIT_EXPR,(sm_object*)$3); }
| LET SYM '=' EXPR { $$ = sm_new_expr_2(SM_LET_EXPR,(sm_object*)$2,(sm_object*)$4); }
| RM SYM {$$ = sm_new_expr(SM_RM_EXPR, (sm_object *)$2); }
| SYM{}
| SYM DOT SYM {$$ = sm_new_expr_2(SM_DOT_EXPR,(sm_object*)$1,(sm_object*)$3); }
| EXPR DOT SYM {$$ = sm_new_expr_2(SM_DOT_EXPR,(sm_object*)$1,(sm_object*)$3); }
| EXPR '+' EXPR { $$ = sm_new_expr_2(SM_PLUS_EXPR, (sm_object *)$1, (sm_object *)$3); }
| EXPR '-' EXPR { $$ = sm_new_expr_2(SM_MINUS_EXPR, (sm_object *)$1, (sm_object *)$3); }
| EXPR '*' EXPR { $$ = sm_new_expr_2(SM_TIMES_EXPR, (sm_object *)$1, (sm_object *)$3); }
| EXPR '/' EXPR { $$ = sm_new_expr_2(SM_DIVIDE_EXPR, (sm_object *)$1, (sm_object *)$3); }
| EXPR '^' EXPR { $$ = sm_new_expr_2(SM_POW_EXPR, (sm_object *)$1, (sm_object *)$3); }
| NUM{}
| '-' EXPR {
  if (((sm_object *)$2)->my_type == SM_DOUBLE_TYPE) {
    ((sm_double *)$2)->value *= -1;
    $$ = $2;
  } else {
    $$ = sm_new_expr_2(SM_TIMES_EXPR, (sm_object *)sm_new_double(-1), (sm_object *)$2);
  }
}
| '(' EXPR ')' { $$ = $2; }
| STRING{}
| SIN '(' EXPR ')' { $$ = sm_new_expr(SM_SIN_EXPR, (sm_object *)$3); }
| COS '(' EXPR ')' { $$ = sm_new_expr(SM_COS_EXPR, (sm_object *)$3); }
| TAN '(' EXPR ')' { $$ = sm_new_expr(SM_TAN_EXPR, (sm_object *)$3); }
| ASIN '(' EXPR ')' { $$ = sm_new_expr(SM_ASIN_EXPR, (sm_object *)$3); }
| ACOS '(' EXPR ')' { $$ = sm_new_expr(SM_ACOS_EXPR, (sm_object *)$3); }
| ATAN '(' EXPR ')' { $$ = sm_new_expr(SM_ATAN_EXPR, (sm_object *)$3); }
| SINH '(' EXPR ')' { $$ = sm_new_expr(SM_SINH_EXPR, (sm_object *)$3); }
| COSH '(' EXPR ')' { $$ = sm_new_expr(SM_COSH_EXPR, (sm_object *)$3); }
| TANH '(' EXPR ')' { $$ = sm_new_expr(SM_TANH_EXPR, (sm_object *)$3); }
| ASINH '(' EXPR ')' { $$ = sm_new_expr(SM_ASINH_EXPR, (sm_object *)$3); }
| ACOSH '(' EXPR ')' { $$ = sm_new_expr(SM_ACOSH_EXPR, (sm_object *)$3); }
| ATANH '(' EXPR ')' { $$ = sm_new_expr(SM_ATANH_EXPR, (sm_object *)$3); }
| SEC '(' EXPR ')' { $$ = sm_new_expr(SM_SEC_EXPR, (sm_object *)$3); }
| CSC '(' EXPR ')' { $$ = sm_new_expr(SM_CSC_EXPR, (sm_object *)$3); }
| COT '(' EXPR ')' { $$ = sm_new_expr(SM_COT_EXPR, (sm_object *)$3); }
| SECH '(' EXPR ')' { $$ = sm_new_expr(SM_SECH_EXPR, (sm_object *)$3); }
| CSCH '(' EXPR ')' { $$ = sm_new_expr(SM_CSCH_EXPR, (sm_object *)$3); }
| COTH '(' EXPR ')' { $$ = sm_new_expr(SM_COTH_EXPR, (sm_object *)$3); }
| LN '(' EXPR ')' { $$ = sm_new_expr(SM_LN_EXPR, (sm_object *)$3); }
| LOG '(' EXPR ',' EXPR ')' { $$ = sm_new_expr_2(SM_LOG_EXPR,(sm_object*)$3, (sm_object*)$5);}
| EXP '(' EXPR ')' { $$ = sm_new_expr(SM_EXP_EXPR, (sm_object *)$3); }
| SQRT '(' EXPR ')' { $$ = sm_new_expr(SM_SQRT_EXPR, (sm_object *)$3); }
| ABS '(' EXPR ')' { $$ = sm_new_expr(SM_ABS_EXPR, (sm_object *)$3); }
| DIFF '(' EXPR ',' EXPR ')' { $$ = sm_new_expr_2(SM_DIFF_EXPR, (sm_object *)$3, (sm_object *)$5); }
| SIMP '(' EXPR ')' { $$ = sm_new_expr(SM_SIMP_EXPR, (sm_object *)$3); }
| MAP '(' EXPR ',' EXPR ')' { $$ = sm_new_expr_2(SM_MAP_EXPR,(sm_object*)$3,(sm_object*)$5); }
| REDUCE '(' EXPR ',' EXPR ',' EXPR  ')' { $$ = sm_new_expr_3(SM_REDUCE_EXPR,(sm_object*)$3,(sm_object*)$5,(sm_object*)$7); }
| CONTEXT{}
| ARRAY{}
| META_EXPR{}
| ASSIGNMENT{}
| INDEX_ASSIGNMENT{}
| DOT_ASSIGNMENT{}
| FUN_CALL{}
| FUN{}
| IF_STATEMENT{}
| EQ{}
| EXPR IS EXPR { $$ = sm_new_expr_2(SM_IS_EXPR,(sm_object*)$1,(sm_object*)$3);}
| TEST_LT{}
| TEST_GT{}
| TEST_LT_EQ{}
| TEST_GT_EQ{}
| BLOCK {}
| EXPR '[' EXPR ']' {$$ = sm_new_expr_2(SM_INDEX_EXPR,(sm_object*)$1,(sm_object*)$3);}
| SYM '[' EXPR ']' {$$ = sm_new_expr_2(SM_INDEX_EXPR,(sm_object*)$1,(sm_object*)$3);}
| PARENT '(' EXPR ')' {$$ = sm_new_expr(SM_PARENT_EXPR,(sm_object*)$3);}
| SIZE '(' EXPR ')' {$$ = sm_new_expr(SM_SIZE_EXPR,(sm_object*)$3);}
| WHILE '(' EXPR ')' EXPR {$$ = sm_new_expr_2(SM_WHILE_EXPR,(sm_object*)$3,(sm_object*)$5);}
| FOR '(' EXPR ';' EXPR ';' EXPR ')' EXPR { $$ = sm_new_expr_4(SM_FOR_EXPR,(sm_object*)$3,(sm_object*)$5,(sm_object*)$7,(sm_object*)$9);}
| DO_WHILE '(' EXPR ')' EXPR {$$ = sm_new_expr_2(SM_DO_WHILE_EXPR,(sm_object*)$5,(sm_object*)$3);}
| RETURN EXPR {$$ = sm_new_expr(SM_RETURN_EXPR,(sm_object*)$2);}
| EVAL '(' EXPR ')' {$$ = sm_new_expr(SM_EVAL_EXPR,(sm_object*)$3);}
| CX_EVAL '(' EXPR ',' EXPR ')' {$$ = sm_new_expr_2(SM_CX_EVAL_EXPR,(sm_object*)$3,(sm_object*)$5);}
| EVAL_FAST '(' EXPR ')' {$$ = sm_new_expr(SM_EVAL_FAST_EXPR,(sm_object*)$3);}
| EVAL_FAST_IN_CX '(' EXPR ',' EXPR ')' {$$ = sm_new_expr_2(SM_EVAL_FAST_EXPR,(sm_object*)$3,(sm_object*)$5);}
| FAILS '(' EXPR ')' {$$ = sm_new_expr(SM_FAILS_EXPR,(sm_object*)$3);}
| PARSE '(' EXPR ')' {$$ = sm_new_expr(SM_PARSE_EXPR,(sm_object*)$3);}
| TO_STR '(' EXPR ')' {$$ = sm_new_expr(SM_TO_STRING_EXPR,(sm_object*)$3);}
| PUT '(' EXPR ')' {$$ = sm_new_expr(SM_PUT_EXPR,(sm_object*)$3);}
| PUTLN '(' EXPR ')' {$$ = sm_new_expr(SM_PUTLN_EXPR,(sm_object*)$3);}
| INPUT '(' ')' { $$ = sm_new_expr_n(SM_INPUT_EXPR,0,0);}
| CX_DOT '(' EXPR ',' EXPR ')' {$$=sm_new_expr_2(SM_CX_DOT_EXPR, (sm_object *)$3,(sm_object*)$5);}
| CX_CONTAINING '(' EXPR ',' EXPR ')' {$$=sm_new_expr_2(SM_CX_CONTAINING_EXPR, (sm_object *)$3,(sm_object*)$5);}
| CX_CLEAR '(' EXPR ')' {$$=sm_new_expr(SM_CX_CLEAR_EXPR, (sm_object *)$3);}
| CX_IMPORT '(' EXPR ',' EXPR ')' {$$=sm_new_expr_2(SM_CX_IMPORT_EXPR, (sm_object *)$3, (sm_object*) $5);}
| CX_LET '(' EXPR ',' EXPR ',' EXPR ')' { $$ = sm_new_expr_3(SM_CX_LET_EXPR,(sm_object*)$3,(sm_object*)$5, (sm_object*)$7);}
| CX_SET '(' EXPR ',' EXPR ',' EXPR ')' { $$ = sm_new_expr_3(SM_CX_SET_EXPR,(sm_object*)$3,(sm_object*)$5, (sm_object*)$7);}
| CX_GET '(' EXPR ',' EXPR ')' { $$ = sm_new_expr_2(SM_CX_GET_EXPR,(sm_object*)$3,(sm_object*)$5);}
| CX_HAS '(' EXPR ',' EXPR ')' { $$ = sm_new_expr_2(SM_CX_HAS_EXPR,(sm_object*)$3,(sm_object*)$5);}
| CX_GET_FAR '(' EXPR ',' EXPR ')' { $$ = sm_new_expr_2(SM_CX_GET_FAR_EXPR,(sm_object*)$3,(sm_object*)$5);}
| CX_HAS_FAR '(' EXPR ',' EXPR ')' { $$ = sm_new_expr_2(SM_CX_HAS_FAR_EXPR,(sm_object*)$3,(sm_object*)$5);}
| CX_RM '(' EXPR ',' EXPR ')' {$$ = sm_new_expr_2(SM_CX_RM_EXPR, (sm_object *)$3,(sm_object*)$5);}
| CX_SIZE '(' EXPR ')' {$$ = sm_new_expr(SM_CX_SIZE_EXPR, (sm_object *)$3);}
| CX_KEYS '(' EXPR ')' {$$ = sm_new_expr(SM_CX_KEYS_EXPR, (sm_object *)$3);}
| CX_VALUES '(' EXPR ')' {$$ = sm_new_expr(SM_CX_VALUES_EXPR, (sm_object *)$3);}
| FN_XP '(' EXPR ')' {$$ = sm_new_expr(SM_FN_XP_EXPR,(sm_object *)$3);}
| FN_SETXP '(' EXPR ',' EXPR ')' {$$ = sm_new_expr_2(SM_FN_SETXP_EXPR,(sm_object *)$3,(sm_object*)$5);}
| FN_PARAMS '(' EXPR ')' {$$ = sm_new_expr(SM_FN_PARAMS_EXPR,(sm_object *)$3);}
| FN_SETPARAMS '(' EXPR ','  EXPR ')' {$$ = sm_new_expr_2(SM_FN_SETPARAMS_EXPR,(sm_object *)$3,(sm_object*)$5);}
| FN_PARENT '(' EXPR ')' {$$ = sm_new_expr(SM_FN_PARENT_EXPR,(sm_object *)$3);}
| FN_SETPARENT '(' EXPR ','  EXPR ')' {$$ = sm_new_expr_2(SM_FN_SETPARENT_EXPR,(sm_object *)$3,(sm_object*)$5);}
| XP_OP '(' EXPR ')' {$$ = sm_new_expr(SM_XP_OP_EXPR,(sm_object*)$3);}
| XP_SETOP '(' EXPR ',' EXPR ')' {$$ = sm_new_expr_2(SM_XP_SET_OP_EXPR,(sm_object*)$3,(sm_object*)$5);}
| XP_OPSTR '(' EXPR ')' {$$ = sm_new_expr(SM_XP_OP_STR_EXPR,(sm_object*)$3);}

| FILE_PARSE '(' EXPR ')' {$$ = sm_new_expr(SM_FILE_PARSE_EXPR,(sm_object*)$3);}
| FILE_READ '(' EXPR ')' {$$ = sm_new_expr(SM_FILE_READ_EXPR,(sm_object*)$3);}
| FILE_RUN '(' EXPR ',' EXPR ')' {$$ = sm_new_expr_2(SM_FILE_READ_EXPR,(sm_object*)$3,(sm_object*)$5);}
| FILE_PART '(' EXPR ',' EXPR ',' EXPR ')' {$$ = sm_new_expr_3(SM_FILE_PART_EXPR,(sm_object*)$3,(sm_object*)$5,(sm_object*)$7);}
| FILE_WRITE '(' EXPR ',' EXPR ')' {$$ = sm_new_expr_2(SM_FILE_WRITE_EXPR,(sm_object*)$3,(sm_object*)$5);}
| FILE_APPEND '(' EXPR ',' EXPR ')' {$$ = sm_new_expr_2(SM_FILE_APPEND_EXPR,(sm_object*)$3,(sm_object*)$5);}
| FILE_EXISTS '(' EXPR ')' {$$ = sm_new_expr(SM_FILE_EXISTS_EXPR,(sm_object*)$3);}
| FILE_RM '(' EXPR ')' {$$ = sm_new_expr(SM_FILE_RM_EXPR,(sm_object*)$3);}
| FILE_STAT '(' EXPR ')' {$$ = sm_new_expr(SM_FILE_STAT_EXPR,(sm_object*)$3);}
| RANDOM  '(' ')' { $$ = sm_new_expr_n(SM_RANDOM_EXPR,0,0);}
| SEED  '(' EXPR ')' { $$ = sm_new_expr(SM_SEED_EXPR,(sm_object*)$3);}
| ROUND '(' EXPR ')' { $$ = sm_new_expr(SM_ROUND_EXPR,(sm_object*)$3);}
| CEIL '(' EXPR ')' { $$ = sm_new_expr(SM_CEIL_EXPR,(sm_object*)$3);}
| MOD '(' EXPR ',' EXPR ')' { $$ = sm_new_expr_2(SM_MOD_EXPR,(sm_object*)$3,(sm_object*)$5);}
| FLOOR '(' EXPR ')' { $$ = sm_new_expr(SM_FLOOR_EXPR,(sm_object*)$3);}
| NOT   '(' EXPR ')' { $$ = sm_new_expr(SM_NOT_EXPR,(sm_object*)$3);}
| EXPR OR EXPR   { $$ = sm_new_expr_2(SM_OR_EXPR,(sm_object*)$1,(sm_object*)$3);}
| EXPR AND EXPR   { $$ = sm_new_expr_2(SM_AND_EXPR,(sm_object*)$1,(sm_object*)$3);}
| STR_ESCAPE '(' EXPR ')' { $$ = sm_new_expr(SM_STR_ESCAPE_EXPR,(sm_object*)$3);}
| STR_SIZE '(' EXPR ')' {$$ = sm_new_expr(SM_STR_SIZE_EXPR,(sm_object*)$3);}
| STR_FIND '(' EXPR ',' EXPR ')' {$$ = sm_new_expr_2(SM_STR_FIND_EXPR,(sm_object*)$3,(sm_object*)$5);}
| STR_CAT '(' EXPR ',' EXPR ')' {$$ = sm_new_expr_2(SM_STR_CAT_EXPR,(sm_object*)$3,(sm_object*)$5);}
| EXPR STR_CAT EXPR {$$ = sm_new_expr_2(SM_STR_CAT_EXPR,(sm_object*)$1,(sm_object*)$3);}
| STR_SPLIT '(' EXPR ',' EXPR ')' {$$ = sm_new_expr_2(SM_STR_SPLIT_EXPR,(sm_object*)$3,(sm_object*)$5);}
| STR_PART '(' EXPR ',' EXPR ',' EXPR ')' {$$ = sm_new_expr_3(SM_STR_PART_EXPR,(sm_object*)$3,(sm_object*)$5,(sm_object*)$7);}
| DATE_STR '(' ')' { $$ = sm_new_expr_n(SM_DATE_STR_EXPR,0,0);}
| DATE '(' ')' { $$ = sm_new_expr_n(SM_DATE_EXPR,0,0);}
| TIME '(' ')' { $$ = sm_new_expr_n(SM_TIME_EXPR,0,0);}
| SLEEP '(' EXPR ')' { $$ = sm_new_expr(SM_SLEEP_EXPR,(sm_object*)$3);}
| EXEC '(' EXPR ')' { $$ = sm_new_expr(SM_EXEC_EXPR,(sm_object*)$3);}
| OS_GETENV '(' EXPR ')' { $$ = sm_new_expr(SM_OS_GETENV_EXPR,(sm_object*)$3);}
| OS_SETENV '(' EXPR ',' EXPR ')' { $$ = sm_new_expr_2(SM_OS_SETENV_EXPR,(sm_object*)$3,(sm_object*)$5);}
| FORK '(' ')' { $$ = sm_new_expr_n(SM_FORK_EXPR,0,0);}
| WAIT '(' ')' { $$ = sm_new_expr_n(SM_WAIT_EXPR,0,0);}
| LS '(' ')' { $$ = sm_new_expr_n(SM_LS_EXPR,0,0);}
| CD '(' EXPR ')' { $$ = sm_new_expr(SM_CD_EXPR,(sm_object*)$3);}
| PWD '(' ')' { $$ = sm_new_expr_n(SM_PWD_EXPR,0,0);}
| RUNTIME_META '(' EXPR ')' { $$ = sm_new_expr(SM_RUNTIME_META_EXPR, (sm_object*)$3);}
| GC '(' ')' { $$ = sm_new_expr_n(SM_GC_EXPR, 0,0); }

FUN : FUN_INTRO EXPR {
  //local variables are changed from symbol to local
  $1->content = (sm_object *)sm_localize((sm_object*)$2, $1);
  $$ = $1;
}

FUN_INTRO : PARAM_LIST ARROW {
  sm_cx * parent_cx = *(sm_global_lex_stack(NULL)->top);
  sm_fun *new_fun = sm_new_fun(parent_cx, ($1)->size, (sm_object *)NULL);
  for (unsigned int i = 0; i < ($1)->size; i++) {
    sm_fun_param_obj *po = (sm_fun_param_obj *)sm_expr_get_arg($1, i);
    sm_fun_set_param(new_fun, i, po->name, po->default_val, po->known_expr);
  }
  $$ = new_fun;
}
| SYM ARROW {
  sm_cx * parent_cx = *(sm_global_lex_stack(NULL)->top);
  sm_fun *new_fun = sm_new_fun(parent_cx,1, (sm_object *)NULL);
  sm_fun_set_param(new_fun, 0, $1->name, NULL, 0);
  $$ = new_fun;
}

PARAM_LIST : '(' ')' {
  $$ = sm_new_expr_n(SM_PARAM_LIST_EXPR, 0, 0);
}
| '(' SYM ')' {
  sm_fun_param_obj * fpo = sm_new_fun_param_obj($2->name,NULL,0);
  $$                = sm_new_expr(SM_PARAM_LIST_EXPR,(sm_object*)fpo);
}
| PARAM_LIST_OPEN ')' {}
| PARAM_LIST_OPEN SYM ')' {
  sm_fun_param_obj * new_param= sm_new_fun_param_obj($2->name,NULL,0);
  $$ = sm_expr_append($1, (sm_object *)new_param);
}

PARAM_LIST_OPEN : '(' SYM ',' {
  sm_expr *new_expr = sm_new_expr_n(SM_PARAM_LIST_EXPR, 1, 3);
  sm_fun_param_obj * new_param= sm_new_fun_param_obj($2->name,NULL,0);
  $$                = sm_expr_set_arg(new_expr, 0, (sm_object*)new_param);
}
| PARAM_LIST_OPEN SYM ',' {
  sm_fun_param_obj * new_param= sm_new_fun_param_obj($2->name,NULL,0);
  $$ = sm_expr_append($1, (sm_object *)new_param);
}

DOT_ASSIGNMENT : EXPR DOT SYM '=' EXPR { $$ = sm_new_expr_3(SM_ASSIGN_DOT_EXPR, (sm_object *)($1), (sm_object *)($3), (sm_object *)($5)); }
| SYM DOT SYM '=' EXPR { $$ = sm_new_expr_3(SM_ASSIGN_DOT_EXPR, (sm_object *)($1), (sm_object *)($3), (sm_object *)($5)); }
| EXPR '=' EXPR { $$ = sm_new_expr_2(SM_ASSIGN_DOT_EXPR, (sm_object *)($1), (sm_object *)($3)); }

ASSIGNMENT : SYM '=' EXPR { $$ = sm_new_expr_2(SM_ASSIGN_EXPR, (sm_object *)($1), (sm_object *)($3)); }

INDEX_ASSIGNMENT : EXPR '[' EXPR ']' '=' EXPR { $$ = sm_new_expr_3(SM_ASSIGN_INDEX_EXPR, (sm_object *)($1), (sm_object *)($3), (sm_object *)($6)); }
| SYM '[' EXPR ']' '=' EXPR { $$ = sm_new_expr_3(SM_ASSIGN_INDEX_EXPR, (sm_object *)($1), (sm_object *)($3), (sm_object *)($6)); }

BLOCK : OPEN_BLOCK '}' {
  sm_stack_pop(sm_global_lex_stack(NULL));
}
| OPEN_BLOCK ';' '}' {
  sm_stack_pop(sm_global_lex_stack(NULL));
}

OPEN_BLOCK : '{' EXPR {
  sm_cx * new_cx = sm_new_cx((sm_cx*)*sm_global_lex_stack(NULL)->top);
  sm_cx_contextualize((sm_object*)$2,new_cx);
  sm_global_lex_stack(sm_stack_push(sm_global_lex_stack(NULL), new_cx));
  $$ = sm_new_expr_2(SM_BLOCK_EXPR,(sm_object*)new_cx, (sm_object *)$2); 
}
| OPEN_BLOCK ';' EXPR {
  sm_cx_contextualize((sm_object*)$3,*sm_global_lex_stack(NULL)->top);
  $$ = sm_expr_append((sm_expr *)$1, (sm_object *)$3);
}

TEST_LT : '<' '(' EXPR ',' EXPR ')' {
  $$ = sm_new_expr_2(SM_LT_EXPR, (sm_object *)($3), (sm_object *)($5));
}
| EXPR '<' EXPR { $$ = sm_new_expr_2(SM_LT_EXPR, (sm_object *)($1), (sm_object *)($3)); }

TEST_GT : '>' '(' EXPR ',' EXPR ')' {
  $$ = sm_new_expr_2(SM_GT_EXPR, (sm_object *)($3), (sm_object *)($5));
}
| EXPR '>' EXPR { $$ = sm_new_expr_2(SM_GT_EXPR, (sm_object *)($1), (sm_object *)($3)); }

TEST_LT_EQ: LT_EQ '(' EXPR ',' EXPR ')' {
  $$ = sm_new_expr_2(SM_LT_EQ_EXPR, (sm_object *)($3), (sm_object *)($5));
}
| EXPR LT_EQ EXPR { $$ = sm_new_expr_2(SM_LT_EQ_EXPR,(sm_object*)$1,(sm_object*)$3);};

TEST_GT_EQ: GT_EQ '(' EXPR ',' EXPR ')' {
  $$ = sm_new_expr_2(SM_GT_EQ_EXPR, (sm_object *)($3), (sm_object *)($5));
}
| EXPR GT_EQ EXPR { $$ = sm_new_expr_2(SM_GT_EQ_EXPR,(sm_object*)$1,(sm_object*)$3);};

EQ : EQEQ '(' EXPR ',' EXPR ')' {
  $$ = sm_new_expr_2(SM_EQEQ_EXPR, (sm_object *)($3), (sm_object *)($5));
}
| EXPR EQEQ EXPR { $$ = sm_new_expr_2(SM_EQEQ_EXPR, (sm_object *)($1), (sm_object *)($3)); }

IF_STATEMENT : IF '(' EXPR ')' EXPR  {
  $$ = sm_new_expr_2(SM_IF_EXPR, (sm_object *)($3), (sm_object *)($5));
}
| IF '(' EXPR ')' EXPR ELSE EXPR {
  $$ = sm_new_expr_3(SM_IF_ELSE_EXPR, (sm_object *)($3), (sm_object *)($5), (sm_object *)($7));
}

FUN_CALL : FUN_CALL_OPEN ')' {}
| EXPR '(' ')'{
  // store the function in the fun_call here
  // index: 0   1
  // value: expr args
  sm_expr * args= sm_new_expr_n(SM_PARAM_LIST_EXPR,0,0);
  $$ = sm_new_expr_2(SM_FUN_CALL_EXPR, (sm_object *)$1, (sm_object *)args);
}

FUN_CALL_OPEN : EXPR '(' EXPR {
  // store the function in the fun_call here
  // index: 0   1
  // value: expr args
  sm_expr * args= sm_new_expr_n(SM_PARAM_LIST_EXPR,1,2);
  args=sm_expr_set_arg(args,0,(sm_object*)$3);
  $$ = sm_new_expr_2(SM_FUN_CALL_EXPR, (sm_object *)$1, (sm_object *)args);
}
| FUN_CALL_OPEN ',' EXPR {
  sm_expr * args = (sm_expr*)sm_expr_get_arg($1,1);
  args = sm_expr_append(args, (sm_object *)$3);
  $$=sm_expr_set_arg($1,1,(sm_object*)args);
}

META_EXPR : ':' EXPR { $$ = sm_new_meta((sm_object *)$2, *(sm_global_lex_stack(NULL))->top); }

ARRAY : ARRAY_LIST ']' {};
| ARRAY_LIST ',' ']' {};
| '[' EXPR ']' { $$ = (sm_expr *)sm_new_expr(SM_ARRAY_EXPR, (sm_object *)$2); }
| '[' ']' { $$ = sm_new_expr_n(SM_ARRAY_EXPR, 0, 0); }

ARRAY_LIST : '[' EXPR ',' EXPR { $$ = sm_new_expr_2(SM_ARRAY_EXPR, (sm_object *)$2, (sm_object *)$4); }
| ARRAY_LIST ',' EXPR { $$ = sm_expr_append($1, (sm_object *)$3); }

ASSOCIATION : EXPR ASSOCIATE EXPR { $$ = sm_new_expr_2(SM_ASSOCIATE_EXPR,(sm_object*)$1,(sm_object*)$3); }

CONTEXT : CONTEXT_LIST '}' {
  sm_stack_pop(sm_global_lex_stack(NULL));
}
| CONTEXT_LIST ';' '}' {
  sm_stack_pop(sm_global_lex_stack(NULL));
}
| '{' ASSOCIATION ';' '}' {
  sm_cx *parent_cx         = *(sm_global_lex_stack(NULL)->top);
  sm_cx *new_cx            = sm_new_cx(parent_cx);
  sm_string  *name              = ((sm_symbol *)sm_expr_get_arg($2, 0))->name;
  sm_object  *value             = (sm_object *)sm_expr_get_arg($2, 1);
  sm_cx_let(new_cx,&name->content,name->size,value);
  $$ = new_cx;
}
| '{' ASSOCIATION '}' {
  sm_cx *parent_cx         = *(sm_global_lex_stack(NULL)->top);
  sm_cx *new_cx            = sm_new_cx(parent_cx);
  sm_string  *name              = ((sm_symbol *)sm_expr_get_arg($2, 0))->name;
  sm_object  *value             = ((sm_object *)sm_expr_get_arg($2, 1));
  sm_cx_let(new_cx,&name->content,name->size,value);
  $$ = new_cx;
}
| '{' '}' {
  sm_cx *parent_cx = *(sm_global_lex_stack(NULL)->top);
  $$    = sm_new_cx(parent_cx);
}

CONTEXT_LIST : '{' ASSOCIATION ';' ASSOCIATION {
  sm_cx *parent_cx = *(sm_global_lex_stack(NULL)->top);
  sm_cx *new_cx    = sm_new_cx(parent_cx);
  sm_string        *name   = ((sm_symbol *)sm_expr_get_arg($2, 0))->name;
  sm_string        *name2  = ((sm_symbol *)sm_expr_get_arg($4, 0))->name;
  sm_object        *value  = (sm_object *)sm_expr_get_arg($2, 1);
  sm_object        *value2 = (sm_object *)sm_expr_get_arg($4, 1);
  sm_cx_contextualize(value,new_cx);
  sm_cx_contextualize(value2,new_cx);
  sm_cx_let(new_cx,&name->content,name->size,value);
  sm_cx_let(new_cx,&name2->content,name2->size,value2);
  sm_global_lex_stack(sm_stack_push(sm_global_lex_stack(NULL), new_cx));
  $$ = new_cx;
}
| CONTEXT_LIST ';' ASSOCIATION {
  sm_string  *name   = ((sm_symbol *)sm_expr_get_arg($3, 0))->name;
  sm_object  *value  = (sm_object *)sm_expr_get_arg($3, 1);
  sm_cx_let($1, &name->content,name->size, value);
  $$                 = $1;
}


%%


FILE* lex_file(char *fpath){
  if(access(fpath,F_OK)!=0){
    printf("File not found: %s\n",fpath);
    return false;
  }
  FILE * f = _lex_file(fpath);
  return f;
}

void done_lexing_file(FILE* f){
  _done_lexing_file(f);
}

void lex_cstr(char * cstr,int len){
  _lex_cstr(cstr,len);
}

void yyerror(const char *msg) {
  // Use this function to investigate the error.
  fprintf(stderr, "Error on line: %i %s\n",yylineno, msg);
  //Parsing a file will stop here, but repl will continue and needs a line increment
  yylineno++;
}
