#ifndef VP_HPP_
#define VP_HPP_

#include "dma.hpp"
#include "hardware.hpp"
#include "interconnect.hpp"
#include "software.hpp"
#include <cstdint>

class Vp : public sc_core::sc_module {

public:
  Vp(sc_core::sc_module_name name);
  ~Vp();
  sc_core::sc_event hwDone;

protected:
  Software software;
  Dma dma;
  Hardware hardware;
  Interconnect ic;
  sc_core::sc_fifo<uint32_t> fifoToDma; // fifo between dma and ip
  sc_core::sc_fifo<uint32_t> fifoToIP;  // fifo between dma and ip
};

#endif // VP_HPP_
