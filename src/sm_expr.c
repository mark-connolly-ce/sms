// The following file is provided under the BSD 2-clause license. For more info, read LICENSE.txt.

#include "sms.h"

// New expression object with n arguments
// Make sure to fill in the arguments afterward
sm_expr *sm_new_expr_n(enum sm_expr_type op, unsigned int size, unsigned int capacity) {
  sm_expr *new_expr  = (sm_expr *)sm_malloc(sizeof(sm_expr) + sizeof(void *) * capacity);
  new_expr->my_type  = sm_expr_type;
  new_expr->op       = op;
  new_expr->size     = size;
  new_expr->capacity = capacity;
  return new_expr;
}

// New expression object
sm_expr *sm_new_expr(enum sm_expr_type op, sm_object *arg) {
  sm_expr *new_expr = sm_new_expr_n(op, 1, 1);
  return sm_set_expr_arg(new_expr, 0, arg);
}

// Append another object to this expression.
sm_expr *sm_append_to_expr(sm_expr *expr, sm_object *arg) {
  if (expr->size == expr->capacity) {
    unsigned int new_capacity = ((int)(expr->capacity * sm_global_growth_factor(0))) + 1;
    sm_expr     *new_expr     = sm_new_expr_n(expr->op, expr->size + 1, new_capacity);
    for (unsigned int i = 0; i < expr->size; i++) {
      sm_set_expr_arg(new_expr, i, sm_get_expr_arg(expr, i));
    }
    return sm_set_expr_arg(new_expr, new_expr->size - 1, arg);
  } else {
    expr->size += 1;
    return sm_set_expr_arg(expr, expr->size - 1, arg);
  }
}

// New expression with 2 arguments
sm_expr *sm_new_expr_2(enum sm_expr_type op, sm_object *arg1, sm_object *arg2) {
  sm_expr *new_expr = sm_new_expr_n(op, 2, 2);
  sm_set_expr_arg(new_expr, 0, arg1);
  return sm_set_expr_arg(new_expr, 1, arg2);
}

// New expression with 3 arguments
sm_expr *sm_new_expr_3(enum sm_expr_type op, sm_object *arg1, sm_object *arg2, sm_object *arg3) {
  sm_expr *new_expr = sm_new_expr_n(op, 2, 2);
  sm_set_expr_arg(new_expr, 0, arg1);
  sm_set_expr_arg(new_expr, 1, arg2);
  return sm_set_expr_arg(new_expr, 2, arg3);
}

// Set an argument of an expression
sm_expr *sm_set_expr_arg(sm_expr *expr, unsigned int index, sm_object *value) {
  sm_object **ptr_array = (sm_object **)&(expr[1]);
  ptr_array[index]      = value;
  return expr;
}

// Get an argument of an expression
sm_object *sm_get_expr_arg(sm_expr *expr, unsigned int index) {
  sm_object **ptr_array = (sm_object **)&(expr[1]);
  return ptr_array[index];
}

// Can this op take 2 arguments AND have infix representation?
bool sm_is_infix(enum sm_expr_type op) {
  switch (op) {
  case sm_plus:
  case sm_minus:
  case sm_times:
  case sm_divide:
  case sm_pow:
    return true;
  default:
    return false;
  }
}

// New string containing the contents of an expression without the bounding symbols
sm_string *sm_expr_contents_to_string(sm_expr *sme) {
  sm_string *result_str;
  if (sme->size > 0)
    result_str = sm_object_to_string(sm_get_expr_arg(sme, 0));
  else
    return sm_new_string(0, "");
  for (unsigned int arg_index = 1; arg_index < sme->size; arg_index++) {
    result_str         = sm_string_add_recycle(result_str, sm_new_string(1, ","));
    sm_string *obj_str = sm_object_to_string(sm_get_expr_arg(sme, arg_index));
    result_str         = sm_string_add_recycle(result_str, obj_str);
  }
  return result_str;
}

