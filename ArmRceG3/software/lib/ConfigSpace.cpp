#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <string>
#include <sys/mman.h>
#include <iostream>
#include "ConfigSpace.h"
#include "MemorySpace.h"
using namespace std;
 
ConfigSpace::ConfigSpace (MemorySpace *mspace) {
   _mspace = mspace;
}

ConfigSpace::~ConfigSpace () { }

// Read from completion FIFOs 0 - 10
uint ConfigSpace::getCompFifoData ( uint fifo ) {
   if ( fifo < 11 ) return(_mspace->readConfig(0x1000,fifo));
   return(0);
}

// Read from free list FIFOs 0 - 3
uint ConfigSpace::getObFreeFifoData ( uint fifo ) {
   if ( fifo < 4 ) return(_mspace->readConfig(0x1100,fifo));
   return(0);
}

// Header free list FIFO write, 0 - 3
void ConfigSpace::postHeaderFreeList ( uint fifo, uint flags, uint base ) {
   if ( fifo <= 3 ) _mspace->writeConfig(0x000100,(fifo*16)+flags,base);
}

// Outbound header tx FIFO write, 0 - 3
void ConfigSpace::postObHeaderPtr ( uint fifo, uint flags, uint base ) {
   if ( fifo <= 3 ) _mspace->writeConfig(0x000200,(fifo*16)+flags,base);
}

// Dirty flag clear, 0 - 4
void ConfigSpace::clearDirtyFlag ( uint fifo ) {
   if ( fifo <= 4  ) _mspace->writeConfig(0x000300, fifo , 0);
}

// Get dirty status, 0 - 16
bool ConfigSpace::getDirty (uint channel) {
   uint bit;
   uint dirty;

   if ( channel <= 15 ) {
      bit = 0x1 << channel;
      dirty = _mspace->readConfig(0x000400,0);
      return(dirty & bit);
   } else return(false);
}

// Set interrupt enable, 0 - 15
void ConfigSpace::setIntEnable (uint channel, bool enable) {
   uint old;
   uint bit;
   uint set;

   if ( channel <= 15 ) {
      old = _mspace->readConfig(0x000404,0);
      bit = 0x1 << channel;
      if ( enable ) set = old | bit;
      else set = old & (bit ^ 0xFFFFFFFF);
      _mspace->writeConfig(0x000404,0,set);
   }
}

// DMA Cache config
void ConfigSpace::setWriteDmaCache ( uint value ) {
   _mspace->writeConfig(0x000408, 0 , value);
}

// Read DMA Cache config
void ConfigSpace::setReadDmaCache ( uint value ) {
   _mspace->writeConfig(0x00040C, 0 , value);
}

// FIFO enables 0 - 8
void ConfigSpace::setFifoEnable (uint fifo, bool enable ) {
   uint old;
   uint bit;
   uint set;

   if ( fifo <= 8 ) {
      old = _mspace->readConfig(0x000410,0);
      bit = 0x1 << fifo;
      if ( enable ) set = old | bit;
      else set = old & (bit ^ 0xFFFFFFFF);
      _mspace->writeConfig(0x000410,0,set);
   }
}

// Memory base address
void ConfigSpace::setMemBaseAddress (uint base ) {
   _mspace->writeConfig(0x000418, 0 , base);
}

// DMA Cache config
void ConfigSpace::setPpiWriteDmaCache ( uint value ) {
   _mspace->writeConfig(0x000420, 0 , value);
}

// Read DMA Cache config
void ConfigSpace::setPpiReadDmaCache ( uint value ) {
   _mspace->writeConfig(0x00041C, 0 , value);
}

// Inbound ppi data write 0 - 3
void ConfigSpace::postIbPpiDesc ( uint fifo, uint flags, uint data ) {
   if ( fifo <= 3 ) _mspace->writeConfig(0x000500,(fifo*16)+flags,data);
}

