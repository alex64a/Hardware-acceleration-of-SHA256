#ifndef UTILS_H
#define UTILS_H

#include "tlm.h"
#include "typedefs.hpp"
#include <bitset>
#include <cstdint>
#include <fstream>
#include <inttypes.h>
#include <iostream>
#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <string>
#include <systemc>
#include <tlm_utils/simple_initiator_socket.h>
#include <tlm_utils/simple_target_socket.h>

const extern uint32_t K[64];
extern uint32_t H[8];
size_t Read_from_file(const char *path, unsigned char **buff);
#endif
