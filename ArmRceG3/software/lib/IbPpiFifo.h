#ifndef __IB_PPI_FIFO_H__
#define __IB_PPI_FIFO_H__

#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <string>
#include <sys/mman.h>
#include <iostream>
#include "MemorySpace.h"

class ConfigSpace;
class DmaSpace;
class QuadWordFifo;
class ObHeaderFifo;

class IbPpiDesc {
   public:
      uint  hsize;
      uint  psize;
      uchar *data;
      uint  alloc;
      uint  boffset;
};

class IbPpiFifo {

      IbHeaderFifo  * _hfifo;
      ConfigSpace   * _cspace;
      DmaSpace      * _dspace;
      uint            _num;
      uint            _compIdx;
      bool            _enable;

   public:

      IbPpiFifo (ConfigSpace *cspace, DmaSpace *dspace, uint fifoNum);

      ~IbPpiFifo ();

      void setEnable ( bool enable );

      // Pop a transmit entry onto FIFO
      uint popEntry ( IbPpiDesc *ptr );

};

#endif
