#include "optimize.h"

VALUE rb_mOptimize;
VALUE rb_mLbfgsb;

static VALUE lbfgsb_fmin(VALUE self, VALUE fnc, VALUE x_val, VALUE jcb, VALUE args, VALUE l_val, VALUE u_val,
                         VALUE nbd_val, VALUE maxcor, VALUE ftol, VALUE gtol, VALUE maxiter, VALUE disp) {
  F77_int n_iter;
  F77_int n_fev;
  F77_int n_jev;
#ifdef USE_INT64
  F77_int max_iter = NUM2LONG(maxiter);
#else
  F77_int max_iter = NUM2INT(maxiter);
#endif
  narray_t* x_nary;
  narray_t* l_nary;
  narray_t* u_nary;
  narray_t* nbd_nary;
  F77_int n;
#ifdef USE_INT64
  F77_int m = NUM2LONG(maxcor);
#else
  F77_int m = NUM2INT(maxcor);
#endif
  double* x_ptr;
  double* l_ptr;
  double* u_ptr;
  F77_int* nbd_ptr;
  double f;
  double* g;
  double factr = NUM2DBL(ftol);
  double pgtol = NUM2DBL(gtol);
  double* wa;
  F77_int* iwa;
  char task[60];
#ifdef USE_INT64
  F77_int iprint = NIL_P(disp) ? -1 : NUM2LONG(disp);
#else
  F77_int iprint = NIL_P(disp) ? -1 : NUM2INT(disp);
#endif
  char csave[60];
  F77_int lsave[4];
  F77_int isave[44];
  double dsave[29];
  VALUE g_val;
  VALUE fg_arr;
  VALUE ret;

  GetNArray(x_val, x_nary);
  if (NA_NDIM(x_nary) != 1) {
    rb_raise(rb_eArgError, "x must be a 1-D array.");
    return Qnil;
  }
  n = (F77_int)NA_SIZE(x_nary);
  if (CLASS_OF(x_val) != numo_cDFloat) {
    x_val = rb_funcall(numo_cDFloat, rb_intern("cast"), 1, x_val);
  }
  if (!RTEST(nary_check_contiguous(x_val))) {
    x_val = nary_dup(x_val);
  }

  GetNArray(l_val, l_nary);
  if (NA_NDIM(l_nary) != 1) {
    rb_raise(rb_eArgError, "l must be a 1-D array.");
    return Qnil;
  }
  if ((F77_int)NA_SIZE(l_nary) != n) {
    rb_raise(rb_eArgError, "The size of l must be equal to that of x.");
    return Qnil;
  }
  if (CLASS_OF(l_val) != numo_cDFloat) {
    l_val = rb_funcall(numo_cDFloat, rb_intern("cast"), 1, l_val);
  }
  if (!RTEST(nary_check_contiguous(l_val))) {
    l_val = nary_dup(l_val);
  }

  GetNArray(u_val, u_nary);
  if (NA_NDIM(u_nary) != 1) {
    rb_raise(rb_eArgError, "u must be a 1-D array.");
    return Qnil;
  }
  if ((F77_int)NA_SIZE(u_nary) != n) {
    rb_raise(rb_eArgError, "The size of u must be equal to that of x.");
    return Qnil;
  }
  if (CLASS_OF(u_val) != numo_cDFloat) {
    u_val = rb_funcall(numo_cDFloat, rb_intern("cast"), 1, u_val);
  }
  if (!RTEST(nary_check_contiguous(u_val))) {
    u_val = nary_dup(u_val);
  }

  GetNArray(nbd_val, nbd_nary);
  if (NA_NDIM(nbd_nary) != 1) {
    rb_raise(rb_eArgError, "nbd must be a 1-D array.");
    return Qnil;
  }
  if ((F77_int)NA_SIZE(nbd_nary) != n) {
    rb_raise(rb_eArgError, "The size of nbd must be equal to that of x.");
    return Qnil;
  }
#ifdef USE_INT64
  if (CLASS_OF(nbd_val) != numo_cInt64) {
    nbd_val = rb_funcall(numo_cInt64, rb_intern("cast"), 1, nbd_val);
  }
#else
  if (CLASS_OF(nbd_val) != numo_cInt32) {
    nbd_val = rb_funcall(numo_cInt32, rb_intern("cast"), 1, nbd_val);
  }
#endif
  if (!RTEST(nary_check_contiguous(nbd_val))) {
    nbd_val = nary_dup(nbd_val);
  }

  x_ptr = (double*)na_get_pointer_for_read_write(x_val);
  l_ptr = (double*)na_get_pointer_for_read(l_val);
  u_ptr = (double*)na_get_pointer_for_read(u_val);
  nbd_ptr = (F77_int*)na_get_pointer_for_read(nbd_val);
  g = ALLOC_N(double, n);
  wa = ALLOC_N(double, (2 * m + 5) * n + 12 * m * m + 12 * m);
  iwa = ALLOC_N(F77_int, 3 * n);

  g_val = Qnil;
  f = 0.0;
  memset(g, 0, n * sizeof(*g));
  strcpy(task, "START");
  n_fev = 0;
  n_jev = 0;

  for (n_iter = 0; n_iter < max_iter;) {
    setulb_(&n, &m, x_ptr, l_ptr, u_ptr, nbd_ptr, &f, g, &factr, &pgtol, wa, iwa, task, &iprint, csave, lsave, isave, dsave);
    if (strncmp(task, "FG", 2) == 0) {
      if (RB_TYPE_P(jcb, T_TRUE)) {
        fg_arr = rb_funcall(self, rb_intern("fnc"), 3, fnc, x_val, args);
        f = NUM2DBL(rb_ary_entry(fg_arr, 0));
        g_val = rb_ary_entry(fg_arr, 1);
      } else {
        f = NUM2DBL(rb_funcall(self, rb_intern("fnc"), 3, fnc, x_val, args));
        g_val = rb_funcall(self, rb_intern("jcb"), 3, jcb, x_val, args);
      }
      n_fev++;
      n_jev++;
      if (CLASS_OF(g_val) != numo_cDFloat)
        g_val = rb_funcall(numo_cDFloat, rb_intern("cast"), 1, g_val);
      if (!RTEST(nary_check_contiguous(g_val)))
        g_val = nary_dup(g_val);
      memcpy(g, na_get_pointer_for_read(g_val), n * sizeof(*g));
      RB_GC_GUARD(g_val);
    } else if (strncmp(task, "NEW_X", 5) == 0) {
      n_iter++;
    } else {
      break;
    }
  }

  xfree(g);
  xfree(wa);
  xfree(iwa);

  ret = rb_hash_new();
  rb_hash_aset(ret, ID2SYM(rb_intern("task")), rb_str_new_cstr(task));
  rb_hash_aset(ret, ID2SYM(rb_intern("x")), x_val);
  rb_hash_aset(ret, ID2SYM(rb_intern("fnc")), DBL2NUM(f));
  rb_hash_aset(ret, ID2SYM(rb_intern("jcb")), g_val);
#ifdef USE_INT64
  rb_hash_aset(ret, ID2SYM(rb_intern("n_iter")), LONG2NUM(n_iter));
  rb_hash_aset(ret, ID2SYM(rb_intern("n_fev")), LONG2NUM(n_fev));
  rb_hash_aset(ret, ID2SYM(rb_intern("n_jev")), LONG2NUM(n_jev));
#else
  rb_hash_aset(ret, ID2SYM(rb_intern("n_iter")), INT2NUM(n_iter));
  rb_hash_aset(ret, ID2SYM(rb_intern("n_fev")), INT2NUM(n_fev));
  rb_hash_aset(ret, ID2SYM(rb_intern("n_jev")), INT2NUM(n_jev));
#endif
  rb_hash_aset(ret, ID2SYM(rb_intern("success")), strncmp(task, "CONV", 4) == 0 ? Qtrue : Qfalse);

  RB_GC_GUARD(x_val);
  RB_GC_GUARD(l_val);
  RB_GC_GUARD(u_val);
  RB_GC_GUARD(nbd_val);

  return ret;
}

