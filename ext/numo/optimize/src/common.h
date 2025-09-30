#ifndef NUMO_OPTIMIZE_COMMON_H_
#define NUMO_OPTIMIZE_COMMON_H_

#include <inttypes.h>
#include <math.h>
#include <stdint.h>

#ifdef USE_INT64
typedef int64_t F77_int;
#define PRIdF77INT PRId64
#else
typedef int32_t F77_int;
#define PRIdF77INT PRId32
#endif

#endif /* NUMO_OPTIMIZE_COMMON_H_ */
