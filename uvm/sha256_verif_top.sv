module sha256_verif_top;

   import uvm_pkg::*;     // import the UVM library
`include "uvm_macros.svh" // Include the UVM macros

   import sha256_test_pkg::*;

   logic clk;
   logic rst;

   // interface
   sha256_if sha256_vif(clk, rst);

   // DUT
   sha256_top DUT(
                .clk          ( clk ),
                .reset        ( rst ),
                .N_i    (sha256_vif.N_i),
                .M_i    (sha256_vif.M_i),
                .H      (sha256_vif.H),
                .start  (sha256_vif.start),
                .ready  (sha256_vif.ready)
              
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