unsigned int sm_expr_contents_to_string_len(sm_expr *sme) {
  unsigned int sum;
  if (sme->size > 0)
    sum = sm_object_to_string_len(sm_get_expr_arg(sme, 0));
  else
    return 0;
  for (unsigned int arg_index = 1; arg_index < sme->size; arg_index++) {
    sum += 1; // comma
    sum += sm_object_to_string_len(sm_get_expr_arg(sme, arg_index));
  }
  return sum;
}

unsigned int sm_expr_contents_sprint(sm_expr *expr, char *buffer) {
  if (expr->size == 0)
    return 0;
  unsigned int buffer_pos = 0;
  for (unsigned int i = 0; i + 1 < expr->size; i++) {
    buffer_pos += sm_object_sprint(sm_get_expr_arg(expr, i), &(buffer[buffer_pos]));
    buffer[buffer_pos++] = ',';
  }
  buffer_pos += sm_object_sprint(sm_get_expr_arg(expr, expr->size - 1), &(buffer[buffer_pos]));
  return buffer_pos;
}

// New string containing array description
sm_string *sm_expr_array_to_string(sm_expr *expr) {
  if (expr->size == 0)
    return sm_new_string(2, "[]");
  sm_string *str_beginning = sm_new_string(1, "[");
  sm_string *str_contents  = sm_expr_contents_to_string(expr);
  sm_string *result_str    = sm_string_add_recycle_1st(str_beginning, str_contents);
  return sm_string_add_recycle(result_str, sm_new_string(1, "]"));
}


// Print to a cstring buffer the description of array
// Return the resulting length
unsigned int sm_expr_array_sprint(sm_expr *expr, char *buffer) {
  buffer[0] = '[';
  if (expr->size == 0) {
    buffer[1] = ']';
    return 2;
  }
  int len         = sm_expr_contents_sprint(expr, &(buffer[1]));
  buffer[1 + len] = ']';
  return 2 + len;
}


// New string containing prefix description
sm_string *sm_prefix_to_string(sm_expr *expr, sm_string *op) {
  if (expr->size == 0)
    return sm_string_add_recycle(op, sm_new_string(2, "()"));
  sm_string *str_beginning = sm_string_add_recycle(op, sm_new_string(1, "("));
  sm_string *str_contents  = sm_expr_contents_to_string(expr);
  sm_string *result_str    = sm_string_add(str_beginning, str_contents);
  return sm_string_add_recycle_2nd(result_str, sm_new_string(1, ")"));
}

// Print description of prefix expression to buffer
unsigned int sm_prefix_sprint(sm_expr *expr, char *buffer) {
  if (expr->size == 0) {
    buffer[0] = '[';
    buffer[1] = ']';
    return 2;
  }
  sm_strncpy(buffer, sm_global_fn_name(expr->op), sm_global_fn_name_len(expr->op));
  unsigned int cursor = sm_global_fn_name_len(expr->op);
  buffer[cursor++]    = '(';
  cursor += sm_expr_contents_sprint(expr, &(buffer[cursor]));
  buffer[cursor++] = ')';
  return cursor;
}

// Return length of string from sm_prefix_to_string
unsigned int sm_prefix_to_string_len(sm_expr *expr, unsigned int op_length) {
  if (expr->size == 0)
    return op_length + 2;                                      // f();
  return 2 + op_length + sm_expr_contents_to_string_len(expr); // f(x,y,z);
}

// Useful for making decisions about parenthesis
unsigned short int op_level(enum sm_expr_type op_type) {
  switch (op_type) {
  case sm_plus:
  case sm_minus:
    return 1;
  case sm_times:
  case sm_divide:
    return 2;
  case sm_pow:
  case sm_exp:
  case sm_ln:
    return 3;
  default:
    return 4;
  }
}

