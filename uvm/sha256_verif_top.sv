module sha256_verif_top;

   import uvm_pkg::*;     // import the UVM library
`include "uvm_macros.svh" // Include the UVM macros

   import sha256_test_pkg::*;

   logic clk;
   logic [6 : 0] rst;

   // interface
   sha256_if sha256_vif(clk, rst);

   // DUT
   sha256_top DUT(
                .c_clk        ( clk ),
                .reset        ( rst ),
                .out_data1    ( sha256_vif.out_data1 ),
                .out_data2    ( sha256_vif.out_data2 ),
                .out_data3    ( sha256_vif.out_data3 ),
                .out_data4    ( sha256_vif.out_data4 ),
                .out_resp1    ( sha256_vif.out_resp1 ),
                .out_resp2    ( sha256_vif.out_resp2 ),
                .out_resp3    ( sha256_vif.out_resp3 ),
                .out_resp4    ( sha256_vif.out_resp4 ),
                .req1_cmd_in  ( sha256_vif.req1_cmd_in ),
                .req1_data_in ( sha256_vif.req1_data_in ),
                .req2_cmd_in  ( sha256_vif.req2_cmd_in ),
                .req2_data_in ( sha256_vif.req2_data_in ),
                .req3_cmd_in  ( sha256_vif.req3_cmd_in ),
                .req3_data_in ( sha256_vif.req3_data_in ),
                .req4_cmd_in  ( sha256_vif.req4_cmd_in ),
                .req4_data_in ( sha256_vif.req4_data_in )
                );

   // run test
   initial begin      
      uvm_config_db#(virtual sha256_if)::set(null, "uvm_test_top.env", "sha256_if", sha256_vif);
      run_test();
   end

   // clock and reset init.
   initial begin
      clk <= 0;
      rst <= 1;
      #50 rst <= 0;
   end

   // clock generation
   always #50 clk = ~clk;

endmodule : sha256_verif_top
