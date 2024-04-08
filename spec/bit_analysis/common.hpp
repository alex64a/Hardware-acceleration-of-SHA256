#ifndef COMMON_H
#define COMMON_H
#include <sysc/datatypes/int/sc_uint.h>
#define SC_INCLUDE_FX
#include <fstream>
#include <iostream>
#include <systemc>
#include <vector>
#define M_SIZE_def 32
#define N_SIZE_def 64
#define H_SIZE_def 32
typedef sc_dt::sc_uint<M_SIZE_def> M_SIZE;
typedef sc_dt::sc_uint<H_SIZE_def> H_SIZE;
typedef std::vector<H_SIZE> H_array;

typedef sc_dt::sc_uint<N_SIZE_def> N_SIZE;
typedef std::vector<M_SIZE> M_array;
#endif
