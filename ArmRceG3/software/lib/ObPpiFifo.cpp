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
#include "ObPpiFifo.h"
#include "ConfigSpace.h"
#include "DmaSpace.h"
using namespace std;

ObPpiFifo::ObPpiFifo (ConfigSpace *cspace, DmaSpace *dspace, uint fifoNum) {
   _cspace   = cspace;
   _dspace   = dspace;
   _num      = fifoNum;
   _enable   = false;
   _count    = 0;

   _hfifo = new ObHeaderFifo(cspace,dspace, fifoNum);

   _compIdx = 4 + fifoNum;
}

ObPpiFifo::~ObPpiFifo () {
}

// Enable FIFO
void ObPpiFifo::setEnable ( bool enable ) {
   _enable = enable;
   _hfifo->setEnable(enable);
}

// Push a transmit entry onto FIFO
void ObPpiFifo::pushEntry ( ObPpiDesc *ptr ) {
   uint         addr;
   uint         cmp;
   ObHeaderDesc hdesc;

   // Not enabled
   if ( !_enable ) return;

   // Get address
   addr = _dspace->getObPpiOffset(_num,0) + ptr->boffset;

   // Setup header
   hdesc.mgmt  = 0;
   hdesc.htype = 0;
   hdesc.size  = (ptr->hsize/4) + 4;
   hdesc.alloc = hdesc.size;
   hdesc.data  = (uint *)malloc(sizeof(uint) * hdesc.size);
   _count ++;

   // Copy header data
   memcpy(hdesc.data,ptr->data,hdesc.size*4);
   if ( ptr->psize != 0 ) hdesc.data[0] = ptr->psize;
   hdesc.data[hdesc.size-4]  = _dspace->getDmaBase() + addr;
   hdesc.data[hdesc.size-3]  = ptr->psize;
   hdesc.data[hdesc.size-2]  =  _count+_num;
   hdesc.data[hdesc.size-1]  = _compIdx;
   hdesc.data[hdesc.size-1] |= 0x10; // compEn

   // Empty flag
   if ( ptr->psize == 0 ) hdesc.data[hdesc.size-1] |= 0x20;

   // Copy payload data
   if ( ptr->psize > 0 ) _dspace->obCopy8((uchar *)(&(ptr->data[ptr->hsize])),addr,ptr->psize);

   // Post entry
   _hfifo->pushEntry(&hdesc);

   if ( ptr->psize == 0 ) return;

   // Wait for completion
   if ( ! _cspace->getDirty(5 + _compIdx) ) {
      cout << "Waiting for outbound completion entry!" << endl;
      while ( ! _cspace->getDirty(5 + _compIdx) ) usleep(100);
   }

   cmp = _cspace->getCompFifoData ( _compIdx );

   cout << "Got outbound completion entry: 0x" 
        << hex << setw(8) << setfill('0') << cmp << endl;

   if ( cmp != ( _count+_num )) {
      cout << "Bad completion value." << endl;
      exit(1);
   }
}

