#ifndef TYPEDEFS_HPP
#define TYPEDEFS_HPP

#include <tlm.h>
extern sc_core::sc_time delay;

typedef tlm::tlm_base_protocol_types::tlm_payload_type pl_t;
typedef tlm::tlm_base_protocol_types::tlm_phase_type ph_t;
#define BLOCK_SIZE (512 / 32)
#define OUTPUT_SIZE (256 / 8)
#define HEX_AMOUNT (OUTPUT_SIZE * 2 + 1)

#define VP_ADDR_DMA_L 0x01000000
#define VP_ADDR_DMA_H 0x01D00000

#define DMA_INPUT_ADDR 0x00000001
#define DMA_HASH_ADDR 0x00000002
#define DMA_CSR_ADDR 0x00000003
#define DMA_ILEN_ADDR 0x00000004

#define VP_ADDR_HARD_L 0x02000000
#define VP_ADDR_HARD_H 0x02000040

#define HARDWARE_BCOUNT_ADDR 0x00000001
#define HARDWARE_STATUS_ADDR 0x00000002

#define START_CMD 0x01

#define TIME_LONGEST_PATH 6
#define BUS_WIDTH 32

#endif
