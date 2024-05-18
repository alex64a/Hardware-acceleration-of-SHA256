#include "software.hpp"
#include "string.h"
#include "typedefs.hpp"
#include <stdio.h>
using namespace std;
using namespace tlm;
using namespace sc_core;
using namespace sc_dt;

SC_HAS_PROCESS(Software);

Software::Software(sc_core::sc_module_name name, sc_core::sc_event *hwDoneC)
    : sc_module(name), icsoc("icsoc"), dmasoc("dmasoc") {
  dmasoc.register_b_transport(this, &Software::b_transport);
  SC_REPORT_INFO("Software", "Constructed.");

  hwDone = hwDoneC;

  SC_THREAD(app);
}

Software::~Software() {
  SC_REPORT_INFO("Software", "Destructed."); // message
}

// 3.2
uint32_t Software::rotr(uint32_t x, size_t n) {
  return (x >> n) | (x << (32 - n));
}

uint32_t Software::shr(uint32_t x, size_t n) { return x >> n; }

uint32_t Software::swapE32(uint32_t val) {

  uint32_t x = val;
  x = (x & 0xffff0000) >> 16 | (x & 0x0000ffff) << 16;
  x = (x & 0xff00ff00) >> 8 | (x & 0x00ff00ff) << 8;
  return x;
}

uint64_t Software::swapE64(uint64_t val) {
  uint64_t x = val;
  x = (x & 0xffffffff00000000) >> 32 | (x & 0x00000000ffffffff) << 32;
  x = (x & 0xffff0000ffff0000) >> 16 | (x & 0x0000ffff0000ffff) << 16;
  x = (x & 0xff00ff00ff00ff00) >> 8 | (x & 0x00ff00ff00ff00ff) << 8;
  return x;
}

void Software::pad_and_parse(unsigned char *msg, size_t len) {
  // 5.1.1

  l = len * sizeof(char) * 8;
  k = (448 - l - 1) % 512;
  if (k <= 0)
    k += 512;
  assert((l + 1 + k) % 512 == 448);
  inputLen = l + 1 + k + 64;

  msgPad = (char *)calloc((inputLen / 8), sizeof(char));
  memcpy(msgPad, msg, len);
  msgPad[len] = 0x80;
  l = swapE64(l);
  memcpy(msgPad + (inputLen / 8) - 8, &l, 8);
  // 5.2.1
  N = inputLen / 512;

  // 6.2

  M = (uint32_t *)msgPad;
  cout << "M is: " << M << endl;
  cout << "Value at M is: " << *M << endl;
  cout << "N is: " << N << endl;
  for (size_t i = 0; i < N * 16; i++) {
    M[i] = swapE32(M[i]);
  }
}

void Software::write_dma(sc_dt::uint64 addr, unsigned char *ptr) {
  pl_t pl;
  sc_dt::uint64 taddr;
  taddr = VP_ADDR_DMA_L | addr;
  pl.set_command(tlm::TLM_WRITE_COMMAND);
  pl.set_response_status(tlm::TLM_INCOMPLETE_RESPONSE);

  switch (addr) {
  case DMA_INPUT_ADDR:
    pl.set_address(taddr);
    pl.set_data_ptr(ptr);
    pl.set_data_length(sizeof(ptr));
    break;

  case DMA_HASH_ADDR:
    pl.set_address(taddr);
    pl.set_data_ptr(ptr);
    pl.set_data_length(sizeof(ptr));
    break;

  case DMA_ILEN_ADDR:
    inputLen /= 32;
    pl.set_address(taddr);
    pl.set_data_ptr((unsigned char *)&inputLen);
    pl.set_data_length(sizeof(inputLen));
    break;

  case DMA_CSR_ADDR:
    ctrl = 1;
    pl.set_address(taddr);
    pl.set_data_ptr((unsigned char *)&ctrl);
    pl.set_data_length(sizeof(ctrl));
    break;

  default:
    SC_REPORT_ERROR("SW", "Wrong adress to write in DMA");
  }

  delay += sc_core::sc_time(30 * TIME_LONGEST_PATH, sc_core::SC_NS);
  icsoc->b_transport(pl, offset); // transport
}

void Software::write_hardware(sc_dt::uint64 addr) {
  pl_t pl; // payload

  sc_dt::uint64 taddr = addr | VP_ADDR_HARD_L;

  pl.set_address(taddr);
  pl.set_data_length(sizeof(N));
  pl.set_data_ptr((unsigned char *)&N);
  pl.set_command(tlm::TLM_WRITE_COMMAND); // set command for writing
  pl.set_response_status(tlm::TLM_INCOMPLETE_RESPONSE); // set response
  sc_time offset(6 * TIME_LONGEST_PATH, SC_NS);
  icsoc->b_transport(pl, offset); // transport

  std::cout << "\nSW: wrote to hardware" << std::endl;
}

void Software::app() {
  inputLen = Read_from_file("../data/input", &input);
  cout << "Length of input is: " << inputLen << endl;
  // configure hardware
  std::cout << "SW: wrote to dma, started\n" << std::endl;

  /*cout << endl << "Enter string to be hashed: " << endl;
   cin >> hash;
   cout << "You entered :" << hash << endl;
   len = strlen(hash);*/
  pad_and_parse(input, inputLen);

  write_hardware(HARDWARE_BCOUNT_ADDR);
  // configure dma
  write_dma(DMA_ILEN_ADDR);
  write_dma(DMA_INPUT_ADDR, (unsigned char *)M);
  write_dma(DMA_HASH_ADDR, (unsigned char *)H);
  // start
  write_dma(DMA_CSR_ADDR);
  wait(*hwDone);
  // compare and report
  free(msgPad);
  cout << "Delay: " << delay << endl;
  cout << "Throughput: "
       << (N * BLOCK_SIZE / pow(1024, 2)) / (delay.to_double() / pow(10,
                                                                     12))
       << " MB/s." << endl; // number of blocks * bytes per block *MB / time *s
}

void Software::b_transport(pl_t &pl, sc_core::sc_time &offset) {
  tlm_command cmd = pl.get_command();
  uint64 addr = pl.get_address();
  char *data = (char *)pl.get_data_ptr();
  unsigned int length = pl.get_data_length();
  // if it's a hash just give me the pointer
  if (cmd == tlm::TLM_WRITE_COMMAND) {
    if (addr == DMA_HASH_ADDR) {
      hash = (unsigned char *)data;
      cout << "DDR : read the hash\n" << endl;
      pl.set_response_status(tlm::TLM_OK_RESPONSE);
    }
  }
}
