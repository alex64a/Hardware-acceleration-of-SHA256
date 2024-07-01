class sha256_agent extends uvm_agent;

   // components
   sha256_driver drv;
   sha256_sequencer seqr;
   sha256_monitor mon;
   virtual interface sha256_if vif;
   // configuration
   sha256_config cfg;
   int value;   
   `uvm_component_utils_begin (sha256_agent)
      `uvm_field_object(cfg, UVM_DEFAULT)
   `uvm_component_utils_end

   function new(string name = "sha256_agent", uvm_component parent = null);
      super.new(name,parent);
   endfunction

   function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      /************Geting from configuration database*******************/
      if (!uvm_config_db#(virtual sha256_if)::get(this, "", "sha256_if", vif))
        `uvm_fatal("NOVIF",{"virtual interface must be set:",get_full_name(),".vif"})
      
      if(!uvm_config_db#(sha256_config)::get(this, "", "sha256_config", cfg))
        `uvm_fatal("NOCONFIG",{"Config object must be set for: ",get_full_name(),".cfg"})
      /*****************************************************************/
      
      /************Setting to configuration database********************/
            uvm_config_db#(virtual sha256_if)::set(this, "*", "sha256_if", vif);
      /*****************************************************************/
      
      mon = sha256_monitor::type_id::create("mon", this);
      if(cfg.is_active == UVM_ACTIVE) begin
         drv = sha256_driver::type_id::create("drv", this);
         seqr = sha256_sequencer::type_id::create("seqr", this);
      end
   endfunction : build_phase

   function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      if(cfg.is_active == UVM_ACTIVE) begin
         drv.seq_item_port.connect(seqr.seq_item_export);
      end
   endfunction : connect_phase

endclass : sha256_agent
