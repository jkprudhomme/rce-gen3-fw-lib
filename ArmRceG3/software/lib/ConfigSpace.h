#ifndef __CONFIG_SPACE_H__
#define __CONFIG_SPACE_H__

#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <string>
#include <sys/mman.h>
#include <iostream>

class MemorySpace;

class ConfigSpace {

      MemorySpace * _mspace;

   public:

      ConfigSpace (MemorySpace *mspace);

      ~ConfigSpace ();

      // Read from completion FIFOs 0 - 10
      uint getCompFifoData ( uint fifo );

      // Read from free list FIFOs, 0 - 3
      uint getObFreeFifoData ( uint fifo );

      // Inbound header free list FIFO write, 0 - 3
      void postHeaderFreeList ( uint fifo, uint flags, uint base );

      // Outbound header write, 0 - 3
      void postObHeaderPtr ( uint fifo, uint flags, uint value );

      // Dirty flag clear, 0 - 8
      void clearDirtyFlag ( uint fifo );

      // Get dirty status, 0 - 19
      bool getDirty (uint channel);

      // Set interrupt enable, 0 - 15
      void setIntEnable (uint channel, bool enable);

      // Write DMA Cache config
      void setWriteDmaCache ( uint value );

      // Read DMA Cache config
      void setReadDmaCache ( uint value );

      // FIFO enables 0 - 8
      void setFifoEnable (uint fifo, bool enable );

      // Memory base address
      void setMemBaseAddress (uint base );

      // Write DMA Cache config
      void setPpiWriteDmaCache ( uint value );

      // Read DMA Cache config
      void setPpiReadDmaCache ( uint value );

      // Inbound ppi data write, 0 - 3
      void postIbPpiDesc ( uint fifo, uint flags, uint data );
};

#endif
