//////////////////////////////////////////////////////////////////////////////
// This file is part of 'SLAC RCE Core'.
// It is subject to the license terms in the LICENSE.txt file found in the 
// top-level directory of this distribution and at: 
//    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
// No part of 'SLAC RCE Core', including this file, 
// may be copied, modified, propagated, or distributed except according to 
// the terms contained in the LICENSE.txt file.
//////////////////////////////////////////////////////////////////////////////
#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <string>
#include <unistd.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <iostream>
#include <iomanip>
#include <queue>
#include "RceG3CpuSim.h"
using namespace std;
 
RceG3CpuSim::RceG3CpuSim (unsigned char *memSpace, uint memSize, uint addrMask ) {
   uint x;

   _memSpace = memSpace;
   _memSize  = memSize;

   for(x=0; x<4; x++) _hpSlave[x] = new AxiSlaveSim(memSpace,memSize,addrMask);
   _apvSlave = new AxiSlaveSim(memSpace,memSize,addrMask);

   for(x=0; x<2; x++) _gpMaster[x] = new AxiMasterSim();
}

RceG3CpuSim::~RceG3CpuSim () {
   this->close();
}

// Open the port
bool RceG3CpuSim::open () {
   uint x;

   for(x=0; x<4; x++) {
      if ( ! _hpSlave[x]->open(x+5) ) return false;
   }
   if ( ! _apvSlave->open(4) ) return(false);

   for(x=0; x<2; x++) {
      if ( ! _gpMaster[x]->open(x) ) return(false);
   }

   return(true);
}

// Close the port
void RceG3CpuSim::close () {
   uint x;
   for(x=0; x<4; x++) _hpSlave[x]->close();
   _apvSlave->close();
   for(x=0; x<2; x++) _gpMaster[x]->close();
}


// Write a value
void RceG3CpuSim::write(uint address, uint value) {
   if ( address >= gp0Base && address <= gp0Top ) _gpMaster[0]->write(address,value);
   if ( address >= gp1Base && address <= gp1Top ) _gpMaster[1]->write(address,value);
}

// Read a value
uint RceG3CpuSim::read(uint address) {
   if ( address >= gp0Base && address <= gp0Top ) return(_gpMaster[0]->read(address));
   if ( address >= gp1Base && address <= gp1Top ) return(_gpMaster[1]->read(address));
   return(0);
}

// Read a value
AxiMasterSim * RceG3CpuSim::getMaster(uint address) {
   if ( address >= gp0Base && address <= gp0Top ) return(_gpMaster[0]);
   if ( address >= gp1Base && address <= gp1Top ) return(_gpMaster[1]);
   return(NULL);
}

void RceG3CpuSim::setVerbose(bool v) { 
   uint x;
   for(x=0; x<4; x++) _hpSlave[x]->setVerbose(v);
   _apvSlave->setVerbose(v);
   for(x=0; x<2; x++) _gpMaster[x]->setVerbose(v);
}