// New String containing infix description
// If there are more than 2 arguments, defaults to prefix
// Adding an arg to 1 + 1 leads to +( 1, 1, x )
sm_string *sm_infix_to_string(sm_expr *expr, sm_string *op) {
  if (expr->size > 2)
    return sm_prefix_to_string(expr, op);

  sm_object *o1 = sm_get_expr_arg(expr, 0);
  sm_object *o2 = sm_get_expr_arg(expr, 1);

  sm_string *left_string  = sm_object_to_string(o1);
  sm_string *right_string = sm_object_to_string(o2);

  int mid_op_level   = op_level(expr->op);
  int left_op_level  = o1->my_type == sm_expr_type ? op_level(((sm_expr *)o1)->op) : 5;
  int right_op_level = o2->my_type == sm_expr_type ? op_level(((sm_expr *)o1)->op) : 5;

  if (left_op_level <= 2 && right_op_level <= 2 && left_op_level != mid_op_level) {
    sm_string *str = sm_string_add_recycle(sm_new_string(1, "("), left_string);
    str            = sm_string_add_recycle(str, sm_new_string(1, ")"));
    str            = sm_string_add_recycle(str, op);
    str            = sm_string_add_recycle(str, sm_new_string(1, "("));
    str            = sm_string_add_recycle(str, right_string);
    return sm_string_add_recycle(str, sm_new_string(1, ")"));
  } else if (left_op_level <= 2 && left_op_level != mid_op_level) {
    sm_string *str = sm_string_add_recycle(sm_new_string(1, "("), left_string);
    str            = sm_string_add_recycle(str, sm_new_string(1, ")"));
    str            = sm_string_add_recycle(str, op);
    return sm_string_add_recycle(str, right_string);
  } else if (right_op_level <= 2 && right_op_level != mid_op_level) {
    sm_string *str = sm_string_add_recycle(left_string, op);
    str            = sm_string_add_recycle(str, sm_new_string(1, "("));
    str            = sm_string_add_recycle(str, right_string);
    return sm_string_add_recycle(str, sm_new_string(1, ")"));
  } else {
    sm_string *left_and_op = sm_string_add_recycle(left_string, op);
    return sm_string_add_recycle(left_and_op, right_string);
  }
}

unsigned int sm_infix_sprint(sm_expr *expr, char *buffer) {
  if (expr->size > 2) {
    return sm_prefix_sprint(expr, buffer);
  }

  sm_object *o1 = sm_get_expr_arg(expr, 0);
  sm_object *o2 = sm_get_expr_arg(expr, 1);

  int mid_op_level   = op_level(expr->op);
  int left_op_level  = o1->my_type == sm_expr_type ? op_level(((sm_expr *)o1)->op) : 5;
  int right_op_level = o2->my_type == sm_expr_type ? op_level(((sm_expr *)o1)->op) : 5;

  if (left_op_level <= 2 && right_op_level <= 2 && left_op_level != mid_op_level) {
    //(left)op(right)
    buffer[0]        = '(';
    int cursor       = sm_object_sprint(o1, &(buffer[1]));
    buffer[cursor++] = ')';
    sm_strncpy(&(buffer[cursor]), sm_global_fn_name(expr->op), sm_global_fn_name_len(expr->op));
    cursor += sm_global_fn_name_len(expr->op);
    buffer[cursor++] = '(';
    cursor += sm_object_sprint(o2, &(buffer[cursor]));
    buffer[cursor++] = ')';
    return cursor;
  } else if (left_op_level <= 2 && left_op_level != mid_op_level) {
    //(left)op right
    buffer[0]        = '(';
    int cursor       = sm_object_sprint(o1, &(buffer[1]));
    buffer[cursor++] = ')';
    sm_strncpy(&(buffer[cursor]), sm_global_fn_name(expr->op), sm_global_fn_name_len(expr->op));
    cursor += sm_object_sprint(o2, &(buffer[cursor]));
    return cursor;
  } else if (right_op_level <= 2 && right_op_level != mid_op_level) {
    // left op(right)
    int cursor = sm_object_sprint(o1, buffer);
    sm_strncpy(&(buffer[cursor]), sm_global_fn_name(expr->op), sm_global_fn_name_len(expr->op));
    cursor += sm_global_fn_name_len(expr->op);
    buffer[cursor++] = '(';
    cursor += sm_object_sprint(o2, &(buffer[cursor]));
    buffer[cursor++] = ')';
    return cursor;
  } else {
    // left op right
    int cursor = sm_object_sprint(o1, buffer);
    sm_strncpy(&(buffer[cursor]), sm_global_fn_name(expr->op), sm_global_fn_name_len(expr->op));
    cursor += sm_global_fn_name_len(expr->op);
    cursor += sm_object_sprint(o2, &(buffer[cursor]));
    return cursor;
  }
}


