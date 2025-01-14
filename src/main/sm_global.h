// Read https://raw.githubusercontent.com/reginaldford/sms/main/LICENSE.txt for license information

#ifndef SMS_GLOBALS
#define SMS_GLOBALS

extern sm_heap   *sms_heap;
extern sm_heap   *sms_other_heap;
extern sm_symbol *sms_true;
extern sm_symbol *sms_false;

#endif /* SMS_GLOBALS */

int                sm_gc_count(int increase);
double             sm_global_growth_factor(double replacement);
sm_space_array    *sm_global_space_array(sm_space_array *replacement);
sm_expr           *sm_global_obj_stack(sm_expr *replacement);
char              *sm_global_fn_name(unsigned short int which);
unsigned int       sm_global_fn_name_len(unsigned short int which);
unsigned int       sm_global_num_fns();
sm_stack          *sm_global_lex_stack(sm_stack *replacement);
sm_expr           *sm_global_parents(sm_expr *replacement);
sm_object         *sm_global_parser_output(sm_object *replacement);
sm_env            *sm_global_environment(sm_env *replacement);
char              *sm_global_type_name(unsigned short int which);
unsigned short int sm_global_type_name_len(unsigned short int which);
struct termios    *sm_global_term_attrs();
