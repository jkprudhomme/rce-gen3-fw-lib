#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <string>
#include <sys/mman.h>
#include <iostream>
#include "QuadWordFifo.h"
#include "ConfigSpace.h"
#include "DmaSpace.h"
using namespace std;

QuadWordFifo::QuadWordFifo (ConfigSpace *cspace, DmaSpace *dspace, uint fifoNum) {
   _cspace   = cspace;
   _dspace   = dspace;
   _num      = fifoNum;
   _enable   = false;
}

QuadWordFifo::~QuadWordFifo () {}

// Enable FIFO
void QuadWordFifo::setEnable ( bool enable ) {
   _enable = enable;
   _cspace->setFifoEnable(_num,enable);
}

// Pop a test entry value if available
bool QuadWordFifo::popEntry ( uint *high, uint *low ) {

   // Not enabled
   if ( !_enable ) return(false);

   if ( _cspace->getDirty(_num) ) {
      _dspace->getSingleDma ( _num, high, low );
      _cspace->clearDirtyFlag(_num);
      return(true);
   }
   return(false);
}

