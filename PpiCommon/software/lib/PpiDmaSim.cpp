#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <fcntl.h>
#include <string>
#include <unistd.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <iostream>
#include <iomanip>
#include <queue>
#include <sys/stat.h>

#include "PpiDmaSim.h"
using namespace std;

PpiDmaSim::PpiDmaSim (uint idx, RceG3CpuSim *cpu, unsigned char *mem, uint memSize ) {
   _cpuSim     = cpu;
   _slaveMem   = mem;
   _slaveSize  = memSize;
   _channel    = idx;

   _baseAddr[0] = 0x50000000;
   _baseAddr[1] = 0x50020000;
   _baseAddr[2] = 0x50040000;
   _baseAddr[3] = 0x50060000;

   printf("Write to ob free list : 0x%08x\n",_obHdrAddr);
   _cpuSim->write(_baseAddr[idx]+_obWork,_obHdrAddr);
   printf("Write to ib free list : 0x%08x\n",_ibHdrAddr);
   _cpuSim->write(_baseAddr[idx]+_ibWork,_ibHdrAddr);
}

PpiDmaSim::~PpiDmaSim () { }

// Write a block of data
int PpiDmaSim::write(unsigned char *data, uint hdrSize, uint paySize, uint type) {
   uint            addr;
   uint            desc;
   uint            size;
   uint          * uintPtr;
   unsigned char * ucharPtr;

   addr = _cpuSim->read(_baseAddr[_channel]+_obFree);

   if ((addr & 0x1) != 0 ) return(0);
   printf("Got free outbound address : 0x%08x\n",addr);

   uintPtr  = (uint *)(_slaveMem + addr);
   ucharPtr = _slaveMem + addr + 24;

   uintPtr[0] = addr + 24 + hdrSize;
   uintPtr[1] = paySize;
   uintPtr[2] = _channel*2;
   uintPtr[3] = 0x5a5a5a5a;

   uintPtr[4] = hdrSize;
   uintPtr[5] = paySize;

   memcpy(ucharPtr,data,hdrSize+paySize);
   size = hdrSize + paySize + 24;

   desc = addr | (((hdrSize/8)+3) << 18) | (type << 26);

   if ( paySize > 0 ) desc |= 0xC0000000;
   else desc |= 0x40000000;

   printf("Writing to outbound work\n");
   _cpuSim->write(_baseAddr[_channel]+_obWork,desc);

   if ( paySize > 0 ) {
      printf("Waiting for outbound completion\n");
      do {
         desc = _cpuSim->read(_compFifos+(_channel*8));
         usleep(100);
      } while ( (desc & 0x1) != 0);
      printf("Got write completion : 0x%08x\n",desc);
   }

   return(hdrSize+paySize);
}

// Read a block of data, return -1 on error, 0 if no data, size if data
int PpiDmaSim::read(unsigned char *data, uint maxSize, uint *type, uint *err, uint *hdrSize, uint *paySize) {
   uint          * uintPtr;
   unsigned char * ucharPtr;
   uint            desc;
   uint            pay;
   uint            addr;

   desc = _cpuSim->read(_baseAddr[_channel]+_ibPend);
   if ((desc & 0x1) != 0 ) return(0);

   addr  = desc & 0x3FFFF;
   *type = (desc >> 26) & 0xF;
   *err  = (desc >> 30) & 0x1;
   pay   = (desc >> 31) & 0x1;

   uintPtr  = (uint *)(_slaveMem + addr);
   ucharPtr = _slaveMem + addr + 24;

   *hdrSize = uintPtr[4];
   *paySize = uintPtr[5];

   printf("Got inbound header Addr: 0x%08x, Type: %i, Err: %i, Pay: %i, HSize: %i, PSize: %i\n",
      addr,*type,*err,pay,*hdrSize,*paySize);
   memcpy(data,ucharPtr,*hdrSize);

   if ( pay == 0 ) {
      printf("Write to ib free list : 0x%08x\n",addr);
      _cpuSim->write(_baseAddr[_channel]+_ibWork,addr);
      return(*hdrSize);
   }

   uintPtr[0] = addr + 24 + *hdrSize;
   uintPtr[1] = *paySize;
   uintPtr[2] = (_channel*2)+1;
   uintPtr[3] = 0x5a5a5a5a;

   printf("Writing to inbound work\n");
   desc = 0x60000000 | addr;
   _cpuSim->write(_baseAddr[_channel]+_ibWork,desc);

   printf("Waiting for inbound completion\n");
   do {
      desc = _cpuSim->read(_compFifos+((_channel*8)+4));
      usleep(100);
   } while ( (desc & 0x1) != 0);
   printf("Got read completion : 0x%08x\n",desc);

   memcpy(data,ucharPtr,*hdrSize+*paySize);

   return(*hdrSize+*paySize);
}

