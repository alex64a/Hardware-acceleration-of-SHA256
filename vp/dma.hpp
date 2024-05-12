#ifndef DMA_HPP_
#define DMA_HPP_

#include "typedefs.hpp"
#include "utils.hpp"
#include <cstdint>

class Dma : public sc_core::sc_module {
  SC_HAS_PROCESS(Dma);

public:
  Dma(sc_core::sc_module_name name);
  ~Dma();

  tlm_utils::simple_target_socket<Dma> icsoc;    // interconnect socket
  tlm_utils::simple_initiator_socket<Dma> swsoc; // software socket

  sc_core::sc_fifo_in<uint32_t> fifoToDma; // fifo between dma and ip
  sc_core::sc_fifo_out<uint32_t> fifoToIP; // fifo between dma and ip

protected:
  uint32_t *hAddr, *iAddr;  // hash and input address pointers
  sc_dt::sc_uint<1> ctrl;   // control bit
  int iLen;                 // length of input from ddr
  sc_core::sc_event fifoEv; // event that starts the sending of data to ip when
                            // ctrl bit jumps to 1

  pl_t pl;                 // payload
  sc_core::sc_time offset; // time

  void
  send_to_fifo(); // started when fifoEv is triggered, send the data to hw/ip

  void b_transport(pl_t &pl, sc_core::sc_time &offset); // transport function
};
#endif // DMA_HPP_
