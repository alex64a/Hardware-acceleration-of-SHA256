`ifndef SHA256_IF_SV
 `define SHA256_IF_SV

interface sha256_if (input clk, logic [1 : 0] rst);

   parameter DATA_WIDTH = 32;
   parameter OUTPUT_WIDTH = 64;

   logic [DATA_WIDTH - 1 : 0] N_i;
   logic [DATA_WIDTH - 1 : 0]  M_i;
   logic [OUTPUT_WIDTH - 1 : 0]  H;
   logic [1:0] start;
   logic [1:0] ready;

endinterface : sha256_if

`endif