RUBY_FUNC_EXPORTED void
Init_optimize(void) {
  rb_require("numo/narray");

  /**
   * Document-module: Numo::Optimize
   */
  rb_mOptimize = rb_define_module_under(rb_mNumo, "Optimize");
  /**
   * Document-module: Numo::Optimize::Lbfgsb
   */
  rb_mLbfgsb = rb_define_module_under(rb_mOptimize, "Lbfgsb");

#ifdef USE_INT64
  /* The bit size of fortran integer. */
  rb_define_const(rb_mLbfgsb, "SZ_F77_INTEGER", INT2NUM(64));
#else
  /* The bit size of fortran integer. */
  rb_define_const(rb_mLbfgsb, "SZ_F77_INTEGER", INT2NUM(32));
#endif
  /* The value of double epsilon used in the native extension. */
  rb_define_const(rb_mLbfgsb, "DBL_EPSILON", DBL2NUM(DBL_EPSILON));
  /**
   * Minimize a function using the L-BFGS-B algorithm.
   * This module function is for internal use. It is recommended to use `Numo::Optimize.minimize`.
   *
   * @overload fmin(fnc, x, jcb, args, l, u, nbd, maxcor, ftol, gtol, maxiter, disp)
   *   @param fnc [Method/Proc]
   *   @param x [Numo::DFloat]
   *   @param jcb [Method/Proc/boolean]
   *   @param args [Object]
   *   @param l [Numo::DFloat]
   *   @param u [Numo::DFloat]
   *   @param nbd [Numo::Int32/Numo::Int64]
   *   @param maxcor [Integer]
   *   @param ftol [Float]
   *   @param gtol [Float]
   *   @param maxiter [Integer]
   *   @param disp [Integer/nil]
   *   @return [Hash{Symbol => Object}]
   */
  rb_define_module_function(rb_mLbfgsb, "fmin", lbfgsb_fmin, 12);
}
