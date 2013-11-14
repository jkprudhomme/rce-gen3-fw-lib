#ifndef __OB_PPI_FIFO_H__
#define __OB_PPI_FIFO_H__

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

class ObPpiDesc {
   public:
      uint  hsize;
      uint  psize;
      uchar *data;
      uint  alloc;
      uint  boffset;
};

class ObPpiFifo {

      ObHeaderFifo  * _hfifo;
      ConfigSpace   * _cspace;
      DmaSpace      * _dspace;
      uint            _num;
      uint            _compIdx;
      bool            _enable;

   public:

      ObPpiFifo (ConfigSpace *cspace, DmaSpace *dspace, uint fifoNum);

      ~ObPpiFifo ();

      // Enable FIFO
      void setEnable ( bool enable );

      // Push a transmit entry onto FIFO
      void pushEntry ( ObPpiDesc *ptr );

};

#endif
