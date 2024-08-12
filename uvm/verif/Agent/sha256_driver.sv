`ifndef SHA256_DRIVER_SV
 `define SHA256_DRIVER_SV
class sha256_driver extends uvm_driver#(sha256_seq_item);

   `uvm_component_utils(sha256_driver)
   
   virtual interface sha256_if vif;
   
   function new(string name = "sha256_driver", uvm_component parent = null);
      super.new(name,parent);
      if (!uvm_config_db#(virtual sha256_if)::get(this, "", "sha256_if", vif))
        `uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".vif"})
   endfunction

   function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      
   endfunction : connect_phase

   
   task main_phase(uvm_phase phase);
      forever begin
         seq_item_port.get_next_item(req);
         `uvm_info(get_type_name(),
                   $sformatf("Driver sending...\n%s", req.sprint()),
                   UVM_HIGH)
         // do actual driving here
			   /* TODO */
		 vif.M_i = req.M_i;
         vif.N_i = req.N_i;
         vif.H = req.H;
         vif.start = req.start;
     
         seq_item_port.item_done();
      end
   endtask : main_phase

endclass : sha256_driver

`endif

