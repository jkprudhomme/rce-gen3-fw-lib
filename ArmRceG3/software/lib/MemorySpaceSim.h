#ifndef __MEMORY_SPACE_SIM_H__
#define __MEMORY_SPACE_SIM_H__

#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <string>
#include <sys/mman.h>
#include <iostream>
#include "MemorySpace.h"
#include "AxiSharedMem.h"

class ThreadData {
   public:
      void         *ptr;
      pthread_t    writeThread;
      pthread_t    readThread;
      AxiSharedMem *mem;
      uint         idx;
};
 
class MemorySpaceSim : public MemorySpace {

      // Constants
      static const uint ConfigBase = 0x88000000;
      static const uint MemorySize = 1024*1024;

      // Memory space
      uint *_memorySpace;

      // Read tracking
      uint _readReq;
      uint _readAck;
      uint _readAddr;
      uint _readData;

      // Write tracking
      uint _writeReq;
      uint _writeAck;
      uint _writeAddr;
      uint _writeData;

      // Config interface
      AxiSharedMem *_configShared;
      AxiSharedMem *_acpShared;

      // Threads
      pthread_t _configThread;
      ThreadData _memThread[5];

      // Thread routines
      static void * staticConfigRun(void *t);
      static void * staticMemoryWriteRun(void *t);
      static void * staticMemoryReadRun(void *t);

      // Run Enable
      bool _runEnable;

   public:

      MemorySpaceSim ();

      ~MemorySpaceSim ();

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

      void configRun();
      void memoryWriteRun(ThreadData *ptr);
      void memoryReadRun(ThreadData *ptr);

};

#endif
