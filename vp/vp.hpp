#ifndef VP_HPP_
#define VP_HPP_

#include "software.hpp"
#include "dma.hpp"
#include "hardware.hpp"
#include "interconnect.hpp"

class Vp :  public sc_core::sc_module{
    
public:
    Vp(sc_core::sc_module_name name);
    ~Vp();
    sc_core::sc_event hwDone;

protected:
    Software software;
    Dma dma;
    Hardware hardware;
    Interconnect ic;
    sc_core::sc_fifo <unsigned char> fifoToDma; // fifo between dma and ip
    sc_core::sc_fifo <unsigned char> fifoToIP;  // fifo between dma and ip

};

#endif // VP_HPP_