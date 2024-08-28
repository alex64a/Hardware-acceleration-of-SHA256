`ifndef SHA256_IF_SV
 `define SHA256_IF_SV

interface sha256_if (input clk, logic rst);

  parameter DATA_WIDTH = 32;
  parameter OUTPUT_WIDTH = 256;

   logic [DATA_WIDTH - 1 : 0] N_i;
   logic [DATA_WIDTH - 1 : 0]  M_i;
   logic [OUTPUT_WIDTH - 1 : 0]  H;
   logic start;
   logic ready;

endinterface : sha256_if

`endif
