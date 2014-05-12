#ifndef __DMA_SPACE_H__
#define __DMA_SPACE_H__

#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <string>
#include <sys/mman.h>
#include <iostream>
#include "MemorySpace.h"

class DmaSpace {

      static const uint SingleOffset   = 0;
      static const uint IbHeaderOffset = 256;
      static const uint IbHeaderSize   = 128;
      static const uint ObHeaderOffset = 1024;
      static const uint ObHeaderSize   = 128;
      static const uint IbPpiOffset    = 2048;
      static const uint IbPpiSize      = 512;
      static const uint ObPpiOffset    = 4096;
      static const uint ObPpiSize      = 512;

      MemorySpace * _mspace;

   public:

      DmaSpace (MemorySpace *mspace);

      ~DmaSpace ();

      // Get DMA space base address (hardware address)
      uint getDmaBase();

      // Get the two 32-bit values from a particular memory channel
      void getSingleDma ( uint channel, uint *upper, uint *lower );

      // Init the two 32-bit values from a particular memory channel
      void initSingleDma ( uint channel );

      // Get offset for inbound header channel
      uint getIbHeaderOffset(uint channel, uint idx);

      // Get offset for outbound header channel
      uint getObHeaderOffset(uint channel, uint idx);

      // Get pointer to inbound PPI space
      uint getIbPpiOffset(uint channel, uint idx);

      // Get pointer to outbound PPI space
      uint getObPpiOffset(uint channel, uint idx);

      // Copy data
      void ibCopy32 ( uint  *ptr, uint offset, uint size );
      void ibCopy8  ( uchar *ptr, uint offset, uint size );
      void clear8   ( uint offset, uint size );

      // Copy data
      void obCopy32 ( uint  *ptr, uint offset, uint size );
      void obCopy8  ( uchar *ptr, uint offset, uint size );

};

#endif
