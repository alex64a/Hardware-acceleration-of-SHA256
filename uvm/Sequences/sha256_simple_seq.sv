`ifndef SHA256_SIMPLE_SEQ_SV
 `define SHA256_SIMPLE_SEQ_SV

class sha256_simple_seq extends sha256_base_seq;

   `uvm_object_utils (sha256_simple_seq)

   function new(string name = "sha256_simple_seq");
      super.new(name);
   endfunction

   virtual task body();
      // simple example - just send one item
      `uvm_do(req);
   endtask : body

endclass : sha256_simple_seq

`endif
