#ifndef __MEMORY_SPACE_MAP_H__
#define __MEMORY_SPACE_MAP_H__

#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <string>
#include <sys/mman.h>
#include <iostream>
#include "MemorySpace.h"
 
class MemorySpaceMap : public MemorySpace {

      static const uint ConfigBase             = 0x88000000;
      static const unsigned long ConfigMapSize = 0x00040000;

      //static const uint MemoryBase             = 0x00001000;
      static const uint MemoryBase             = 0xFFFC0000;
      static const unsigned long MemoryMapSize = 16384;

      int    _devFd;

      void * _memMappedBase;
      void * _cfgMappedBase;

   public:

      MemorySpaceMap ();

      ~MemorySpaceMap ();

      // Open the port
      bool open ();

      // Close the port
      void close ();

      // Config base (hardware)
      uint cfgBaseHw ();

      // Memory base (hardware)
      uint memBaseHw ();

      // Write config register
      void writeConfig ( uint base, uint offset, uint value );

      // Read config register
      uint readConfig ( uint base, uint offset );

      // Write memory location
      void writeMemory32 ( uint offset, uint  value );
      void writeMemory8  ( uint offset, uchar value );

      // Read memory register
      uint  readMemory32 ( uint offset );
      uchar readMemory8  ( uint offset );

      // Dump memory space
      void dumpMemory ( uint base, uint size );

      // Dump config space
      void dumpConfig (uint base, uint size );

};

#endif
