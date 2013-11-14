#ifndef __IB_HEADER_FIFO_H__
#define __IB_HEADER_FIFO_H__

#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <string>
#include <sys/mman.h>
#include <iostream>

class ConfigSpace;
class DmaSpace;
class QuadWordFifo;

class IbHeaderDesc {
   public:
      uint mgmt;
      uint htype;
      uint size;
      uint err;
      uint *data;
      uint alloc;
};

class IbHeaderFifo {

      QuadWordFifo  * _sfifo;
      ConfigSpace   * _cspace;
      DmaSpace      * _dspace;
      uint            _num;
      bool            _enable;

   public:

      IbHeaderFifo (ConfigSpace *cspace, DmaSpace *dspace, uint fifoNum);

      ~IbHeaderFifo ();

      // Enable FIFO
      void setEnable ( bool enable );

      // Pop a test entry value if available
      uint popEntry ( IbHeaderDesc *ptr );

};

#endif
