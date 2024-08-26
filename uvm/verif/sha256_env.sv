`ifndef SHA256_ENV_SV
 `define SHA256_ENV_SV

class sha256_env extends uvm_env;

   sha256_agent agent;
   sha256_config cfg;
   virtual interface sha256_if vif;
   `uvm_component_utils (sha256_env)

   function new(string name = "calc_env", uvm_component parent = null);
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
      uvm_config_db#(sha256_config)::set(this, "agent", "sha256_config", cfg);
      uvm_config_db#(virtual sha256_if)::set(this, "agent", "sha256_if", vif);
      /*****************************************************************/
      agent = sha256_agent::type_id::create("agent", this);
      
   endfunction : build_phase

endclass : sha256_env

`endif
