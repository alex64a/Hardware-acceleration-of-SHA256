class sha256_monitor extends uvm_monitor;

   // control fileds
   bit checks_enable = 1;
   bit coverage_enable = 1;

   uvm_analysis_port #(sha256_seq_item) item_collected_port;

   `uvm_component_utils_begin(sha256_monitor)
      `uvm_field_int(checks_enable, UVM_DEFAULT)
      `uvm_field_int(coverage_enable, UVM_DEFAULT)
   `uvm_component_utils_end

   // The virtual interface used to drive and view HDL signals.
   virtual interface sha256_if vif;

   // current transaction
   sha256_seq_item curr_it;

   function new(string name = "sha256_monitor", uvm_component parent = null);
      super.new(name,parent);      
      item_collected_port = new("item_collected_port", this);
      if (!uvm_config_db#(virtual sha256_if)::get(this, "", "sha256_if", vif))
        `uvm_fatal("NOVIF",{"virtual interface must be set:",get_full_name(),".vif"})
   endfunction

   function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      
   endfunction : connect_phase

   task main_phase(uvm_phase phase);
      forever begin
      curr_it = sha256_seq_item::type_id::create("curr_it", this);    
      item_collected_port.write(curr_it);
      end
   endtask : main_phase

endclass : sha256_monitor
