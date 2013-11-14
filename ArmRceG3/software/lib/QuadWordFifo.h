#ifndef __QUAD_WORD_FIFO_H__
#define __QUAD_WORD_FIFO_H__

#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <string>
#include <sys/mman.h>
#include <iostream>

class ConfigSpace;
class DmaSpace;

class QuadWordFifo {

      ConfigSpace * _cspace;
      DmaSpace    * _dspace;
      uint          _num;
      bool          _enable;

   public:

      QuadWordFifo (ConfigSpace *cspace, DmaSpace *dspace, uint fifoNum);

      ~QuadWordFifo ();

      // Enable FIFO
      void setEnable ( bool enable );

      // Pop a test entry value if available
      bool popEntry ( uint *high, uint *low );

};

#endif
