`ifndef SHA256_TEST_PKG_SV
 `define SHA256_TEST_PKG_SV

package sha256_test_pkg;

   import uvm_pkg::*;      // import the UVM library   
 `include "uvm_macros.svh" // Include the UVM macros

   import sha256_agent_pkg::*;
   import sha256_seq_pkg::*;
   import sha256_pkg::*;   
`include "sha256_env.sv"   
`include "sha256_base.sv"
`include "sha256_simple.sv"
`include "sha256_simple_2.sv"


endpackage : sha256_test_pkg

 `include "sha256_if.sv"

`endif

