#ifndef HARDWARE_HPP_
#define HARDWARE_HPP_

#include "typedefs.hpp"
#include "utils.hpp"
#include <cstdint>

class Hardware : public sc_core::sc_module {
  SC_HAS_PROCESS(Hardware);

public:
  Hardware(sc_core::sc_module_name name, sc_core::sc_event *hwDoneC);
  ~Hardware();

  tlm_utils::simple_target_socket<Hardware> icsoc; // interconnect socket

  sc_core::sc_fifo_out<unsigned char> fifoToDma;
  sc_core::sc_fifo_in<unsigned char> fifoToIP;
  sc_core::sc_event *hwDone; // event for modelling the interrupt in the system

protected:
  pl_t pl;
  sc_core::sc_time offset;
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

  // 4.1.2
  uint32_t Ch(uint32_t, uint32_t, uint32_t);
  uint32_t rotr(uint32_t, size_t);
  uint32_t shr(uint32_t, size_t);

  uint32_t Maj(uint32_t, uint32_t, uint32_t);

  uint32_t ep0(uint32_t);
  uint32_t ep1(uint32_t);
  uint32_t sig0(uint32_t);
  uint32_t sig1(uint32_t);
  uint32_t T1, T2;
  uint32_t swapE32(uint32_t);

  unsigned char *intBuff; // internal buffer for storing the input
  int blockCount; // configuration register that indicates how many blocks there
                  // will be
  int inputPos = 0; // indicator of how much input has been hashed
  unsigned char
      *hex;    // internal buffer for storing the output for sending to dma
  void hash(); // function to be accelerated
  void printHash();
  void hexOut(void *, size_t);
  // checks if dma has sent the input
  void fifoCheck();
  void b_transport(pl_t &pl, sc_core::sc_time &offset);
};
#endif
