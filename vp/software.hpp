#ifndef SOFTWARE_HPP_
#define SOFTWARE_HPP_

#include "typedefs.hpp"
#include "utils.hpp"
#include <assert.h>
#include <cstddef>
#include <cstdint>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
using namespace std;

#define RATE (1088 / 8)

class Software : public sc_core::sc_module {
public:
  Software(sc_core::sc_module_name name, sc_core::sc_event *hwDoneC);
  ~Software();

  tlm_utils::simple_initiator_socket<Software> icsoc; // interconnect socket
  tlm_utils::simple_target_socket<Software> dmasoc;   // dma socket
  sc_core::sc_event *hwDone;                          // model of an interrupt

protected:
  // 5.1.1
  uint64_t l;
  size_t k;
  char *msgPad;
  size_t len;
  // 5.2.1
  size_t N;
  // 6.2
  uint32_t v[8];
  uint32_t W[64];
  uint32_t *M;
  uint32_t T1, T2;

  uint32_t rotr(uint32_t, size_t);

  uint32_t shr(uint32_t, size_t);

  // swap byte endian
  uint32_t swapE32(uint32_t);
  uint64_t swapE64(uint64_t);
  void hexOutput(void *, size_t);
  void pad_and_parse(unsigned char *, size_t);

  int blockCount;         // number of blocks there will be/config for hw
  size_t inputLen;        // length of input = msgSize
  unsigned char *input;   // string for input from file
  unsigned char *hash;    // string for hashed input = char *msg [argv1]
  sc_dt::sc_uint<1> ctrl; // control/start bit for dma

  pl_t pl;                 // payload
  sc_core::sc_time offset; // offset
  // running the whole operation, waits for hwDone from the hardware and
  // compares the username hash with the database
  void app();
  void write_dma(sc_dt::uint64 addr, unsigned char *ptr = 0); // write in dma
  void write_hardware(sc_dt::uint64 addr); // write in hardware
  void b_transport(pl_t &pl, sc_core::sc_time &offset);
};

#endif // Software_HPP_
