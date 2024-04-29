#include <systemc>
#include "vp.hpp"
#include <sstream>

using namespace sc_core;
using namespace tlm;
using namespace std;

sc_time delay;

int sc_main(int argc, char* argv[])
{
    Vp vp("VP");
    sc_start();
    
    return 0;
}