#include "../main/sms.h"
#include "macros.h"

// Since the sms_test system only checks that to_string(evaluated)==to_string(literal)
// Proving that literals print to what they should to verify expression printing mechanics.
int chapter_2(int test) {
  int num_fails = 0;
  sm_init(NULL);
  unsigned short int num_fns = sm_global_num_fns();
  for (unsigned short int i = 0; i < num_fns; i++) {
    char        *op_name   = sm_global_fn_name(i);
    sm_object   *test_obj1 = (sm_object *)sm_new_string(5, "Hello");
    sm_object   *test_obj2 = (sm_object *)sm_new_string(5, "World");
    unsigned int len       = sm_global_fn_name_len(i);
    sm_expr     *expr      = sm_new_expr_2(i, test_obj1, test_obj2);
    char        *to_str    = &(sm_object_to_string((sm_object *)expr)->content);
    printf("%i: expression: %s is %i characters long and prints as %s\n", i, op_name, len, to_str);
    if (strlen(sm_global_fn_name(i)) != len) {
      printf("string length mismatch: the counted length is %lu but the global setting is %i\n",
             strlen(sm_global_fn_name(i)), len);
      num_fails++;
    }
  }
  return num_fails;
}