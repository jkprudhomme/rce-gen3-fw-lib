#ifndef __MEMORY_SPACE_H__
#define __MEMORY_SPACE_H__

#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <string>
#include <sys/mman.h>
#include <iostream>

typedef unsigned char uchar;
 
class MemorySpace {

   public:

      MemorySpace ();

      virtual ~MemorySpace ();

      // Open the port
      virtual bool open ();

      // Close the port
      virtual void close ();

      // Config base (hardware)
      virtual uint cfgBaseHw ();

      // Memory base (hardware)
      virtual uint memBaseHw ();

      // Write config register
      virtual void writeConfig ( uint base, uint offset, uint value );

      // Read config register
      virtual uint readConfig ( uint base, uint offset );

      // Write memory location
      virtual void writeMemory32 ( uint offset, uint  value );
      virtual void writeMemory8  ( uint offset, uchar value );

      // Read memory register
      virtual uint  readMemory32 ( uint offset );
      virtual uchar readMemory8  ( uint offset );
};

#endif