// Return the length of string from sm_infix_to_string
unsigned int sm_infix_to_string_len(sm_expr *expr, unsigned int op_len) {
  if (expr->size > 2)
    return sm_prefix_to_string_len(expr, op_len);

  sm_object *o1 = sm_get_expr_arg(expr, 0);
  sm_object *o2 = sm_get_expr_arg(expr, 1);

  unsigned int left_arg_len  = sm_object_to_string_len(sm_get_expr_arg(expr, 0));
  unsigned int right_arg_len = sm_object_to_string_len(sm_get_expr_arg(expr, 1));

  int mid_op_level   = op_level(expr->op);
  int left_op_level  = o1->my_type == sm_expr_type ? op_level(((sm_expr *)o1)->op) : 5;
  int right_op_level = o2->my_type == sm_expr_type ? op_level(((sm_expr *)o1)->op) : 5;

  if (left_op_level <= 2 && right_op_level <= 2 && left_op_level != mid_op_level) {
    //(left)op(right)
    return 4 + left_arg_len + right_arg_len + op_len;
  } else if (left_op_level <= 2 && left_op_level != mid_op_level) {
    //(left)op right
    return 2 + left_arg_len + op_len + right_arg_len;
  } else if (right_op_level <= 2 && right_op_level != mid_op_level) {
    // left op(right)
    return 2 + left_arg_len + op_len + right_arg_len;
  } else {
    return left_arg_len + op_len + right_arg_len;
  }
}


// New string describing this expression
sm_string *sm_expr_to_string(sm_expr *expr) {
  if (expr->op == sm_array) {
    return sm_expr_array_to_string(expr);
  } else {
    if (expr->op < sm_global_num_fns()) {
      sm_string *op_string =
        sm_new_string(sm_global_fn_name_len(expr->op), sm_global_fn_name(expr->op));
      if (sm_is_infix(expr->op))
        return sm_infix_to_string(expr, op_string);
      else
        return sm_prefix_to_string(expr, op_string);
    } else {
      return sm_new_string(17, "unrecognized expr");
    }
  }
}

unsigned int sm_expr_to_string_len(sm_expr *expr) {
  if (expr->op == sm_array) {
    return 2 + sm_expr_contents_to_string_len(expr);
  } else {
    if (expr->op < sm_global_num_fns()) {
      if (sm_is_infix(expr->op))
        return sm_infix_to_string_len(expr, sm_global_fn_name_len(expr->op));
      else
        return sm_prefix_to_string_len(expr, sm_global_fn_name_len(expr->op));
    } else {
      return 17; //"unrecognized expr"
    }
  }
}

// Adds a c string describing the expr to the buffer
// Returns the length
unsigned int sm_expr_sprint(sm_expr *expr, char *buffer) {
  if (expr->op == sm_array) {
    return sm_expr_array_sprint(expr, buffer);
  } else {
    if (expr->op < sm_global_num_fns()) {
      if (sm_is_infix(expr->op))
        return sm_infix_sprint(expr, buffer);
      else
        return sm_prefix_sprint(expr, buffer);
    } else {
      sm_strncpy(buffer, "unrecognized expr", 17);
      return 17;
    }
  }
}

// Remove and return the object with the highest index
sm_object *sm_expr_pop(sm_expr *sme) {
  if (sme->size > 0) {
    sme->size--;
    return sm_get_expr_arg(sme, sme->size);
  } else {
    printf("Stack underflow.");
    return NULL;
  }
}

// Remove and return the object with the highest index,
// then, place a space object in the remaining space
sm_object *sm_expr_pop_recycle(sm_expr *sme) {
  if (sme->size > 0) {
    sme->size--;
    sme->capacity     = sme->size;
    sm_object *answer = sm_get_expr_arg(sme, sme->size);
    sm_new_space_after(sme, sizeof(sm_object *));
    return answer;
  } else {
    printf("Stack underflow.");
    return NULL;
  }
}