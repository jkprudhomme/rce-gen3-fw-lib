#ifndef __OB_HEADER_FIFO_H__
#define __OB_HEADER_FIFO_H__

#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <string>
#include <sys/mman.h>
#include <iostream>

class ConfigSpace;
class DmaSpace;
class QuadWordFifo;

class ObHeaderDesc {
   public:
      uint mgmt;
      uint htype;
      uint size;
      uint *data;
      uint alloc;
};

class ObHeaderFifo {

      ConfigSpace   * _cspace;
      DmaSpace      * _dspace;
      uint            _num;
      bool            _enable;

   public:

      ObHeaderFifo (ConfigSpace *cspace, DmaSpace *dspace, uint fifoNum);

      ~ObHeaderFifo ();

      // Enable FIFO
      void setEnable ( bool enable );

      // Push a transmit entry onto FIFO
      void pushEntry ( ObHeaderDesc *ptr );

};

#endif
