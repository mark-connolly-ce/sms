// Read https://raw.githubusercontent.com/reginaldford/sms/main/LICENSE.txt for license information

// all garbage collected objects start with this
typedef struct sm_object {
  short int my_type;
} sm_object;

sm_string   *sm_object_to_string(sm_object *obj1);
unsigned int sm_object_sprint(sm_object *obj1, char *buffer, bool fake);
int          sm_sizeof(sm_object *sm_obj);
bool         sm_object_is_literal(unsigned short int t);
void         sm_object_dbg_print(sm_object *obj);
bool         sm_object_eq(sm_object *result, sm_object *self);
