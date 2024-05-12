#include "dma.hpp"
#include <cstdint>
#include <stdio.h>
#include <tlm>

using namespace std;
using namespace sc_core;
using namespace sc_dt;
using namespace tlm;

Dma::Dma(sc_core::sc_module_name name) : sc_module(name), icsoc("icsoc") {
  SC_REPORT_INFO("DMA", "Constructed.");
  icsoc.register_b_transport(this, &Dma::b_transport);

  SC_THREAD(send_to_fifo);
  dont_initialize();
  sensitive << fifoEv;
}

Dma::~Dma() {
  SC_REPORT_INFO("Dma", "Destructed."); // message
}

void Dma::b_transport(pl_t &pl, sc_core::sc_time &offset) {
  tlm_command cmd = pl.get_command();
  uint64 addr = pl.get_address();
  unsigned char *data = pl.get_data_ptr();
  unsigned int length = pl.get_data_length();

  switch (cmd) {
  case TLM_WRITE_COMMAND:
    switch (addr) {
    case DMA_INPUT_ADDR:
      iAddr = (uint32_t *)data;
      pl.set_response_status(TLM_OK_RESPONSE);
      break;

    case DMA_HASH_ADDR:
      hAddr = (uint32_t *)data;
      hAddr = new uint32_t[HEX_AMOUNT + 2];
      pl.set_response_status(TLM_OK_RESPONSE);
      break;

    case DMA_ILEN_ADDR:
      iLen = *(int *)data;
      cout << "DMA: iLen = " << iLen << endl;
      break;

    case DMA_CSR_ADDR:
      ctrl = *(sc_dt::sc_uint<1> *)data;

      // START
      if (ctrl == 1)
        fifoEv.notify();
      pl.set_response_status(TLM_OK_RESPONSE);
      break;

    default:
      pl.set_response_status(TLM_ADDRESS_ERROR_RESPONSE);
      SC_REPORT_ERROR("DMA", "WRITE ERROR");
      break;
    }
    break;

  default:
    pl.set_response_status(TLM_COMMAND_ERROR_RESPONSE);
    break;
  }
}

void Dma::send_to_fifo() {
  // AXI-FULL DDR TO DMA
  cout << "Send to fifo" << endl;
  // delay += sc_core::sc_time(
  //   floor(30 + iLen * 8 / BUS_WIDTH) * TIME_SHORTEST_PATH, sc_core::SC_NS);

  // send it to fifo
  printf("DMA write");
  for (size_t i = 0; i < iLen; i++) {
    fifoToIP->write(iAddr[i]);
  }
  cout << endl << "DMA: input read from DDR, sending to HW" << endl;

  // AXI-STREAM DMA TO HARDWARE
  // delay += sc_core::sc_time((30 + iLen * 8 / BUS_WIDTH) * TIME_SHORTEST_PATH,
  //                         sc_core::SC_NS);

  while (1) {
    if (fifoToDma.num_available()) {
      for (size_t i = 0; i < HEX_AMOUNT - 1; i++) {
        fifoToDma->read(hAddr[i]);
      }
      cout << "DMA: Read the hash, sending to DDR" << endl;
      // AXI-FULL DMA TO DDR
      // delay += sc_core::sc_time((OUTPUT_SIZE * 8 / BUS_WIDTH + 30) *
      //                            TIME_SHORTEST_PATH,
      //                      sc_core::SC_NS);

      // sending data to ddr
      pl.set_command(tlm::TLM_WRITE_COMMAND);
      pl.set_address(DMA_HASH_ADDR);
      pl.set_response_status(tlm::TLM_INCOMPLETE_RESPONSE);
      pl.set_data_ptr((unsigned char *)hAddr);
      pl.set_data_length(HEX_AMOUNT);

      swsoc->b_transport(pl, offset);

      return;
    }
    wait(sc_core::SC_ZERO_TIME);
  }
}
