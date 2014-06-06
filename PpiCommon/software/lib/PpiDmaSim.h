#ifndef __PPI_DMA_SIM_H__
#define __PPI_DMA_SIM_H__

#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <string>
#include <sys/mman.h>
#include <iostream>
#include "RceG3CpuSim.h"

class PpiDmaSim  {

      RceG3CpuSim   * _cpuSim;
      uint            _channel;
      unsigned char * _slaveMem;
      uint            _slaveSize;

      uint _baseAddr[4];
      //static const uint _baseAddr[4] = { 0x50000000,
      //                                   0x50020000,
      //                                   0x50040000,
      //                                   0x50060000 };

      // Per PPI registers
      static const uint _ppiControl = 0x00000000;
      static const uint _countReset = 0x0000000C;
      static const uint _obHdrError = 0x00000010;
      static const uint _obPayError = 0x00000014;
      static const uint _ibHdrError = 0x00000018;
      static const uint _ibPayError = 0x0000001C;
      static const uint _obFree     = 0x00010000;
      static const uint _ibPend     = 0x00010004;
      static const uint _obWork     = 0x00010200;
      static const uint _ibWork     = 0x00010240;

      // Completion FIFO base
      static const uint _compFifos  = 0x50080000;
    
      static const uint _buffSize   = 4096;

      static const uint _ibHdrAddr  = 0x00000000;
      static const uint _ibPayAddr  = _ibHdrAddr + _buffSize;
      static const uint _obHdrAddr  = _ibPayAddr + _buffSize;
      static const uint _obPayAddr  = _obHdrAddr + _buffSize;

   public:

      PpiDmaSim (uint idx, RceG3CpuSim *cpu,unsigned char *mem, uint memSize );
      ~PpiDmaSim ();

      // Write a block of data
      int write(unsigned char *data, uint hdrSize, uint paySize, uint type);

      // Read a block of data, return -1 on error, 0 if no data, size if data
      int read(unsigned char *data, uint maxSize, uint *type, uint *err, uint *hdrSize, uint *paySize);

};

#endif
