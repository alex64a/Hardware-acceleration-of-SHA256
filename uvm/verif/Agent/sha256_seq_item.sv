`ifndef SHA256_SEQ_ITEM_SV
 `define SHA256_SEQ_ITEM_SV

parameter DATA_WIDTH = 32;
parameter OUTPUT_WIDTH = 256;

class sha256_seq_item extends uvm_sequence_item;

   logic start;
   logic ready;
   logic [DATA_WIDTH - 1 : 0] N_i;
   logic [DATA_WIDTH - 1 : 0] M_i;
   logic [OUTPUT_WIDTH - 1 : 0] H;   

   `uvm_object_utils_begin(sha256_seq_item)
        `uvm_field_int(start, UVM_DEFAULT);
        `uvm_field_int(ready, UVM_DEFAULT);
        `uvm_field_int(M_i, UVM_DEFAULT);
        `uvm_field_int(N_i, UVM_DEFAULT);
        `uvm_field_int(H, UVM_DEFAULT);
   `uvm_object_utils_end

   function new (string name = "sha256_seq_item");
      super.new(name);
   endfunction // new

endclass : sha256_seq_item

`endif
