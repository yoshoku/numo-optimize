#include "optimize.h"

VALUE rb_mOptimize;

RUBY_FUNC_EXPORTED void
Init_optimize(void) {
  rb_mOptimize = rb_define_module("Optimize");
}
