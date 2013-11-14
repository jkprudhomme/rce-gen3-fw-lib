#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <string>
#include <unistd.h>
#include <string.h>
#include <sys/mman.h>
#include <iostream>
#include <iomanip>
#include "QuadWordFifo.h"
#include "ObHeaderFifo.h"
#include "ConfigSpace.h"
#include "DmaSpace.h"
using namespace std;

ObHeaderFifo::ObHeaderFifo (ConfigSpace *cspace, DmaSpace *dspace, uint fifoNum) {
   _cspace   = cspace;
   _dspace   = dspace;
   _num      = fifoNum;
   _enable   = false;

   uint value;
   value = (uint)_dspace->getObHeaderOffset(_num,0) & 0x0003FFFF;

   // Put one entry on the free list
   std::cout << "Ob Header Fifo " << std::dec << _num << " Free List Entry 0x" << std::hex << value << std::endl;

   value |= 0x40000000; // Bit 30 = transfer
   _cspace->postObHeaderPtr(_num,0,value);
}

ObHeaderFifo::~ObHeaderFifo () {
}

// Enable FIFO
void ObHeaderFifo::setEnable ( bool enable ) {
   _enable = enable;
   _cspace->setFifoEnable(_num+5,enable);
}

// Push a transmit entry onto FIFO
void ObHeaderFifo::pushEntry ( ObHeaderDesc *ptr ) {
   uint offset;
   uint value;
   uint length;

   // Not enabled
   if ( !_enable ) return;

   offset = _cspace->getObFreeFifoData(_num);
   if ( (offset & 0x80000000) == 0 ) {
      cout << "Waiting for outbound free list entry!" << endl;
      while ( (offset & 0x80000000) == 0 ) {
         usleep(100);
         offset = _cspace->getObFreeFifoData(_num);
      }
      cout << "Got outbound free list entry!" << endl;
   }

   // Get offset entry
   offset = offset & 0x0003FFFF;

   // Bad size
   if ( ptr->size % 2 != 0 ) {
      cout << "Bad size = " << dec << ptr->size << endl;
      return;
   }
   length = ptr->size/2;

   // Copy data
   _dspace->obCopy32(ptr->data,offset,ptr->size);
   cout << "Header " << dec << _num << " start outbound transfer offset 0x" << hex << setw(8) << setfill('0') << offset << endl;

   // Transmit
   value  = offset             & 0x0003FFFF;
   value |= (length     << 18) & 0x03FC0000;
   value |= (ptr->htype << 26) & 0x1C000000;
   value |= (ptr->mgmt  << 29) & 0x20000000;

   _cspace->postObHeaderPtr(_num,0,value);
}

