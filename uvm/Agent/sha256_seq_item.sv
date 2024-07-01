`ifndef SHA256_SEQ_ITEM_SV
 `define SHA256_SEQ_ITEM_SV

parameter DATA_WIDTH = 32;
parameter RESP_WIDTH = 2;
parameter CMD_WIDTH = 4;

class sha256_seq_item extends uvm_sequence_item;

      

   `uvm_object_utils_begin(sha256_seq_item)
   `uvm_object_utils_end

   function new (string name = "sha256_seq_item");
      super.new(name);
   endfunction // new

endclass : sha256_seq_item

`endif
