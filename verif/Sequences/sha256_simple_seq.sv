`ifndef SHA256_SIMPLE_SEQ_SV
 `define SHA256_SIMPLE_SEQ_SV

class sha256_simple_seq extends sha256_base_seq;

   `uvm_object_utils (sha256_simple_seq)

   function new(string name = "sha256_simple_seq");
      super.new(name);
   endfunction

 //Padded input string
 //Check https://sha256algorithm.com/ for more info on how the padding works   
 logic [31:0] test_string[16] = '{
      32'h31800000,//1
      32'h00000000,//2
      32'h00000000,//3
      32'h00000000,//4
      32'h00000000,//5
      32'h00000000,//6
      32'h00000000,//7
      32'h00000000,//8
      32'h00000000,//9
      32'h00000000,//10
      32'h00000000,//11
      32'h00000000,//12
      32'h00000000,//13
      32'h00000000,//14
      32'h00000000,//15
      32'h00000008 //16
   };


virtual task body();
   req.rand_mode(0);
   
   
  //When the start signal is set to high, send the number of blocks (block count)
  `uvm_do_with(req, {req.start == 1; req.N_i == 32'h00000001; })
   $display("SIMPLE_SEQ: The value of req.N_i is: %h", req.N_i);
   $display("SIMPLE_SEQ: The value of req.start is: %b", req.start);
   
   `uvm_info("sha256_simple_seq", "Block count sent", UVM_LOW);
   
   //Send the padded message M which is our test_string
   //Check https://sha256algorithm.com/ for more info on how the padding works 
   for(int i = 0; i < 16; i++)begin
   `uvm_do_with(req, {req.start == 0; req.M_i == test_string[i]; })
   end                       
  
endtask : body

endclass : sha256_simple_seq

`endif
