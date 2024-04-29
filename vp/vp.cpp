#include "vp.hpp"

Vp::Vp(sc_core::sc_module_name name)
    : sc_module(name), software("SW", &hwDone), hardware("HW", &hwDone),
      ic("IC"), dma("DMA") {
  software.icsoc.bind(ic.swsoc);
  ic.hwsoc.bind(hardware.icsoc);
  ic.dmasoc.bind(dma.icsoc);
  dma.swsoc.bind(software.dmasoc);

  dma.fifoToDma(fifoToDma);
  dma.fifoToIP(fifoToIP);
  hardware.fifoToDma(fifoToDma);
  hardware.fifoToIP(fifoToIP);

  SC_REPORT_INFO("Virtual Platform", "Constructed."); // message
}

Vp::~Vp() {
  SC_REPORT_INFO("Virtual Platform", "Destructed."); // message
}
