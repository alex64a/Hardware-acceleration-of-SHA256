`ifndef SHA256_SIMPLE_SEQ_SV
 `define SHA256_SIMPLE_SEQ_SV

class sha256_simple_seq extends sha256_base_seq;

   `uvm_object_utils (sha256_simple_seq)

   function new(string name = "sha256_simple_seq");
      super.new(name);
   endfunction
   
   /*logic [31:0] test_string[16] = '{
      32'h31800000,
      32'h00000000,
      32'h00000000,
      32'h00000000,
      32'h00000000,
      32'h00000000,
      32'h00000000,
      32'h00000000,
      32'h00000000,
      32'h00000000,
      32'h00000000,
      32'h00000000,
      32'h00000000,
      32'h00000000,
      32'h00000000,
      32'h00000008
   }
*/

   virtual task body();
   
   #20ns;
   `uvm_do_with(req, {  req.start == 1; 
                       req.N_i == 32'h00000001;})
   #10ns;                    
      `uvm_do_with(req, {  req.start == 0;}) 
                      
  `uvm_info("sha256_simple_seq", "Block count sent", UVM_LOW);
  #10ns;
  /* for(int i = 0; i < 16; i++)
  {
   `uvm_do_with(req, {req.M_i == test_string[i];} )
  } 
  `uvm_info("sha3_simple_seq", "Padded message sent", UVM_LOW);
*/
   endtask : body

endclass : sha256_simple_seq

`endif
