#ifndef NUMO_OPTIMIZE_LINPACK_H_
#define NUMO_OPTIMIZE_LINPACK_H_

#include "common.h"

extern void dpofa_(double* a, F77_int* lda, F77_int* n, F77_int* info);
extern void dtrsl_(double* t, F77_int* ldt, F77_int* n, double* b, F77_int* job, F77_int* info);

#endif /* NUMO_OPTIMIZE_LINPACK_H_ */
