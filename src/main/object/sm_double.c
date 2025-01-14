// Read https://raw.githubusercontent.com/reginaldford/sms/main/LICENSE.txt for license information

#include "../sms.h"

sm_double *sm_new_double(double value) {
  struct sm_double *newnum = (sm_double *)sm_malloc(sizeof(sm_double));
  newnum->my_type          = SM_DOUBLE_TYPE;
  newnum->value            = value;
  return newnum;
}

// Return an sm_string describing this double
sm_string *sm_double_to_string(sm_double *self) {
  sm_string *new_str = sm_new_string(sm_double_sprint(self, NULL, true), "");
  sm_double_sprint(self, &(new_str->content), false);
  (&new_str->content)[new_str->size] = '\0';
  return new_str;
}

// Adds a c string describing the double to the buffer
// Returns the length
unsigned int sm_double_sprint(sm_double *self, char *buffer, bool fake) {
  char internal_buf[24];
  if (!fake)
    snprintf(buffer, 23, "%.16g", self->value);
  else {
    snprintf(internal_buf, 23, "%.16g", self->value);
    buffer = internal_buf;
  }
  unsigned short int count = 0;
  for (; count < 24 && buffer[count] != '\0'; count++)
    ;
  return count;
}
