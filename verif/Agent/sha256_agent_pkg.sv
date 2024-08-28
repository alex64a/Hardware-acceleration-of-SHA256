`ifndef SHA256_AGENT_PKG
`define SHA256_AGENT_PKG

package sha256_agent_pkg;
 
   import uvm_pkg::*;
   `include "uvm_macros.svh"

   //////////////////////////////////////////////////////////
   // include Agent components : driver,monitor,sequencer
   /////////////////////////////////////////////////////////
   import configurations_pkg::*;   
   
   `include "sha256_seq_item.sv"
   `include "sha256_sequencer.sv"
   `include "sha256_driver.sv"
   `include "sha256_monitor.sv"
   `include "sha256_agent.sv"

endpackage

`endif



