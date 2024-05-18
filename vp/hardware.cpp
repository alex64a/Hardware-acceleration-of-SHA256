#include "hardware.hpp"
#include "string.h"
#include "typedefs.hpp"
#include <bits/fs_fwd.h>
#include <cstdint>
#include <cstdio>
#include <ostream>
using namespace std;

Hardware::Hardware(sc_core::sc_module_name name, sc_core::sc_event *hwDoneC)
    : sc_module(name), icsoc("icsoc") {
  SC_REPORT_INFO("Hardware", "Constructed.");
  icsoc.register_b_transport(this, &Hardware::b_transport);
  hex = new unsigned char[HEX_AMOUNT];
  SC_THREAD(fifoCheck);
  hwDone = hwDoneC;
}

Hardware::~Hardware() { SC_REPORT_INFO("Hardware", "Destructed."); }

uint32_t Hardware::rotr(uint32_t x, size_t n) {
  return (x >> n) | (x << (32 - n));
}
uint32_t Hardware::shr(uint32_t x, size_t n) { return x >> n; }

// 4.1.2
uint32_t Hardware::Ch(uint32_t x, uint32_t y, uint32_t z) {
  return (x & y) ^ (~x & z);
}
uint32_t Hardware::Maj(uint32_t x, uint32_t y, uint32_t z) {
  return (x & y) ^ (x & z) ^ (y & z);
}
uint32_t Hardware::ep0(uint32_t x) {
  return rotr(x, 2) ^ rotr(x, 13) ^ rotr(x, 22);
}
uint32_t Hardware::ep1(uint32_t x) {
  return rotr(x, 6) ^ rotr(x, 11) ^ rotr(x, 25);
}
uint32_t Hardware::sig0(uint32_t x) {
  return rotr(x, 7) ^ rotr(x, 18) ^ shr(x, 3);
}
uint32_t Hardware::sig1(uint32_t x) {
  return rotr(x, 17) ^ rotr(x, 19) ^ shr(x, 10);
}

void Hardware::hash() {

  // 6.2.2
  for (size_t i = 0; i < N; i++) {
    // 1
    for (size_t t = 0; t < 16; t++) {
      W[t] = M[i * 16 + t];
    }
    for (size_t t = 16; t < 64; t++) {
      W[t] = sig1(W[t - 2]) + W[t - 7] + sig0(W[t - 15]) + W[t - 16];
    }

    // 2
    for (size_t t = 0; t < 8; t++) {
      v[t] = H[t];
    }

    // 3
    for (size_t t = 0; t < 64; t++) {
      // a=0 b=1 c=2 d=3 e=4 f=5 g=6 h=7
      T1 = v[7] + ep1(v[4]) + Ch(v[4], v[5], v[6]) + K[t] + W[t];
      T2 = ep0(v[0]) + Maj(v[0], v[1], v[2]);

      v[7] = v[6];
      v[6] = v[5];
      v[5] = v[4];
      v[4] = v[3] + T1;
      v[3] = v[2];
      v[2] = v[1];
      v[1] = v[0];
      v[0] = T1 + T2;
    }

    cout << "H[t] is: ";
    for (size_t t = 0; t < 8; t++) {
      H[t] += v[t];
      cout << H[t];
    }
  }
  cout << endl;
  printHash();
}

void Hardware::printHash() {

  cout << "SHA256 hash: " << endl;
  for (size_t i = 0; i < 8; i++) {
    H[i] = swapE32(H[i]);
    hexOut(&H[i], 4);
  }
  printf("\n");
  cout << endl;
}

void Hardware::hexOut(void *buffer, size_t len) {

  for (size_t i = 0; i < len; i++) {

    printf("%02x", ((char *)buffer)[i] & 0xff);
    if (i % 4 == 3)
      printf(" ");
  }
}
uint32_t Hardware::swapE32(uint32_t val) {

  uint32_t x = val;
  x = (x & 0xffff0000) >> 16 | (x & 0x0000ffff) << 16;
  x = (x & 0xff00ff00) >> 8 | (x & 0x00ff00ff) << 8;
  return x;
}

void Hardware::b_transport(pl_t &pl, sc_core::sc_time &offset) {

  tlm::tlm_command cmd = pl.get_command();
  sc_dt::uint64 addr = pl.get_address();
  unsigned char *data = pl.get_data_ptr();

  if (cmd == tlm::TLM_WRITE_COMMAND) {
    if (addr == HARDWARE_BCOUNT_ADDR) {

      N = *(int *)data;
      M = new uint32_t[N * BLOCK_SIZE + 1];
      M[N * BLOCK_SIZE] = '\0';
      pl.set_response_status(tlm::TLM_OK_RESPONSE);
    } else
      pl.set_response_status(tlm::TLM_ADDRESS_ERROR_RESPONSE);
  } else
    pl.set_response_status(tlm::TLM_ADDRESS_ERROR_RESPONSE);
}

void Hardware::fifoCheck() {
  while (1) {
    if (fifoToIP.num_available()) {
      cout << "Internal buffer:  ";
      for (size_t i = 0; i < N * BLOCK_SIZE; i++) {
        fifoToIP.read(M[i]);
        cout << "HW: Data" << M[i] << endl;
      }
      cout << "HW: Read input from DMA" << endl << endl;
      hash();
      cout << "HW: after hash" << endl;
      for (size_t i = 0; i < HEX_AMOUNT; i++) {
        fifoToDma->write(H[i]);
      }

      // AXI-STREAM HARDWARE TO DMA
      delay += sc_core::sc_time(OUTPUT_SIZE * 8 / BUS_WIDTH * TIME_LONGEST_PATH,
                                sc_core::SC_NS);
      hwDone->notify(); // generate interrupt
      delete (M);
      delete (hex);
      return;
    }
    wait(sc_core::SC_ZERO_TIME);
  }
}
