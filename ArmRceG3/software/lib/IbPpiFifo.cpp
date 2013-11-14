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
#include "IbHeaderFifo.h"
#include "IbPpiFifo.h"
#include "ConfigSpace.h"
#include "DmaSpace.h"
using namespace std;

IbPpiFifo::IbPpiFifo (ConfigSpace *cspace, DmaSpace *dspace, uint fifoNum) {
   _cspace   = cspace;
   _dspace   = dspace;
   _num      = fifoNum;
   _enable   = false;

   _hfifo = new IbHeaderFifo(cspace,dspace, fifoNum);

   _compIdx = fifoNum;
}

IbPpiFifo::~IbPpiFifo () {
}

// Enable FIFO
void IbPpiFifo::setEnable ( bool enable ) {
   _enable = enable;
   _hfifo->setEnable(enable);
}

// Push a transmit entry onto FIFO
uint IbPpiFifo::popEntry ( IbPpiDesc *ptr ) {
   uint         addr;
   IbHeaderDesc hdesc;

   // Not enabled
   if ( !_enable ) return(0);

   // Setup header
   hdesc.mgmt  = 0;
   hdesc.htype = 0;
   hdesc.size  = 0;
   hdesc.err   = 0;
   hdesc.alloc = 1024;
   hdesc.data  = (uint *)malloc(hdesc.alloc*4);

   if ( _hfifo->popEntry(&hdesc) <= 0 ) return(0);

   cout << "Found header. Size=" << dec << hdesc.size << " ERR=" << dec << hdesc.err << endl;

   // Copy data to header
   ptr->hsize = hdesc.size * 4;
   ptr->psize = hdesc.data[0];
   memcpy(ptr->data,hdesc.data,hdesc.size*4);

   // No payload
   if ( ptr->psize == 0 ) {
      cout << "No payload" << endl;
      return(ptr->hsize);
   }
   cout << "Waiting for payload. Size=" << dec << ptr->psize << endl;

   // Get address
   addr = _dspace->getIbPpiOffset(_num,0) + ptr->boffset;

   cout << "Addr=0x" << hex << addr << endl;

   // Write to inbound desc fifo
   _cspace->postIbPpiDesc(_num, 0, _dspace->getDmaBase() + addr); // Drop flag
   _cspace->postIbPpiDesc(_num, 1, ptr->alloc*4); // flags = compEn
   _cspace->postIbPpiDesc(_num, _compIdx, 0xaaaaaaaa);

   // Wait for completion
   if ( ! _cspace->getDirty(5 + _compIdx) ) {
      cout << "Waiting for inbound completion entry!" << endl;
      while ( ! _cspace->getDirty(5 + _compIdx) ) usleep(100);
   }
   cout << "Got inbound completion entry: 0x" 
        << hex << setw(8) << setfill('0') << _cspace->getCompFifoData ( _compIdx ) << endl;

   // Copy data to buffer
   _dspace->ibCopy8((uchar *)(&(ptr->data[ptr->hsize])),addr,ptr->psize);

   return(1);
}

