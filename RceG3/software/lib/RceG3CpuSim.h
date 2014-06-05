#ifndef __RCE_G3_CPU_SIM_H__
#define __RCE_G3_CPU_SIM_H__

#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <string>
#include <sys/mman.h>
#include <iostream>
#include <AxiMasterSim.h>
#include <AxiSlaveSim.h>

class RceG3CpuSim  {

      static const unsigned int gp0Base = 0x40000000;
      static const unsigned int gp0Top  = 0x7FFFFFFF;
      static const unsigned int gp1Base = 0x80000000;
      static const unsigned int gp1Top  = 0xBFFFFFFF;

      AxiSlaveSim  * _hpSlave[4];
      AxiSlaveSim  * _apvSlave;
      AxiMasterSim * _gpMaster[2];

      unsigned char * _memSpace;
      unsigned int    _memSize;

   public:

      RceG3CpuSim (unsigned char *memSpace, uint memSize, uint addrMask=0xFFFFFFFF);
      ~RceG3CpuSim ();

      bool open();
      void close();

      // Write a value
      void write(uint address, uint value);

      // Read a value
      uint read(uint address);

      // Get a master for a particular address space
      AxiMasterSim *getMaster (uint address);

      void setVerbose(bool v);
};

#endif
