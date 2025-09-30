#include "optimize.h"

VALUE rb_mOptimize;

RUBY_FUNC_EXPORTED void
Init_optimize(void) {
  rb_require("numo/narray");

  rb_mOptimize = rb_define_module_under(rb_mNumo, "Optimize");
}
