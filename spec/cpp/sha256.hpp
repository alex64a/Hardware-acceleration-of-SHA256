#ifndef sha256_hpp
#define sha256_hpp

#include <assert.h>
#include <cstddef>
#include <cstdint>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>

// http://csrc.nist.gov/publications/fips/fips180-2/fips180-2.pdf

// 3.2
uint32_t rotr(uint32_t, size_t);

uint32_t shr(uint32_t, size_t);

// 4.1.2
uint32_t Ch(uint32_t, uint32_t, uint32_t);

uint32_t Maj(uint32_t, uint32_t, uint32_t);

uint32_t ep0(uint32_t);
uint32_t ep1(uint32_t);
uint32_t sig0(uint32_t);
uint32_t sig1(uint32_t);

// swap byte endian
uint32_t swapE32(uint32_t);

uint64_t swapE64(uint64_t);

// print hex numbers
void hex(void *, size_t);

void hexOutput(void *, size_t);
void pad(char *, size_t);
void parse();
void hash();
void printHash();
#endif
