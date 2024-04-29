#include "interconnect.hpp"

Interconnect::Interconnect(sc_core::sc_module_name name): sc_module(name), offset(sc_core::SC_ZERO_TIME), swsoc("swsoc")
{
    swsoc.register_b_transport(this, &Interconnect::b_transport);
    SC_REPORT_INFO("Interconnect", "Constructed.");//message
}

Interconnect::~Interconnect(){
    SC_REPORT_INFO("Interconnect", "Destructed.");//message
}

void Interconnect::b_transport(pl_t &pl, sc_core::sc_time &offset)
{
    sc_dt::uint64 addr = pl.get_address();//set payload address
    sc_dt::uint64 taddr = addr & 0x000000FF;//mask to get local address

	if(addr >= VP_ADDR_DMA_L && addr <= VP_ADDR_DMA_H){//transport for dma
        pl.set_address(taddr);//set local address
        dmasoc->b_transport(pl, offset);//transport
    }
    else if(addr >= VP_ADDR_HARD_L && addr <= VP_ADDR_HARD_H){//transport for hardware
        pl.set_address(taddr);//set local address
        hwsoc->b_transport(pl, offset);//transport
    }
	else{//error
        SC_REPORT_ERROR("Interconnect", "Wrong address.");
        pl.set_response_status ( tlm::TLM_ADDRESS_ERROR_RESPONSE );
    }

    offset += sc_core::sc_time(10, sc_core::SC_NS);//increment time
}
