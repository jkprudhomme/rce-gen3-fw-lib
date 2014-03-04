#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <string>
#include <string.h>
#include <sys/mman.h>
#include <iostream>
#include <iomanip>
#include "QuadWordFifo.h"
#include "IbHeaderFifo.h"
#include "ConfigSpace.h"
#include "DmaSpace.h"
using namespace std;

IbHeaderFifo::IbHeaderFifo (ConfigSpace *cspace, DmaSpace *dspace, uint fifoNum) {
   _cspace   = cspace;
   _dspace   = dspace;
   _num      = fifoNum;
   _enable   = false;

   _sfifo = new QuadWordFifo(cspace,dspace,fifoNum);

   uint value;
   value = (uint)_dspace->getIbHeaderOffset(_num,0);

   // Put one entry on the free list
   std::cout << "Ib Header Fifo " << std::dec << _num << " Free List Entry 0x" << std::hex << value << std::endl;
   _cspace->postHeaderFreeList(_num,0,value);
}

IbHeaderFifo::~IbHeaderFifo () {
   delete _sfifo;
}

// Enable FIFO
void IbHeaderFifo::setEnable ( bool enable ) {
   _enable = enable;
   _sfifo->setEnable(true);
}

// Pop a test entry value if available
uint IbHeaderFifo::popEntry ( IbHeaderDesc *ptr ) {
   uint high;
   uint low;
   uint offset;

   // Not enabled
   if ( !_enable ) return(0);

   // Check completion FIFO
   if ( _sfifo->popEntry(&high,&low) ) {

      ptr->err    = (high >> 18) & 0x10000000;
      ptr->mgmt   = (high >> 31) & 0x00080000;
      ptr->htype  = (high >> 28) & 0x00070000;
      ptr->size   = (high      ) & 0x000000FF;
      offset      = (low       ) & 0x0003FFFF;

      ptr->size   = (ptr->size) * 2;

      cout << "Got Header"
           << " err " << ptr->err
           << " mgmt " << ptr->mgmt
           << " htype " << ptr->htype
           << " size " << ptr->size
           << " offset " << ptr->offset << std::endl;

      if ( ptr->alloc < ptr->size ) return -1;

      // Copy data
      _dspace->ibCopy32(ptr->data,offset,ptr->size);

      // Return entry to free list
      _cspace->postHeaderFreeList(_num,0,offset);

      return(ptr->size);
   }
   return(0);
}

